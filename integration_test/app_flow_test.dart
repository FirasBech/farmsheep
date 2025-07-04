// integration_test/app_flow_test.dart
// Integration test for login → home → animal detail flow, error states, and offline/online sync.
import 'dart:async';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sheepfarm/main.dart' as app;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sheepfarm/main.dart' show ConnectivityStatus;
import 'package:sheepfarm/services/auth_service.dart';
import 'package:sheepfarm/services/database_service.dart';
import 'package:sheepfarm/models/animal.dart';
import 'package:sheepfarm/models/manual_log.dart';
import 'package:sheepfarm/models/activity_log.dart';
import 'package:sheepfarm/models/farm.dart';
import 'package:sheepfarm/models/partner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sheepfarm/screens/home_screen.dart';
import 'package:sheepfarm/screens/add_animal_screen.dart' as add_animal_screen;
import 'package:provider/provider.dart';
import 'package:sheepfarm/providers/farm_provider.dart';
import 'package:sheepfarm/services/offline_sync_service.dart';

// Manual fakes for integration tests
class FakeUser extends Fake implements User {
  @override
  String? get email => 'admin@example.com';
  @override
  String get uid => 'fake-uid';
}

class FakeUserCredential extends Fake implements UserCredential {
  @override
  User? get user => FakeUser();
}

class FakeAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  FakeAuthService() {
    _controller.add(null);
  }
  @override
  Stream<User?> get authStateChanges => _controller.stream;

  // Add cleanup method
  void dispose() {
    _controller.close();
  }

  @override
  Future<UserCredential> signIn(
      {required String email, required String password}) async {
    // simulate authentication; only accept correct credentials
    if (email == 'admin@example.com' && password == 'password123') {
      _controller.add(FakeUser());
      return FakeUserCredential();
    } else {
      throw Exception('Invalid credentials');
    }
  }

  @override
  Future<void> signOut() async {
    _controller.add(null);
  }

  @override
  User? get currentUser => FakeUser();

  @override
  Future<String?> getUserRole() async => 'admin';

  @override
  Future<void> createPartner(
      {required String email, required String password}) async {}

  @override
  Future<UserCredential> register(
      {required String name,
      required String email,
      required String password}) async {
    return FakeUserCredential();
  }

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}
}

class FakeDatabaseService implements DatabaseService {
  final _animals = <Animal>[];
  final _manualLogs = <ManualLog>[];
  final _activityLogs = <ActivityLog>[];
  final _animalsSubject = BehaviorSubject<List<Animal>>.seeded([]);
  final _manualLogsController = StreamController<List<ManualLog>>.broadcast();
  final _activityLogsController =
      StreamController<List<ActivityLog>>.broadcast();
  bool _isOnline = true;

  FakeDatabaseService() {
    _animalsSubject.add(_animals);
    _manualLogsController.add(_manualLogs);
    _activityLogsController.add(_activityLogs);
  }

  // --- Add for test setup ---
  void clearAnimals() {
    _animals.clear();
    _animalsSubject.add(List.from(_animals));
    print('FakeDatabaseService: Cleared animals');
  }

  Future<void> addTestAnimal() async {
    final animal = Animal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tagNumber: 1,
      tagColor: '0xFF000000',
      type: 'sheep',
      breed: 'Damani',
      birthDate: DateTime(2020, 1, 1),
      farmId: 'testFarm',
      photoUrls: [],
    );
    _animals.add(animal);
    _animalsSubject.add(List.from(_animals));
    print('FakeDatabaseService: Added test animal');
  }

  void emitAnimals() {
    _animalsSubject.add(List.from(_animals));
    print('FakeDatabaseService: emitAnimals called');
  }

  List<Animal> get debugAnimals => _animals;
  // --- End test setup helpers ---

  @override
  Stream<List<Animal>> streamAnimals({required String farmId}) {
    return _animalsSubject.stream;
  }

  @override
  Stream<List<ManualLog>> streamManualLogs({required String farmId}) =>
      _manualLogsController.stream;
  @override
  Stream<List<ActivityLog>> streamActivityLogs({required String farmId}) =>
      _activityLogsController.stream;

  void setOnline(bool online) {
    _isOnline = online;
  }

  @override
  Future<void> createAnimal({
    required int tagId,
    required String colorHex,
    required String type,
    required String breed,
    required DateTime birthDate,
    required String farmId,
    List<XFile>? images,
    String? notes,
  }) async {
    if (!_isOnline) {
      throw Exception('Offline: Cannot add animal while offline');
    }
    // Check for duplicate tag
    if (_animals.any((a) => a.tagNumber == tagId)) {
      print('FakeDatabaseService: Duplicate tag detected for tagId: $tagId');
      throw Exception('Animal with this tag already exists');
    }
    final animal = Animal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tagNumber: tagId,
      tagColor: colorHex,
      type: type,
      breed: breed,
      birthDate: birthDate,
      farmId: farmId,
      photoUrls: [],
    );
    _animals.add(animal);
    _animalsSubject.add(List.from(_animals));
    print('FakeDatabaseService: Animal added with tagId: $tagId');
  }

  @override
  Future<void> updateAnimal({
    required String id,
    required int tagId,
    required String colorHex,
    required String type,
    required String breed,
    required DateTime birthDate,
    required String farmId,
    List<XFile>? newImages,
    List<String>? keepPhotoUrls,
    String? adminUserId,
    String? notes,
  }) async {
    final idx = _animals.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _animals[idx] = Animal(
        id: id,
        tagNumber: tagId,
        tagColor: colorHex,
        type: type,
        breed: breed,
        birthDate: birthDate,
        farmId: farmId,
        photoUrls: keepPhotoUrls ?? [],
      );
      _animalsSubject.add(List.from(_animals));
    }
  }

  @override
  Future<void> deleteAnimal(String id,
      {String? adminUserId, String? farmId}) async {
    _animals.removeWhere((a) => a.id == id);
    _animalsSubject.add(List.from(_animals));
  }

  @override
  Future<void> createManualLog({
    required String type,
    List<String>? animalIds,
    required String notes,
    required String performedBy,
    required String farmId,
    DateTime? timestamp,
  }) async {
    final log = ManualLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      animalIds: animalIds ?? [],
      notes: notes,
      performedBy: performedBy,
      farmId: farmId,
      timestamp: timestamp ?? DateTime.now(),
    );
    _manualLogs.add(log);
    _manualLogsController.add(List.from(_manualLogs));
  }

  @override
  Future<void> logAdminAction({
    required String action,
    required String entity,
    required String entityId,
    required String details,
    required String userId,
    required String farmId,
    DateTime? timestamp,
  }) async {
    // Not needed for test flows
  }

  @override
  Future<Farm> createFarm({
    required String name,
    required String address,
    required String ownerId,
    String? notes,
  }) async {
    return Farm(
      id: 'farm1',
      name: name,
      address: address,
      ownerId: ownerId,
      partnerIds: [],
      createdAt: DateTime.now(),
      archived: false,
      preferredBreeds: [],
      color: 0xFF388E3C,
      partnerPermissions: {},
    );
  }

  @override
  Future<void> deleteFarm(String farmId) async {}

  @override
  Future<void> archiveFarm(String farmId) async {}

  final List<Farm> _testFarms = [
    Farm(
      id: 'testFarm',
      name: 'Test Farm',
      address: '123 Test Lane',
      ownerId: 'fake-uid',
      partnerIds: ['fake-uid'],
      createdAt: DateTime(2020, 1, 1),
      archived: false,
      preferredBreeds: [],
      color: 0xFF388E3C,
      partnerPermissions: {},
    ),
  ];
  @override
  Stream<List<Farm>> streamFarms({required String userId}) =>
      Stream.value(_testFarms);
  @override
  Future<List<Partner>> getPartnersForFarm(String farmId) async => [];
  @override
  Future<void> removePartnerFromFarm(String partnerId, String farmId) async {}
  @override
  Future<void> updateFarm(Farm farm) async {}
  @override
  Future<void> updatePartner(Partner partner) async {}
}

class TestFarmProvider extends FarmProvider {
  final List<Farm> _testFarms;
  final Farm? _testSelectedFarm;
  TestFarmProvider({required List<Farm> farms, required Farm? selectedFarm})
      : _testFarms = farms,
        _testSelectedFarm = selectedFarm,
        super(db: FakeDatabaseService(), auth: FakeAuthService());
  @override
  List<Farm> get farms => _testFarms;
  @override
  Farm? get selectedFarm => _testSelectedFarm;
  // Stub out any other required methods as needed
}

// Add test doubles for UserProvider and OfflineSyncService
class FakeUserProvider extends ChangeNotifier {
  final String _role = 'admin';
  final bool _initialized = true;
  String? get role => _role;
  bool get isInitialized => _initialized;
  String? get displayName => 'Test User';
  Future<void> loadUserRole() async {}
}

void main() {
  add_animal_screen.isIntegrationTest = true;

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Create single instances to reuse across tests
  late FakeAuthService fakeAuth;
  late FakeDatabaseService fakeDb;
  setUp(() async {
    // Create fresh instances for each test to avoid state pollution
    fakeAuth = FakeAuthService();
    fakeDb = FakeDatabaseService();

    fakeDb.clearAnimals();
    await fakeDb.addTestAnimal();
    fakeDb.emitAnimals();
    print('Test setup: animals in db = ${fakeDb.debugAnimals.length}');
    await app.main(
      skipFirebase: true,
      authService: fakeAuth,
      databaseService: fakeDb,
    );
  });

  tearDown(() {
    // Clean up resources after each test
    fakeAuth.dispose();
  });

  group('App Integration Flows', () {
    testWidgets('Login → Home → Animal Detail navigation', (tester) async {
      final testFarm = Farm(
        id: 'testFarm',
        name: 'Test Farm',
        address: '123 Test Lane',
        ownerId: 'fake-uid',
        partnerIds: ['fake-uid'],
        createdAt: DateTime(2020, 1, 1),
        archived: false,
        preferredBreeds: [],
        color: 0xFF388E3C,
        partnerPermissions: {},
      );
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthService>.value(value: fakeAuth),
            Provider<DatabaseService>.value(value: fakeDb),
            ChangeNotifierProvider.value(value: FakeUserProvider()),
            ChangeNotifierProvider.value(
                value: TestFarmProvider(
                    farms: [testFarm], selectedFarm: testFarm)),
            ChangeNotifierProvider<OfflineSyncService>.value(
                value: FakeOfflineSyncService()),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
            onGenerateRoute: (settings) {
              if (settings.name == '/farms') {
                return MaterialPageRoute(
                    builder: (_) => const Scaffold(body: Text('Farms Page')));
              }
              return null;
            },
          ),
        ),
      );
      await tester.pumpAndSettle(
          const Duration(milliseconds: 500)); // Reduced wait time
      // Perform login
      await tester.enterText(find.byType(TextField).at(0), 'admin@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();
      // Wait for dashboard to appear (manual loop)
      const dashboardKey = HomeScreen.animalsTileKey;
      final start = DateTime.now();
      while (find.byKey(dashboardKey).evaluate().isEmpty) {
        await tester.pump(const Duration(milliseconds: 100));
        if (DateTime.now().difference(start) > const Duration(seconds: 3)) {
          // Reduced timeout
          fail('Dashboard tile did not appear in time');
        }
      }
      // Go to Animals
      await tester.tap(find.byKey(HomeScreen.animalsTileKey));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(
          const Duration(milliseconds: 300)); // Reduced wait time
      // Should show Animals screen
      expect(find.byKey(const Key('animals_screen_title')), findsOneWidget);
      // Tap first animal card by key
      await tester.tap(find.byKey(const Key('animal_card_0')));
      await tester.pumpAndSettle();
      // Should show Animal Details screen by key
      expect(
          find.byKey(const Key('animal_details_screen_title')), findsOneWidget);
    });

    testWidgets('Shows error on failed login', (tester) async {
      await app.main(
        skipFirebase: true,
        authService: fakeAuth,
        databaseService: fakeDb,
      );
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(TextField).at(0), 'baduser@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrongpass');
      await tester.tap(find.byIcon(Icons.login));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Login failed'), findsOneWidget);
    });

    testWidgets('Offline/online sync banner appears', (tester) async {
      final connectivity = ConnectivityStatus();
      await app.main(
        skipFirebase: true,
        authService: fakeAuth,
        databaseService: fakeDb,
        connectivityStatus: connectivity,
      );
      await tester.pumpAndSettle();
      // Simulate offline
      connectivity.setOnlineForTest(false);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('offline_banner')), findsOneWidget);
      // Simulate back online
      connectivity.setOnlineForTest(true);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('offline_banner')), findsNothing);
    });

    testWidgets('Add Animal flow', (tester) async {
      await app.main(
        skipFirebase: true,
        authService: fakeAuth,
        databaseService: fakeDb,
      );
      await tester.pumpAndSettle();
      // Login
      await tester.enterText(find.byType(TextField).at(0), 'admin@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();
      // Go to Animals
      await tester.tap(find.byKey(HomeScreen.animalsTileKey));
      await tester.pumpAndSettle();
      // Tap Add Animal button
      await tester.tap(find.byKey(const Key('add_animal_fab')));
      await tester.pumpAndSettle();
      // Fill animal form
      await tester.enterText(find.byKey(const Key('animal_tag_field')), '1234');
      await tester.enterText(
          find.byKey(const Key('animal_breed_field')), 'Merino');
      await tester.tap(find.byKey(const Key('animal_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sheep').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('animal_birthdate_tile')));
      await tester.pumpAndSettle();
      // Pick a date (simulate)
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      // Submit
      await tester.tap(find.byKey(const Key('animal_save_button')));
      await tester.pumpAndSettle();
      // Should return to Animals list
      expect(find.byKey(const Key('animals_screen_title')), findsOneWidget);
      // Should show new animal (if list updates)
      expect(find.textContaining('1234'), findsWidgets);
    });

    testWidgets('Add Manual Log flow', (tester) async {
      await app.main(
        skipFirebase: true,
        authService: fakeAuth,
        databaseService: fakeDb,
      );
      await tester.pumpAndSettle();
      // Login
      await tester.enterText(find.byType(TextField).at(0), 'admin@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.byIcon(Icons.login));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byKey(HomeScreen.logsTileKey));
      await tester.pumpAndSettle();
      // Debug: Print current route and widget tree
      debugPrint('DEBUG: After tapping logs tile');
      debugDumpApp();
      // Assert that LogHistoryScreen is present
      expect(find.byKey(const Key('logs_screen_title')), findsOneWidget,
          reason: 'Should find logs screen AppBar');
      // Debug: Check for FAB presence
      final fabFinder = find.byKey(const Key('add_log_fab'));
      debugPrint('DEBUG: FAB found: \\${fabFinder.evaluate().isNotEmpty}');
      expect(fabFinder, findsOneWidget,
          reason: 'Should find Add Log FAB on logs screen');
      // Tap Add Log button
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();
      // Fill log form
      await tester.enterText(find.bySemanticsLabel('Notes'), 'Fed all sheep');
      await tester.tap(find.text('Save'));
      await tester.pump(const Duration(milliseconds: 200));
      // Should return to logs list
      expect(find.byKey(const Key('logs_screen_title')), findsOneWidget);
      expect(find.textContaining('Fed all sheep'), findsWidgets);
    });

    testWidgets('Admin adds partner', (tester) async {
      await app.main(
        skipFirebase: true,
        authService: fakeAuth,
        databaseService: fakeDb,
      );
      await tester.pumpAndSettle();
      // Login
      await tester.enterText(find.byType(TextField).at(0), 'admin@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.byIcon(Icons.login));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byKey(HomeScreen.addPartnerTileKey));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byKey(const Key('add_partner_screen_title')), findsOneWidget);
      await tester.enterText(
          find.bySemanticsLabel('Email'), 'partner@example.com');
      await tester.enterText(find.bySemanticsLabel('Password'), 'partnerpass');
      await tester.tap(find.byKey(const Key('create_partner_button')));
      await tester.pumpAndSettle();
      // Should show success snackbar
      expect(find.textContaining('Partner created'), findsOneWidget);
    });

    testWidgets('Shows error on duplicate animal tag', (tester) async {
      await app.main(
        skipFirebase: true,
        authService: fakeAuth,
        databaseService: fakeDb,
      );
      await tester.pumpAndSettle();
      // Add an animal with tag 1234 to set up the duplicate
      final animal = Animal(
        id: 'test-duplicate',
        tagNumber: 1234,
        tagColor: '0xFF000000',
        type: 'sheep',
        breed: 'Merino',
        birthDate: DateTime(2020, 1, 1),
        farmId: 'testFarm',
        photoUrls: [],
      );
      fakeDb.debugAnimals.add(animal);
      fakeDb.emitAnimals();
      print(
          'Duplicate test setup: animals in db = \\${fakeDb.debugAnimals.map((a) => a.tagNumber).toList()}');

      await tester.pumpAndSettle();
      // Login
      await tester.enterText(find.byType(TextField).at(0), 'admin@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();
      // Go to Animals
      await tester.tap(find.byKey(HomeScreen.animalsTileKey));
      await tester.pumpAndSettle();
      // Tap Add button
      await tester.tap(find.byKey(const Key('add_animal_fab')));
      await tester.pumpAndSettle();
      // Fill animal form with duplicate tag
      await tester.enterText(find.byKey(const Key('animal_tag_field')), '1234');
      await tester.enterText(
          find.byKey(const Key('animal_breed_field')), 'Merino');
      await tester.tap(find.byKey(const Key('animal_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sheep').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('animal_birthdate_tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('animal_save_button')));
      await tester.pumpAndSettle();
      // Should show error
      expect(find.textContaining('Error saving animal'), findsOneWidget);
    });

    testWidgets('Edit Animal flow', (tester) async {
      await app.main(
        skipFirebase: true,
        authService: fakeAuth,
        databaseService: fakeDb,
      );
      await tester.pumpAndSettle();
      // Login
      await tester.enterText(find.byType(TextField).at(0), 'admin@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();
      // Go to Animals
      await tester.tap(find.byKey(HomeScreen.animalsTileKey));
      await tester.pumpAndSettle();
      // Tap first animal card
      await tester.tap(find.byKey(const Key('animal_card_0')));
      await tester.pumpAndSettle();
      // Tap edit button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      // Change breed
      await tester.enterText(
          find.byKey(const Key('animal_breed_field')), 'UpdatedBreed');
      // Save
      await tester.tap(find.byKey(const Key('animal_save_button')));
      await tester.pumpAndSettle();
      // Wait for detail screen to appear
      expect(
          find.byKey(const Key('animal_details_screen_title')), findsOneWidget);
      // Should show updated breed
      expect(find.byKey(const Key('animal_breed_text')), findsOneWidget);
      expect(find.text('UpdatedBreed'), findsOneWidget);
    });

    testWidgets('Delete Animal flow', (tester) async {
      await app.main(
        skipFirebase: true,
        authService: fakeAuth,
        databaseService: fakeDb,
      );
      await tester.pumpAndSettle();
      // Login
      await tester.enterText(find.byType(TextField).at(0), 'admin@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();
      // Go to Animals
      await tester.tap(find.byKey(HomeScreen.animalsTileKey));
      await tester.pumpAndSettle();
      // Tap first animal card
      await tester.tap(find.byKey(const Key('animal_card_0')));
      await tester.pumpAndSettle();
      // Tap delete button (assume key 'delete_animal_button')
      await tester.tap(find.byKey(const Key('delete_animal_button')));
      await tester.pumpAndSettle();
      // Confirm delete (assume dialog with 'Delete' button)
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      // Should return to Animals list and not find the deleted animal
      expect(find.byKey(const Key('animals_screen_title')), findsOneWidget);
      expect(find.byKey(const Key('animal_card_0')), findsNothing);
    });

    testWidgets('Add Animal with camera/image flow', (tester) async {
      await app.main(
        skipFirebase: true,
        authService: fakeAuth,
        databaseService: fakeDb,
      );
      await tester.pumpAndSettle();
      // Login
      await tester.enterText(find.byType(TextField).at(0), 'admin@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();
      // Go to Animals
      await tester.tap(find.byKey(HomeScreen.animalsTileKey));
      await tester.pumpAndSettle();
      // Tap Add Animal button
      await tester.tap(find.byKey(const Key('add_animal_fab')));
      await tester.pumpAndSettle();
      // Tap camera button (assume key 'animal_camera_button')
      await tester.tap(find.byKey(const Key('animal_camera_button')));
      await tester.pumpAndSettle();
      // Should add a mock image (simulate)
      // Fill animal form
      await tester.enterText(find.byKey(const Key('animal_tag_field')), '5678');
      await tester.enterText(
          find.byKey(const Key('animal_breed_field')), 'CameraSheep');
      await tester.tap(find.byKey(const Key('animal_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sheep').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('animal_birthdate_tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('animal_save_button')));
      await tester.pumpAndSettle();
      // Should return to Animals list and show new animal
      expect(find.byKey(const Key('animals_screen_title')), findsOneWidget);
      expect(find.textContaining('5678'), findsWidgets);
    });

    testWidgets('Admin Activity Log and Log History edge cases',
        (tester) async {
      await app.main(
        skipFirebase: true,
        authService: fakeAuth,
        databaseService: fakeDb,
      );
      await tester.pumpAndSettle();
      // Setup: Add manual log and admin log
      fakeDb.clearAnimals();
      await fakeDb.addTestAnimal();
      fakeDb.emitAnimals();
      await tester.pumpAndSettle();
      // Login
      await tester.enterText(find.byType(TextField).at(0), 'admin@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();
      // Go to Admin Activity Log
      await tester.tap(find.byKey(HomeScreen.adminLogsTileKey));
      await tester.pumpAndSettle();
      // Should show empty state or logs
      expect(find.byKey(const Key('admin_logs_screen_title')), findsOneWidget);
      // Go to Log History
      await tester.tap(find.byKey(HomeScreen.logsTileKey));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('logs_screen_title')), findsOneWidget);
      // Edge: No logs
      // expect(find.text('No manual logs found'), findsOneWidget);
    });

    testWidgets('Negative form validation: Add Animal', (tester) async {
      await app.main(
        skipFirebase: true,
        authService: fakeAuth,
        databaseService: fakeDb,
      );
      await tester.pumpAndSettle();
      // Fill in the form with invalid data
      await tester.enterText(find.byKey(const Key('animal_tag_field')), '');
      await tester.enterText(find.byKey(const Key('animal_breed_field')), '');
      await tester.tap(find.byKey(const Key('animal_save_button')));
      await tester.pumpAndSettle();
      // Check for validation messages
      expect(find.text('Tag number is required'), findsOneWidget);
      expect(find.text('Breed is required'), findsOneWidget);
    });

    testWidgets('Failed network scenario: offline add animal', (tester) async {
      final connectivity = ConnectivityStatus();
      fakeDb.clearAnimals();
      await fakeDb.addTestAnimal();
      fakeDb.emitAnimals();
      await app.main(
        skipFirebase: true,
        authService: fakeAuth,
        databaseService: fakeDb,
        connectivityStatus: connectivity,
      );
      await tester.pumpAndSettle();
      // Login
      await tester.enterText(find.byType(TextField).at(0), 'admin@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();
      // Simulate offline
      connectivity.setOnlineForTest(false);
      fakeDb.setOnline(false);
      await tester.pumpAndSettle();
      // Go to Animals
      await tester.tap(find.byKey(HomeScreen.animalsTileKey));
      await tester.pumpAndSettle();
      // Tap Add Animal button
      await tester.tap(find.byKey(const Key('add_animal_fab')));
      await tester.pumpAndSettle();
      // Fill animal form
      await tester.enterText(find.byKey(const Key('animal_tag_field')), '9999');
      await tester.enterText(
          find.byKey(const Key('animal_breed_field')), 'OfflineSheep');
      await tester.tap(find.byKey(const Key('animal_type_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sheep').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('animal_birthdate_tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('animal_save_button')));
      await tester.pumpAndSettle();
      // Should show offline error or not add animal
      expect(find.textContaining('Offline: Cannot add animal while offline'),
          findsOneWidget);
    });
  });
}
