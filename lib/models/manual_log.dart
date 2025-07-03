import 'package:cloud_firestore/cloud_firestore.dart';

class ManualLog {
  String id;
  String type;
  DateTime timestamp;
  List<String>? animalIds;
  String notes;
  String performedBy;
  String farmId; // <-- add this

  ManualLog({
    required this.id,
    required this.type,
    required this.timestamp,
    this.animalIds,
    required this.notes,
    required this.performedBy,
    required this.farmId, // <-- add this
  });

  factory ManualLog.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ManualLog(
      id: doc.id,
      type: data['type'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      animalIds: List<String>.from(data['animalRefs'] ?? []),
      notes: data['notes'] ?? '',
      performedBy: data['performedBy'],
      farmId: data['farmId'], // <-- add this
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'timestamp': timestamp,
        'animalRefs': animalIds ?? [],
        'notes': notes,
        'performedBy': performedBy,
        'farmId': farmId, // <-- add this
      };
}
