import 'package:image_picker/image_picker.dart';
import '../../../../models/animal.dart';
import '../../../../services/database_service.dart';
import '../../domain/repositories/animal_repository.dart';

class AnimalRepositoryImpl implements AnimalRepository {
  final DatabaseService _db;
  AnimalRepositoryImpl(this._db);

  @override
  Stream<List<Animal>> watchAnimals(String farmId) =>
      _db.streamAnimals(farmId: farmId);

  @override
  Future<void> createAnimal({
    required int tagId,
    required String colorHex,
    required String type,
    required String breed,
    required DateTime birthDate,
    required String farmId,
    List<String>? imagePaths,
    Map<String, dynamic>? extraFields,
  }) =>
      _db.createAnimal(
        tagId: tagId,
        colorHex: colorHex,
        type: type,
        breed: breed,
        birthDate: birthDate,
        farmId: farmId,
        images: imagePaths?.map((p) => XFile(p)).toList(),
        extraFields: extraFields,
      );

  @override
  Future<void> updateAnimal({
    required String id,
    required int tagId,
    required String colorHex,
    required String type,
    required String breed,
    required DateTime birthDate,
    required String farmId,
    List<String>? newImagePaths,
    List<String>? keepPhotoUrls,
    String? adminUserId,
    String? overrideReason,
    Map<String, dynamic>? extraFields,
  }) =>
      _db.updateAnimal(
        id: id,
        tagId: tagId,
        colorHex: colorHex,
        type: type,
        breed: breed,
        birthDate: birthDate,
        farmId: farmId,
        newImages: newImagePaths?.map((p) => XFile(p)).toList(),
        keepPhotoUrls: keepPhotoUrls,
        adminUserId: adminUserId,
        overrideReason: overrideReason,
        extraFields: extraFields,
      );

  @override
  Future<void> deleteAnimal(String id,
          {String? adminUserId, String? farmId}) =>
      _db.deleteAnimal(id, adminUserId: adminUserId, farmId: farmId);
}
