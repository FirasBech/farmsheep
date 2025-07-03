import 'package:cloud_firestore/cloud_firestore.dart';

class Farm {
  String id;
  String name;
  String address;
  String ownerId;
  List<String> partnerIds;
  DateTime createdAt;
  String? notes;
  bool archived;
  List<String> preferredBreeds;
  int color;
  Map<String, bool> partnerPermissions;

  Farm({
    required this.id,
    required this.name,
    required this.address,
    required this.ownerId,
    required this.partnerIds,
    required this.createdAt,
    this.notes,
    this.archived = false,
    this.preferredBreeds = const [],
    this.color = 0xFF388E3C, // Default green
    this.partnerPermissions = const {},
  });

  factory Farm.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Farm(
      id: doc.id,
      name: data['name'],
      address: data['address'],
      ownerId: data['ownerId'],
      partnerIds: List<String>.from(data['partnerIds'] ?? []),
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(), // fallback if null
      notes: data['notes'],
      archived: data['archived'] ?? false,
      preferredBreeds: List<String>.from(data['preferredBreeds'] ?? []),
      color: data['color'] ?? 0xFF388E3C,
      partnerPermissions:
          Map<String, bool>.from(data['partnerPermissions'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'ownerId': ownerId,
        'partnerIds': partnerIds,
        'createdAt': createdAt,
        if (notes != null) 'notes': notes,
        'archived': archived,
        'preferredBreeds': preferredBreeds,
        'color': color,
        'partnerPermissions': partnerPermissions,
      };

  Farm copyWith({
    String? name,
    String? address,
    String? ownerId,
    List<String>? partnerIds,
    DateTime? createdAt,
    String? notes,
    bool? archived,
    List<String>? preferredBreeds,
    int? color,
    Map<String, bool>? partnerPermissions,
  }) {
    return Farm(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      ownerId: ownerId ?? this.ownerId,
      partnerIds: partnerIds ?? this.partnerIds,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      archived: archived ?? this.archived,
      preferredBreeds: preferredBreeds ?? this.preferredBreeds,
      color: color ?? this.color,
      partnerPermissions: partnerPermissions ?? this.partnerPermissions,
    );
  }
}
