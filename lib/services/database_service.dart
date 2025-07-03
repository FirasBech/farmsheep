import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/animal.dart';
import '../models/manual_log.dart';
import '../models/activity_log.dart';
import '../models/farm.dart';
import '../models/partner.dart';
import '../constants.dart';

class DatabaseService {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  DatabaseService({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Stream<List<Animal>> streamAnimals({required String farmId}) {
    return _db
        .collection(FirestoreCollections.animals)
        .where('farmId', isEqualTo: farmId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Animal.fromDoc(doc)).toList());
  }

  Stream<List<ManualLog>> streamManualLogs({required String farmId}) {
    return _db
        .collection(FirestoreCollections.manualLogs)
        .where('farmId', isEqualTo: farmId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ManualLog.fromDoc(d)).toList());
  }

  Stream<List<ActivityLog>> streamActivityLogs({required String farmId}) {
    return _db
        .collection(FirestoreCollections.activityLogs)
        .where('farmId', isEqualTo: farmId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ActivityLog.fromDoc(d)).toList());
  }

  Stream<List<Farm>> streamFarms({required String userId}) {
    return _db
        .collection(FirestoreCollections.farms)
        .where('partnerIds', arrayContains: userId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Farm.fromDoc(doc)).toList());
  }

  /// Creates an animal record and uploads optional images to Storage.
  Future<void> createAnimal({
    required int tagId,
    required String colorHex,
    required String type,
    required String breed,
    required DateTime birthDate,
    required String farmId,
    List<XFile>? images,
  }) async {
    // Duplicate-tag check (per farm)
    final dup = await _db
        .collection(FirestoreCollections.animals)
        .where(FirestoreFields.earTagId, isEqualTo: tagId)
        .where('farmId', isEqualTo: farmId)
        .limit(1)
        .get();
    if (dup.docs.isNotEmpty) {
      throw Exception('Tag number $tagId already exists in this farm');
    }
    // Create Firestore document
    final data = {
      'earTag': {'id': tagId, 'color': colorHex},
      'type': type.toLowerCase(),
      'breed': breed,
      'birthDate': Timestamp.fromDate(birthDate),
      'farmId': farmId,
      'pregnancyHistory': [],
      'birthLog': [],
      'healthLogs': [],
      'photoUrls': []
    };
    final docRef = await _db.collection(FirestoreCollections.animals).add(data);
    // Upload each image and update Firestore
    if (images != null) {
      for (var file in images) {
        final fileName =
            '${tagId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef = _storage
            .ref()
            .child('${FirestoreCollections.animals}/${docRef.id}/$fileName');
        await storageRef.putFile(File(file.path));
        final url = await storageRef.getDownloadURL();
        await docRef.update({
          'photoUrls': FieldValue.arrayUnion([url])
        });
      }
    }
  }

  /// Creates a manual action log entry.
  Future<void> createManualLog({
    required String type,
    List<String>? animalIds,
    required String notes,
    required String performedBy,
    required String farmId,
    DateTime? timestamp,
  }) async {
    final data = {
      'type': type,
      'animalRefs': animalIds ?? [],
      'notes': notes,
      'performedBy': performedBy,
      'farmId': farmId,
      'timestamp': timestamp ?? DateTime.now(),
    };
    await _db.collection(FirestoreCollections.manualLogs).add(data);
  }

  /// Logs an admin activity in the audit trail.
  Future<void> logAdminAction({
    required String action,
    required String entity,
    required String entityId,
    required String details,
    required String userId,
    required String farmId,
    DateTime? timestamp,
  }) async {
    final data = {
      'action': action,
      'entity': entity,
      'entityId': entityId,
      'details': details,
      'performedBy': userId,
      'farmId': farmId,
      'timestamp': timestamp ?? DateTime.now(),
    };
    await _db.collection(FirestoreCollections.activityLogs).add(data);
  }

  /// Updates an animal record and manages images.
  Future<void> updateAnimal({
    required String id,
    required int tagId,
    required String colorHex,
    required String type,
    required String breed,
    required DateTime birthDate,
    required String farmId,
    List<XFile>? newImages,
    List<String>? keepPhotoUrls,
    String? adminUserId, // If present, log as admin override
  }) async {
    final docRef = _db.collection(FirestoreCollections.animals).doc(id);
    await docRef.update({
      'earTag': {'id': tagId, 'color': colorHex},
      'type': type.toLowerCase(),
      'breed': breed,
      'birthDate': Timestamp.fromDate(birthDate),
      'farmId': farmId,
      'photoUrls': keepPhotoUrls ?? [],
    });
    if (newImages != null && newImages.isNotEmpty) {
      for (var file in newImages) {
        final fileName =
            '${tagId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef = _storage
            .ref()
            .child('${FirestoreCollections.animals}/$id/$fileName');
        await storageRef.putFile(File(file.path));
        final url = await storageRef.getDownloadURL();
        await docRef.update({
          'photoUrls': FieldValue.arrayUnion([url])
        });
      }
    }
    if (adminUserId != null) {
      await logAdminAction(
        action: 'override',
        entity: 'animal',
        entityId: id,
        details: 'Admin override of animal record',
        userId: adminUserId,
        farmId: farmId,
      );
    }
  }

  /// Deletes an animal record.
  Future<void> deleteAnimal(String id,
      {String? adminUserId, String? farmId}) async {
    await _db.collection(FirestoreCollections.animals).doc(id).delete();
    if (adminUserId != null && farmId != null) {
      await logAdminAction(
        action: 'delete',
        entity: 'animal',
        entityId: id,
        details: 'Admin deleted animal record',
        userId: adminUserId,
        farmId: farmId,
      );
    }
  }

  Future<Farm> createFarm({
    required String name,
    required String address,
    required String ownerId,
    String? notes,
  }) async {
    final doc = await _db.collection(FirestoreCollections.farms).add({
      'name': name,
      'address': address,
      'ownerId': ownerId,
      'partnerIds': [ownerId],
      'createdAt': FieldValue.serverTimestamp(),
      if (notes != null) 'notes': notes,
    });
    final snap = await doc.get();
    return Farm.fromDoc(snap);
  }

  Future<void> updateFarm(Farm farm) async {
    await _db
        .collection(FirestoreCollections.farms)
        .doc(farm.id)
        .update(farm.toMap());
  }

  Future<void> deleteFarm(String farmId) async {
    await _db.collection(FirestoreCollections.farms).doc(farmId).delete();
  }

  Future<void> archiveFarm(String farmId) async {
    await _db
        .collection(FirestoreCollections.farms)
        .doc(farmId)
        .update({'archived': true});
  }

  Future<List<Partner>> getPartnersForFarm(String farmId) async {
    final query = await FirebaseFirestore.instance
        .collection('partners')
        .where('farmIds', arrayContains: farmId)
        .get();
    return query.docs.map((doc) => Partner.fromDoc(doc)).toList();
  }

  Future<void> updatePartner(Partner partner) async {
    await _db.collection('partners').doc(partner.id).update(partner.toMap());
  }

  Future<void> removePartnerFromFarm(String partnerId, String farmId) async {
    final doc = await _db.collection('partners').doc(partnerId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final farmIds = List<String>.from(data['farmIds'] ?? []);
    farmIds.remove(farmId);
    await _db
        .collection('partners')
        .doc(partnerId)
        .update({'farmIds': farmIds});
  }
}
