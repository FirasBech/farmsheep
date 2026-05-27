import '../../../../models/partner.dart';

abstract class PartnerRepository {
  Future<List<Partner>> getPartners(String farmId);
  Future<void> updatePartner(Partner partner);
  Future<void> removePartner(String partnerId, String farmId);
}
