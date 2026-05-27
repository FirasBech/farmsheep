import '../../../../models/activity_log.dart';
import '../../../../models/manual_log.dart';

abstract class LogRepository {
  Stream<List<ManualLog>> watchLogs(String farmId);
  Stream<List<ActivityLog>> watchActivityLogs(String farmId);
  Future<void> createLog({
    required String type,
    List<String>? animalIds,
    required String notes,
    required String performedBy,
    required String farmId,
  });
}
