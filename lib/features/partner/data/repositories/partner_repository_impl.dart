import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/partner.dart';
import '../../domain/repositories/partner_repository.dart';

class PartnerRepositoryImpl implements PartnerRepository {
  final FirebaseFirestore _db;

  PartnerRepositoryImpl({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Partner>> getPartners(String farmId) async {
    final snap = await _db
        .collection('partners')
        .where('farmIds', arrayContains: farmId)
        .get();
    return snap.docs.map((d) => Partner.fromDoc(d)).toList();
  }

  @override
  Future<void> updatePartner(Partner partner) async {
    await _db.collection('partners').doc(partner.id).update(partner.toMap());
  }

  @override
  Future<void> removePartner(String partnerId, String farmId) async {
    final doc = await _db.collection('partners').doc(partnerId).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final farmIds = List<String>.from(data['farmIds'] ?? [])..remove(farmId);
    await _db.collection('partners').doc(partnerId).update({'farmIds': farmIds});
    await _db.collection('farms').doc(farmId).update({
      'partnerIds': FieldValue.arrayRemove([partnerId]),
    });
  }
}
