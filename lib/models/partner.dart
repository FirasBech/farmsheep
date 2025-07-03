import 'package:cloud_firestore/cloud_firestore.dart';

class Partner {
  String id;
  String name;
  String email;
  String color;
  List<String> farmIds;
  String role;
  String? farmId; // <-- add this (optional, for single-farm context)

  Partner({
    required this.id,
    required this.name,
    required this.email,
    required this.color,
    required this.farmIds,
    required this.role,
    this.farmId, // <-- add this
  });

  factory Partner.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Partner(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      color: data['color'] ?? '',
      farmIds: List<String>.from(data['farmIds'] ?? []),
      role: data['role'] ?? 'partner',
      farmId: data['farmId'], // <-- add this
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'color': color,
        'farmIds': farmIds,
        'role': role,
        if (farmId != null) 'farmId': farmId, // <-- add this
      };
}
