import 'package:cloud_firestore/cloud_firestore.dart';

class Partner {
  String id;
  String name;
  String email;
  String color;
  List<String> farmIds;
  String role;

  Partner({
    required this.id,
    required this.name,
    required this.email,
    required this.color,
    required this.farmIds,
    required this.role,
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
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'color': color,
        'farmIds': farmIds,
        'role': role,
      };
}
