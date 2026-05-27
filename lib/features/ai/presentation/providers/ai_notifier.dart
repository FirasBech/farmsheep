import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/animal.dart';
import '../../../../models/manual_log.dart';
import '../../../../models/farm.dart';
import '../../../../services/ai_service.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../domain/repositories/ai_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl(AiService());
});

// ── State ──────────────────────────────────────────────────────────────────

class AiState {
  final String? herdSummary;
  final bool summaryLoading;
  final DateTime? summaryGeneratedAt;
  final String? summaryError;

  const AiState({
    this.herdSummary,
    this.summaryLoading = false,
    this.summaryGeneratedAt,
    this.summaryError,
  });

  AiState copyWith({
    String? herdSummary,
    bool? summaryLoading,
    DateTime? summaryGeneratedAt,
    String? summaryError,
    bool clearSummary = false,
    bool clearError = false,
  }) =>
      AiState(
        herdSummary: clearSummary ? null : (herdSummary ?? this.herdSummary),
        summaryLoading: summaryLoading ?? this.summaryLoading,
        summaryGeneratedAt:
            clearSummary ? null : (summaryGeneratedAt ?? this.summaryGeneratedAt),
        summaryError: clearError ? null : (summaryError ?? this.summaryError),
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────

class AiNotifier extends Notifier<AiState> {
  @override
  AiState build() => const AiState();

  AiRepository get _repo => ref.read(aiRepositoryProvider);

  Future<void> refreshHerdSummary({
    required Farm farm,
    required List<Animal> animals,
    required List<ManualLog> recentLogs,
  }) async {
    state = state.copyWith(summaryLoading: true, clearError: true);
    try {
      final summary = await _repo.generateHerdSummary(
          farm: farm, animals: animals, recentLogs: recentLogs);
      state = state.copyWith(
        herdSummary: summary,
        summaryLoading: false,
        summaryGeneratedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
          summaryLoading: false, summaryError: e.toString());
    }
  }

  void clearSummary() {
    state = state.copyWith(clearSummary: true, clearError: true);
  }

  Future<String> predictHealthRisks(Animal animal) =>
      _repo.predictHealthRisks(animal);

  Future<Map<String, String>> suggestLogEntry({
    required Animal animal,
    required List<ManualLog> recentLogs,
  }) =>
      _repo.suggestLogEntry(animal: animal, recentLogs: recentLogs);

  Future<String> recommendBreeds({
    required String climate,
    required String purpose,
    required String preferences,
  }) =>
      _repo.recommendBreeds(
          climate: climate, purpose: purpose, preferences: preferences);

  Future<String> askHealthQuestion({
    required String question,
    required Animal animal,
  }) =>
      _repo.askHealthQuestion(question: question, animal: animal);
}

// ── Provider ──────────────────────────────────────────────────────────────

final aiNotifierProvider =
    NotifierProvider<AiNotifier, AiState>(AiNotifier.new);
