import '../entities/app_user.dart';

abstract class AuthRepository {
  AppUser? get currentUser;

  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> register(
      {required String name,
      required String email,
      required String password});
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<String?> getUserRole();
  Future<void> updateDisplayName(String name);
  Future<void> updatePhotoUrl(String url);
  Future<void> verifyBeforeUpdateEmail(String email);
  Future<void> updatePassword(String password);
  Future<void> createPartner(
      {required String email, required String password, String? farmId});
  Future<List<Map<String, dynamic>>> fetchAllUsers();
  Future<void> updateUserRole(String uid, String newRole);
}
