import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/activity_log.dart';
import '../../../../models/manual_log.dart';
import '../../data/repositories/log_repository_impl.dart';
import '../../domain/repositories/log_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────

final logRepositoryProvider = Provider<LogRepository>((ref) {
  return LogRepositoryImpl();
});

// ── Stream providers ───────────────────────────────────────────────────────

final logsStreamProvider =
    StreamProvider.family<List<ManualLog>, String>((ref, farmId) {
  return ref.watch(logRepositoryProvider).watchLogs(farmId);
});

final activityLogsStreamProvider =
    StreamProvider.family<List<ActivityLog>, String>((ref, farmId) {
  return ref.watch(logRepositoryProvider).watchActivityLogs(farmId);
});

// ── Notifier for mutations ─────────────────────────────────────────────────

class LogNotifier extends Notifier<void> {
  @override
  void build() {}

  LogRepository get _repo => ref.read(logRepositoryProvider);

  Future<void> createLog({
    required String type,
    List<String>? animalIds,
    required String notes,
    required String performedBy,
    required String farmId,
  }) =>
      _repo.createLog(
        type: type,
        animalIds: animalIds,
        notes: notes,
        performedBy: performedBy,
        farmId: farmId,
      );
}

final logNotifierProvider = NotifierProvider<LogNotifier, void>(LogNotifier.new);
