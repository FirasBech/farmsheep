import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/database_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthService());
});

// ── State ──────────────────────────────────────────────────────────────────

class AuthState {
  final String? role;
  final bool roleLoaded;
  final List<Map<String, dynamic>> users;
  final bool usersLoading;

  const AuthState({
    this.role,
    this.roleLoaded = false,
    this.users = const [],
    this.usersLoading = false,
  });

  AuthState copyWith({
    String? role,
    bool? roleLoaded,
    List<Map<String, dynamic>>? users,
    bool? usersLoading,
    bool clearRole = false,
  }) =>
      AuthState(
        role: clearRole ? null : (role ?? this.role),
        roleLoaded: roleLoaded ?? this.roleLoaded,
        users: users ?? this.users,
        usersLoading: usersLoading ?? this.usersLoading,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  AppUser? get currentUser => _repo.currentUser;

  Future<void> loadRole() async {
    final role = await _repo.getUserRole();
    state = state.copyWith(role: role, roleLoaded: true);
  }

  Future<void> signIn({required String email, required String password}) async {
    await _repo.signIn(email: email, password: password);
    await loadRole();
  }

  Future<void> register(
      {required String name,
      required String email,
      required String password}) async {
    await _repo.register(name: name, email: email, password: password);
    await _repo.sendEmailVerification();
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState();
  }

  Future<void> sendPasswordResetEmail(String email) =>
      _repo.sendPasswordResetEmail(email);

  Future<void> uploadAvatar(String localPath) async {
    final url = await DatabaseService().uploadPhoto(localPath);
    await _repo.updatePhotoUrl(url);
  }

  Future<void> updateProfile(
      {String? name, String? email, String? password}) async {
    if (name != null && name.isNotEmpty) {
      await _repo.updateDisplayName(name);
    }
    final currentEmail = _repo.currentUser?.email;
    if (email != null && email.isNotEmpty && email != currentEmail) {
      await _repo.verifyBeforeUpdateEmail(email);
    }
    if (password != null && password.isNotEmpty) {
      await _repo.updatePassword(password);
    }
  }

  Future<void> createPartner(
          {required String email, required String password}) =>
      _repo.createPartner(email: email, password: password);

  Future<void> loadUsers() async {
    state = state.copyWith(usersLoading: true);
    final users = await _repo.fetchAllUsers();
    state = state.copyWith(users: users, usersLoading: false);
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await _repo.updateUserRole(uid, newRole);
    await loadUsers();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final currentRoleProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).role;
});
