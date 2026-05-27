import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/auth_service.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _auth;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthRepositoryImpl(this._auth);

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      emailVerified: user.emailVerified,
      photoUrl: user.photoURL,
    );
  }

  @override
  Future<void> signIn({required String email, required String password}) =>
      _auth.signIn(email: email, password: password);

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> register(
          {required String name,
          required String email,
          required String password}) =>
      _auth.register(name: name, email: email, password: password);

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email);

  @override
  Future<void> sendEmailVerification() => _auth.sendEmailVerification();

  @override
  Future<String?> getUserRole() => _auth.getUserRole();

  @override
  Future<void> updateDisplayName(String name) =>
      _auth.currentUser!.updateDisplayName(name);

  @override
  Future<void> updatePhotoUrl(String url) =>
      _auth.currentUser!.updatePhotoURL(url);

  @override
  Future<void> verifyBeforeUpdateEmail(String email) =>
      _auth.currentUser!.verifyBeforeUpdateEmail(email);

  @override
  Future<void> updatePassword(String password) =>
      _auth.currentUser!.updatePassword(password);

  @override
  Future<void> createPartner(
          {required String email,
          required String password,
          String? farmId}) =>
      _auth.createPartner(email: email, password: password, farmId: farmId);

  @override
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final snap = await _db.collection('users').get();
    // Include doc ID as uid since it is not stored as a field
    return snap.docs.map((d) => {'uid': d.id, ...d.data()}).toList();
  }

  @override
  Future<void> updateUserRole(String uid, String newRole) =>
      _db.collection('users').doc(uid).update({'role': newRole});
}
