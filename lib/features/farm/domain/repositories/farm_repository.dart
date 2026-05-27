import '../../../../models/farm.dart';

abstract class FarmRepository {
  Stream<List<Farm>> watchFarms(String userId);

  Future<Farm> createFarm({
    required String name,
    required String address,
    required String ownerId,
    String? notes,
    String? adminUserId,
  });

  Future<void> updateFarm(Farm farm, {String? adminUserId});

  Future<void> deleteFarm(String farmId, String callerUid);

  Future<void> archiveFarm(String farmId, {String? adminUserId});
}
