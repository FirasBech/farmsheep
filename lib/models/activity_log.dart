import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  String id;
  String action;
  String entity;
  String entityId;
  String details;
  DateTime timestamp;
  String performedBy;
  String farmId; // <-- add this

  ActivityLog({
    required this.id,
    required this.action,
    required this.entity,
    required this.entityId,
    required this.details,
    required this.timestamp,
    required this.performedBy,
    required this.farmId, // <-- add this
  });

  factory ActivityLog.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLog(
      id: doc.id,
      action: data['action'],
      entity: data['entity'],
      entityId: data['entityId'],
      details: data['details'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      performedBy: data['performedBy'],
      farmId: data['farmId'], // <-- add this
    );
  }

  Map<String, dynamic> toMap() => {
        'action': action,
        'entity': entity,
        'entityId': entityId,
        'details': details,
        'timestamp': timestamp,
        'performedBy': performedBy,
        'farmId': farmId, // <-- add this
      };
}
