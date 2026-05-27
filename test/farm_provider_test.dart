import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sheepfarm/models/animal.dart';
import 'package:sheepfarm/models/farm.dart';
import 'package:sheepfarm/providers/farm_provider.dart';
import 'package:sheepfarm/services/database_service.dart';
import 'package:sheepfarm/services/auth_service.dart';
import 'package:fake_async/fake_async.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _FakeAuthService extends Fake implements AuthService {
  final _fakeUser = _FakeUser();

  @override
  Stream<User?> get authStateChanges => Stream.value(_fakeUser);

  @override
  User? get currentUser => _fakeUser;

  // Only methods used by FarmProvider need implementation
  @override
  Future<String?> getUserRole() async => 'owner';

  // The rest can throw UnimplementedError since they are not invoked here
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'fake-uid';
}

class _FakeDatabaseService implements DatabaseService {
  final _ctrl = StreamController<List<Farm>>.broadcast();

  // helper to emit farms
  void emitFarms(List<Farm> farms) => _ctrl.add(farms);

  @override
  Stream<List<Farm>> streamFarms({required String userId}) => _ctrl.stream;

  @override
  Stream<List<Animal>> streamAnimals({required String farmId}) =>
      Stream.value([]);

  // Unused methods throw
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('FarmProvider', () {
    late _FakeDatabaseService fakeDb;
    late _FakeAuthService fakeAuth;
    late FarmProvider provider;

    setUp(() {
      fakeDb = _FakeDatabaseService();
      fakeAuth = _FakeAuthService();
      provider = FarmProvider(db: fakeDb, auth: fakeAuth);
    });

    test('loads farms and selects first farm', () {
      final farm1 = Farm(
        id: 'f1',
        name: 'Farm 1',
        address: 'Addr',
        ownerId: 'fake-uid',
        partnerIds: const [],
        createdAt: DateTime.now(),
        archived: false,
        preferredBreeds: const [],
        color: 0xFF388E3C,
        partnerPermissions: const {},
      );
      fakeAsync((async) {
        provider.loadFarms();
        // emit farms after loadFarms has attached listener
        fakeDb.emitFarms([farm1]);
        // pump microtasks
        async.flushMicrotasks();
        expect(provider.farms, isNotEmpty);
        expect(provider.selectedFarm, equals(farm1));
      });
    });

    test('selectFarm updates selectedFarm', () {
      final farm = Farm(
        id: 'f2',
        name: 'Farm 2',
        address: 'Addr2',
        ownerId: 'fake-uid',
        partnerIds: const [],
        createdAt: DateTime.now(),
        archived: false,
        preferredBreeds: const [],
        color: 0xFF388E3C,
        partnerPermissions: const {},
      );
      provider.selectFarm(farm);
      expect(provider.selectedFarm, equals(farm));
    });
  });
}
