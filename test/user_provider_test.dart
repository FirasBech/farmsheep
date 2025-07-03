import 'package:flutter_test/flutter_test.dart';
import 'package:sheepfarm/providers/user_provider.dart';
import 'package:sheepfarm/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _FakeAuthService extends Fake implements AuthService {
  final _user = _FakeUser();

  @override
  User? get currentUser => _user;

  @override
  Future<String?> getUserRole() async => 'admin';

  @override
  Stream<User?> get authStateChanges => Stream.value(_user);

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUser extends Fake implements User {
  @override
  String? get displayName => 'Jane Doe';
  @override
  String? get email => 'jane@example.com';
}

void main() {
  group('UserProvider', () {
    late _FakeAuthService fakeAuth;
    late UserProvider provider;

    setUp(() {
      fakeAuth = _FakeAuthService();
      provider = UserProvider(authService: fakeAuth);
    });

    test('loadUserRole sets role and initialized flag', () async {
      await provider.loadUserRole();
      expect(provider.role, equals('admin'));
      expect(provider.isInitialized, isTrue);
    });

    test('displayName falls back to email prefix when displayName null', () {
      expect(provider.displayName, equals('Jane Doe'));

      final authNoName = _FakeAuthServiceNoName();
      final provNoName = UserProvider(authService: authNoName);
      expect(provNoName.displayName, equals('noname'));
    });
  });
}

class _FakeUserNoName extends Fake implements User {
  @override
  String? get displayName => null;
  @override
  String? get email => 'noname@example.com';
}

class _FakeAuthServiceNoName extends Fake implements AuthService {
  final _user = _FakeUserNoName();
  @override
  User? get currentUser => _user;
  @override
  Future<String?> getUserRole() async => 'partner';
  @override
  Stream<User?> get authStateChanges => Stream.value(_user);
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
