import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(
      {required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    // Ensure role exists for accounts created before role was introduced.
    final uid = cred.user!.uid;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data()?['role'] == null) {
      await _db.collection('users').doc(uid).set(
          {'role': 'admin'}, SetOptions(merge: true));
    }
    return cred;
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  Future<String?> getUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  /// Creates a new partner user via the self-hosted server (admin-only).
  Future<void> createPartner({
    required String email,
    required String password,
    String? farmId,
  }) async {
    final callerUid = _auth.currentUser?.uid;
    final response = await http.post(
      Uri.parse('$kServerUrl/api/partner'),
      headers: {
        'Authorization': 'Bearer $kServerSecret',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        if (farmId != null) 'farmId': farmId,
        if (callerUid != null) 'callerUid': callerUid,
      }),
    ).timeout(const Duration(seconds: 30));

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? data['error'] ?? 'Failed to create partner');
    }
  }

  Future<UserCredential> register(
      {required String name,
      required String email,
      required String password}) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return cred;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}
