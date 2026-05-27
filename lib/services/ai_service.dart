import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/animal.dart';
import '../models/manual_log.dart';
import '../models/farm.dart';
import '../config.dart';

class AiService {
  Future<String> _call(String feature, Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$kServerUrl/api/ai'),
      headers: {
        'Authorization': 'Bearer $kServerSecret',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'feature': feature, 'payload': payload}),
    ).timeout(const Duration(seconds: 30));

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'AI request failed (${response.statusCode})');
    }
    return data['response'] as String;
  }

  Future<String> askHealthQuestion({
    required String question,
    required Animal animal,
  }) async {
    final ageMonths = DateTime.now().difference(animal.birthDate).inDays ~/ 30;
    return _call('healthChat', {
      'question': question,
      'animalType': animal.type,
      'breed': animal.breed,
      'ageMonths': ageMonths,
      'status': animal.status,
      'recentHealthLogs': animal.healthLogs.take(5).toList(),
    });
  }

  Future<String> predictHealthRisks(Animal animal) async {
    final ageMonths = DateTime.now().difference(animal.birthDate).inDays ~/ 30;
    return _call('healthPrediction', {
      'animalType': animal.type,
      'breed': animal.breed,
      'ageMonths': ageMonths,
      'healthLogs': animal.healthLogs,
      'pregnancyHistory': animal.pregnancyHistory,
      'currentStatus': animal.status,
    });
  }

  Future<Map<String, String>> suggestLogEntry({
    required Animal animal,
    required List<ManualLog> recentLogs,
  }) async {
    final logsPayload = recentLogs
        .take(10)
        .map((l) => {
              'type': l.type,
              'notes': l.notes,
              'daysAgo': DateTime.now().difference(l.timestamp).inDays,
            })
        .toList();
    final response = await _call('logSuggestion', {
      'animalType': animal.type,
      'breed': animal.breed,
      'currentStatus': animal.status,
      'recentLogs': logsPayload,
    });
    try {
      final cleaned = response.trim();
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start != -1 && end != -1) {
        final parsed = jsonDecode(cleaned.substring(start, end + 1)) as Map<String, dynamic>;
        return {
          'type': (parsed['type'] as String?) ?? 'Observation',
          'notes': (parsed['notes'] as String?) ?? response,
        };
      }
    } catch (_) {}
    return {'type': 'Observation', 'notes': response};
  }

  Future<String> generateHerdSummary({
    required Farm farm,
    required List<Animal> animals,
    required List<ManualLog> recentLogs,
  }) async {
    final statusCounts = <String, int>{};
    for (final a in animals) {
      statusCounts[a.status] = (statusCounts[a.status] ?? 0) + 1;
    }
    final breeds = animals.map((a) => a.breed).toSet().toList();
    final recentLogTypes = recentLogs.take(20).map((l) => l.type).toList();
    return _call('herdSummary', {
      'farmName': farm.name,
      'totalAnimals': animals.length,
      'statusBreakdown': statusCounts,
      'breeds': breeds,
      'recentLogTypes': recentLogTypes,
    });
  }

  Future<String> recommendBreeds({
    required String climate,
    required String purpose,
    required String preferences,
  }) async {
    return _call('breedRecommendation', {
      'climate': climate,
      'purpose': purpose,
      'preferences': preferences,
    });
  }
}
