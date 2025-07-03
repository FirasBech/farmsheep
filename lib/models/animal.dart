import 'package:cloud_firestore/cloud_firestore.dart';

class Animal {
  String id;
  int tagNumber;
  String tagColor;
  String type; // sheep or goat
  String breed;
  DateTime birthDate;
  String farmId; // <-- add this
  List<Map<String, dynamic>> pregnancyHistory;
  List<Map<String, dynamic>> birthLog;
  List<Map<String, dynamic>> healthLogs;
  Map<String, dynamic>? saleInfo;
  List<String>? photoUrls;
  Map<String, dynamic> customFields;

  Animal({
    required this.id,
    required this.tagNumber,
    required this.tagColor,
    required this.type,
    required this.breed,
    required this.birthDate,
    required this.farmId, // <-- add this
    this.pregnancyHistory = const [],
    this.birthLog = const [],
    this.healthLogs = const [],
    this.saleInfo,
    this.photoUrls,
    this.customFields = const {},
  });

  factory Animal.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Animal(
      id: doc.id,
      tagNumber: data['earTag']['id'],
      tagColor: data['earTag']['color'],
      type: data['type'],
      breed: data['breed'],
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      farmId: data['farmId'], // <-- add this
      pregnancyHistory:
          List<Map<String, dynamic>>.from(data['pregnancyHistory'] ?? []),
      birthLog: List<Map<String, dynamic>>.from(data['birthLog'] ?? []),
      healthLogs: List<Map<String, dynamic>>.from(data['healthLogs'] ?? []),
      saleInfo: data['saleInfo'],
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      customFields: Map<String, dynamic>.from(data['customFields'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'earTag': {'id': tagNumber, 'color': tagColor},
        'type': type,
        'breed': breed,
        'birthDate': birthDate,
        'farmId': farmId, // <-- add this
        'pregnancyHistory': pregnancyHistory,
        'birthLog': birthLog,
        'healthLogs': healthLogs,
        if (saleInfo != null) 'saleInfo': saleInfo,
        'photoUrls': photoUrls ?? [],
        'customFields': customFields,
      };

  String get tagId => tagNumber.toString();
  String get status {
    if (saleInfo != null && saleInfo!['sold'] == true) return 'Sold';
    if (healthLogs.any((log) => log['type'] == 'death')) return 'Dead';
    if (healthLogs.any((log) => log['type'] == 'sick')) return 'Sick';
    if (healthLogs.any((log) => log['type'] == 'quarantined')) {
      return 'Quarantined';
    }
    if (pregnancyHistory.isNotEmpty) return 'Pregnant';
    // Add more logic as needed
    return 'Alive';
  }

  // PDF export stub
  Future<void> exportToPdf() async {
    // TODO: Implement PDF export logic (platform-specific)
  }
}
