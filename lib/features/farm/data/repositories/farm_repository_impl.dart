import '../../../../models/farm.dart';
import '../../../../services/database_service.dart';
import '../../domain/repositories/farm_repository.dart';

class FarmRepositoryImpl implements FarmRepository {
  final DatabaseService _db;
  FarmRepositoryImpl(this._db);

  @override
  Stream<List<Farm>> watchFarms(String userId) =>
      _db.streamFarms(userId: userId);

  @override
  Future<Farm> createFarm({
    required String name,
    required String address,
    required String ownerId,
    String? notes,
    String? adminUserId,
  }) =>
      _db.createFarm(
        name: name,
        address: address,
        ownerId: ownerId,
        notes: notes,
        adminUserId: adminUserId,
      );

  @override
  Future<void> updateFarm(Farm farm, {String? adminUserId}) =>
      _db.updateFarm(farm, adminUserId: adminUserId);

  @override
  Future<void> deleteFarm(String farmId, String callerUid) =>
      _db.deleteFarm(farmId, callerUid);

  @override
  Future<void> archiveFarm(String farmId, {String? adminUserId}) =>
      _db.archiveFarm(farmId, adminUserId: adminUserId);
}
