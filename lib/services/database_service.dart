import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import '../models/animal.dart';
import '../models/manual_log.dart';
import '../models/activity_log.dart';
import '../models/farm.dart';
import '../models/partner.dart';
import '../constants.dart';
import '../config.dart';

class DatabaseService {
  final FirebaseFirestore _db;

  DatabaseService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Compresses an image to max 1200px width at 80% quality.
  Future<Uint8List> _compressImage(String path) async {
    final result = await FlutterImageCompress.compressWithFile(
      path,
      minWidth: 1200,
      minHeight: 1200,
      quality: 80,
      format: CompressFormat.jpeg,
    );
    return result ?? await File(path).readAsBytes();
  }

  /// Uploads a compressed photo to the self-hosted server and returns its URL.
  Future<String> uploadPhoto(String filePath) async {
    final compressed = await _compressImage(filePath);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$kServerUrl/api/photo/upload'),
    );
    request.headers['Authorization'] = 'Bearer $kServerSecret';
    request.files.add(http.MultipartFile.fromBytes(
      'photo',
      compressed,
      filename: '${DateTime.now().millisecondsSinceEpoch}.jpg',
    ));
    final streamResponse =
        await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamResponse);
    if (response.statusCode != 200) {
      throw Exception('Photo upload failed: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['url'] as String;
  }

  /// Deletes a server-hosted photo by URL. Silently skips non-server URLs.
  Future<void> _deletePhoto(String url) async {
    if (!url.startsWith(kServerUrl)) return;
    try {
      await http.delete(
        Uri.parse('$kServerUrl/api/photo'),
        headers: {
          'Authorization': 'Bearer $kServerSecret',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'url': url}),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  /// Recursively converts any DateTime values in a map to Firestore Timestamps.
  Map<String, dynamic> _convertDates(Map<String, dynamic> map) {
    return map.map((k, v) {
      if (v is DateTime) return MapEntry(k, Timestamp.fromDate(v));
      if (v is Map<String, dynamic>) return MapEntry(k, _convertDates(v));
      if (v is List) {
        return MapEntry(k, v.map((e) => e is Map<String, dynamic> ? _convertDates(e) : e).toList());
      }
      return MapEntry(k, v);
    });
  }

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
        .snapshots(includeMetadataChanges: true)
        // Skip empty-cache snapshots so loading stays true until server responds.
        .where((snap) => !snap.metadata.isFromCache || snap.docs.isNotEmpty)
        .map((snap) => snap.docs.map((doc) => Farm.fromDoc(doc)).toList());
  }

  Future<bool> isPartnerAlreadyInFarm(String email, String farmId) async {
    final userQuery = await _db
        .collection(FirestoreCollections.users)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (userQuery.docs.isEmpty) return false;
    final uid = userQuery.docs.first.id;
    final farmDoc =
        await _db.collection(FirestoreCollections.farms).doc(farmId).get();
    if (!farmDoc.exists) return false;
    final data = farmDoc.data() as Map<String, dynamic>;
    final partnerIds = List<String>.from(data['partnerIds'] ?? []);
    return partnerIds.contains(uid);
  }

  Future<void> createAnimal({
    required int tagId,
    required String colorHex,
    required String type,
    required String breed,
    required DateTime birthDate,
    required String farmId,
    List<XFile>? images,
    Map<String, dynamic>? extraFields,
  }) async {
    final dup = await _db
        .collection(FirestoreCollections.animals)
        .where(FirestoreFields.earTagId, isEqualTo: tagId)
        .where('farmId', isEqualTo: farmId)
        .limit(1)
        .get();
    if (dup.docs.isNotEmpty) {
      throw Exception('Tag number $tagId already exists in this farm');
    }
    final data = <String, dynamic>{
      'earTag': {'id': tagId, 'color': colorHex},
      'type': type.toLowerCase(),
      'breed': breed,
      'birthDate': Timestamp.fromDate(birthDate),
      'farmId': farmId,
      'pregnancyHistory': [],
      'birthLog': [],
      'healthLogs': [],
      'photoUrls': [],
      if (extraFields != null) ..._convertDates(extraFields),
    };
    final docRef = await _db.collection(FirestoreCollections.animals).add(data);
    if (images != null) {
      for (final file in images) {
        final url = await uploadPhoto(file.path);
        await docRef.update({
          'photoUrls': FieldValue.arrayUnion([url])
        });
      }
    }
  }

  Future<void> createManualLog({
    required String type,
    List<String>? animalIds,
    required String notes,
    required String performedBy,
    required String farmId,
    DateTime? timestamp,
  }) async {
    await _db.collection(FirestoreCollections.manualLogs).add({
      'type': type,
      'animalIds': animalIds ?? [],
      'notes': notes,
      'performedBy': performedBy,
      'farmId': farmId,
      'timestamp': timestamp ?? DateTime.now(),
    });
  }

  Future<void> logAdminAction({
    required String action,
    required String entity,
    required String entityId,
    required String details,
    required String userId,
    required String farmId,
    DateTime? timestamp,
  }) async {
    await _db.collection(FirestoreCollections.activityLogs).add({
      'action': action,
      'entity': entity,
      'entityId': entityId,
      'details': details,
      'performedBy': userId,
      'farmId': farmId,
      'timestamp': timestamp ?? DateTime.now(),
    });
  }

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
    String? adminUserId,
    String? overrideReason,
    Map<String, dynamic>? extraFields,
  }) async {
    final docRef = _db.collection(FirestoreCollections.animals).doc(id);

    if (keepPhotoUrls != null) {
      final snap = await docRef.get();
      final existing =
          List<String>.from(snap.data()?['photoUrls'] ?? []);
      final removed = existing.where((url) => !keepPhotoUrls.contains(url));
      for (final url in removed) {
        await _deletePhoto(url);
      }
    }

    await docRef.update({
      'earTag': {'id': tagId, 'color': colorHex},
      'type': type.toLowerCase(),
      'breed': breed,
      'birthDate': Timestamp.fromDate(birthDate),
      'farmId': farmId,
      'photoUrls': keepPhotoUrls ?? [],
      if (extraFields != null) ..._convertDates(extraFields),
    });

    if (newImages != null && newImages.isNotEmpty) {
      for (final file in newImages) {
        final url = await uploadPhoto(file.path);
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
        details: overrideReason ?? 'Admin override of animal record',
        userId: adminUserId,
        farmId: farmId,
      );
    }
  }

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
    String? adminUserId,
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
    final farm = Farm.fromDoc(snap);
    if (adminUserId != null) {
      await logAdminAction(
        action: 'create',
        entity: 'farm',
        entityId: farm.id,
        details: 'Farm created: $name',
        userId: adminUserId,
        farmId: farm.id,
      );
    }
    return farm;
  }

  Future<void> updateFarm(Farm farm, {String? adminUserId}) async {
    await _db
        .collection(FirestoreCollections.farms)
        .doc(farm.id)
        .update(farm.toMap());
    if (adminUserId != null) {
      await logAdminAction(
        action: 'update',
        entity: 'farm',
        entityId: farm.id,
        details: 'Farm updated: ${farm.name}',
        userId: adminUserId,
        farmId: farm.id,
      );
    }
  }

  /// Cascade-deletes a farm and all its data via the self-hosted server.
  Future<void> deleteFarm(String farmId, String callerUid) async {
    final response = await http.post(
      Uri.parse('$kServerUrl/api/farm/delete-cascade'),
      headers: {
        'Authorization': 'Bearer $kServerSecret',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'farmId': farmId, 'callerUid': callerUid}),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['error'] ?? 'Farm deletion failed');
    }
  }

  Future<void> archiveFarm(String farmId, {String? adminUserId}) async {
    await _db
        .collection(FirestoreCollections.farms)
        .doc(farmId)
        .update({'archived': true});
    if (adminUserId != null) {
      await logAdminAction(
        action: 'archive',
        entity: 'farm',
        entityId: farmId,
        details: 'Farm archived',
        userId: adminUserId,
        farmId: farmId,
      );
    }
  }

  Future<List<Partner>> getPartnersForFarm(String farmId) async {
    final query = await _db
        .collection('partners')
        .where('farmIds', arrayContains: farmId)
        .get();
    return query.docs.map((doc) => Partner.fromDoc(doc)).toList();
  }

  Future<void> updatePartner(Partner partner,
      {String? adminUserId, String? farmId}) async {
    await _db.collection('partners').doc(partner.id).update(partner.toMap());
    if (adminUserId != null && farmId != null) {
      await logAdminAction(
        action: 'update',
        entity: 'partner',
        entityId: partner.id,
        details: 'Partner updated: ${partner.name}',
        userId: adminUserId,
        farmId: farmId,
      );
    }
  }

  Future<void> removePartnerFromFarm(String partnerId, String farmId,
      {String? adminUserId}) async {
    final doc = await _db.collection('partners').doc(partnerId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final farmIds = List<String>.from(data['farmIds'] ?? []);
    farmIds.remove(farmId);
    await _db.collection('partners').doc(partnerId).update({'farmIds': farmIds});
    await _db.collection(FirestoreCollections.farms).doc(farmId).update({
      'partnerIds': FieldValue.arrayRemove([partnerId]),
    });
    if (adminUserId != null) {
      await logAdminAction(
        action: 'remove',
        entity: 'partner',
        entityId: partnerId,
        details: 'Partner removed from farm',
        userId: adminUserId,
        farmId: farmId,
      );
    }
  }
}
