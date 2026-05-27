import '../../../../models/animal.dart';

abstract class AnimalRepository {
  Stream<List<Animal>> watchAnimals(String farmId);

  Future<void> createAnimal({
    required int tagId,
    required String colorHex,
    required String type,
    required String breed,
    required DateTime birthDate,
    required String farmId,
    List<String>? imagePaths,
    Map<String, dynamic>? extraFields,
  });

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
  });

  Future<void> deleteAnimal(String id, {String? adminUserId, String? farmId});
}
