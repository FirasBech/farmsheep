import '../../../../models/animal.dart';
import '../../../../models/manual_log.dart';
import '../../../../models/farm.dart';

abstract class AiRepository {
  Future<String> askHealthQuestion({
    required String question,
    required Animal animal,
  });

  Future<String> predictHealthRisks(Animal animal);

  Future<Map<String, String>> suggestLogEntry({
    required Animal animal,
    required List<ManualLog> recentLogs,
  });

  Future<String> generateHerdSummary({
    required Farm farm,
    required List<Animal> animals,
    required List<ManualLog> recentLogs,
  });

  Future<String> recommendBreeds({
    required String climate,
    required String purpose,
    required String preferences,
  });
}
