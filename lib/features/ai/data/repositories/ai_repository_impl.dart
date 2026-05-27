import '../../../../models/animal.dart';
import '../../../../models/manual_log.dart';
import '../../../../models/farm.dart';
import '../../../../services/ai_service.dart';
import '../../domain/repositories/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final AiService _service;

  AiRepositoryImpl(this._service);

  @override
  Future<String> askHealthQuestion({
    required String question,
    required Animal animal,
  }) =>
      _service.askHealthQuestion(question: question, animal: animal);

  @override
  Future<String> predictHealthRisks(Animal animal) =>
      _service.predictHealthRisks(animal);

  @override
  Future<Map<String, String>> suggestLogEntry({
    required Animal animal,
    required List<ManualLog> recentLogs,
  }) =>
      _service.suggestLogEntry(animal: animal, recentLogs: recentLogs);

  @override
  Future<String> generateHerdSummary({
    required Farm farm,
    required List<Animal> animals,
    required List<ManualLog> recentLogs,
  }) =>
      _service.generateHerdSummary(
          farm: farm, animals: animals, recentLogs: recentLogs);

  @override
  Future<String> recommendBreeds({
    required String climate,
    required String purpose,
    required String preferences,
  }) =>
      _service.recommendBreeds(
          climate: climate, purpose: purpose, preferences: preferences);
}
