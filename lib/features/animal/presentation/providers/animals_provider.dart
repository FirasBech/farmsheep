import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/animal.dart';
import '../../../../services/database_service.dart';
import '../../data/repositories/animal_repository_impl.dart';
import '../../domain/repositories/animal_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────

final animalRepositoryProvider = Provider<AnimalRepository>((ref) {
  return AnimalRepositoryImpl(DatabaseService());
});

// ── Stream provider: all animals for a farm ────────────────────────────────

final animalsStreamProvider =
    StreamProvider.family<List<Animal>, String>((ref, farmId) {
  return ref.watch(animalRepositoryProvider).watchAnimals(farmId);
});

// ── Notifier for mutations ─────────────────────────────────────────────────

class AnimalNotifier extends Notifier<void> {
  @override
  void build() {}

  AnimalRepository get _repo => ref.read(animalRepositoryProvider);

  Future<void> create({
    required int tagId,
    required String colorHex,
    required String type,
    required String breed,
    required DateTime birthDate,
    required String farmId,
    List<String>? imagePaths,
    Map<String, dynamic>? extraFields,
  }) =>
      _repo.createAnimal(
        tagId: tagId,
        colorHex: colorHex,
        type: type,
        breed: breed,
        birthDate: birthDate,
        farmId: farmId,
        imagePaths: imagePaths,
        extraFields: extraFields,
      );

  Future<void> update({
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
      _repo.updateAnimal(
        id: id,
        tagId: tagId,
        colorHex: colorHex,
        type: type,
        breed: breed,
        birthDate: birthDate,
        farmId: farmId,
        newImagePaths: newImagePaths,
        keepPhotoUrls: keepPhotoUrls,
        adminUserId: adminUserId,
        overrideReason: overrideReason,
        extraFields: extraFields,
      );

  Future<void> delete(String id, {String? adminUserId, String? farmId}) =>
      _repo.deleteAnimal(id, adminUserId: adminUserId, farmId: farmId);
}

final animalNotifierProvider =
    NotifierProvider<AnimalNotifier, void>(AnimalNotifier.new);
