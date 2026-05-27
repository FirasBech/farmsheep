import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/activity_log.dart';
import '../../../../models/manual_log.dart';
import '../../domain/repositories/log_repository.dart';

class LogRepositoryImpl implements LogRepository {
  final FirebaseFirestore _db;

  LogRepositoryImpl({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ManualLog>> watchLogs(String farmId) {
    return _db
        .collection('manualLogs')
        .where('farmId', isEqualTo: farmId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ManualLog.fromDoc(d)).toList());
  }

  @override
  Stream<List<ActivityLog>> watchActivityLogs(String farmId) {
    return _db
        .collection('activityLogs')
        .where('farmId', isEqualTo: farmId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ActivityLog.fromDoc(d)).toList());
  }

  @override
  Future<void> createLog({
    required String type,
    List<String>? animalIds,
    required String notes,
    required String performedBy,
    required String farmId,
  }) async {
    await _db.collection('manualLogs').add({
      'type': type,
      'animalIds': animalIds ?? [],
      'notes': notes,
      'performedBy': performedBy,
      'farmId': farmId,
      'timestamp': DateTime.now(),
    });
  }
}
