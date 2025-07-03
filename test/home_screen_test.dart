import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sheepfarm/providers/user_provider.dart';
import 'package:sheepfarm/screens/home_screen.dart';
import 'package:sheepfarm/services/auth_service.dart';
import 'package:sheepfarm/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sheepfarm/providers/farm_provider.dart';
import 'package:sheepfarm/models/animal.dart';
import 'package:sheepfarm/models/farm.dart';
import 'package:sheepfarm/models/partner.dart';
import 'package:sheepfarm/models/manual_log.dart';
import 'package:sheepfarm/services/offline_sync_service.dart';

class FakeUserProvider extends ChangeNotifier implements UserProvider {
  @override
  String get role => 'admin';
  @override
  bool get isInitialized => true;
  @override
  Future<void> loadUserRole() async {}
  @override
  String get displayName => 'Test User'; // Add if required
}

class FakeAuthService extends Fake implements AuthService {
  @override
  Stream<User?> get authStateChanges => Stream.value(FakeUser());
  @override
  User? get currentUser => FakeUser();
}

class FakeUser extends Fake implements User {
  @override
  String get email => 'test@example.com';
}

class FakeDatabaseService extends Fake implements DatabaseService {
  @override
  Stream<List<Animal>> streamAnimals({required String farmId}) => Stream.value([
        // Provide at least one animal to trigger dashboard rendering
        // Use a minimal Animal with required fields
        Animal(
          id: '1',
          tagNumber: 1,
          tagColor: '0xFF000000',
          type: 'sheep',
          breed: 'Damani',
          birthDate: DateTime(2020, 1, 1),
          farmId: farmId,
        ),
      ]);
  @override
  Future<List<Partner>> getPartnersForFarm(String farmId) async => [
        Partner(
          id: 'p1',
          name: 'Partner 1',
          email: 'partner1@example.com',
          color: '#FF0000',
          farmIds: [farmId],
          role: 'owner',
          farmId: farmId,
        ),
      ];
  @override
  Stream<List<ManualLog>> streamManualLogs({required String farmId}) =>
      Stream.value([
        ManualLog(
          id: 'log1',
          type: 'Health',
          timestamp: DateTime(2024, 1, 1),
          notes: 'Healthy',
          performedBy: 'admin',
          farmId: farmId,
        ),
      ]);
  // Add similar stubs for logs, partners, etc. if needed by HomeScreen
}

class TestFarmProvider extends ChangeNotifier implements FarmProvider {
  @override
  Farm? get selectedFarm => Farm(
        id: 'farm1',
        name: 'Test Farm',
        address: '123 Test St',
        ownerId: 'user1',
        partnerIds: const [],
        createdAt: DateTime(2024, 1, 1),
        archived: false,
        preferredBreeds: const [],
        color: 0xFF388E3C,
        partnerPermissions: const {},
      );
  @override
  List<Farm> get farms => [selectedFarm!];
  @override
  List<Farm> get archivedFarms => [];
  @override
  void loadFarms() {}
  @override
  void selectFarm(Farm farm) {}
  @override
  Future<void> addFarm(String name, String address, {String? notes}) async {}
  @override
  Future<void> updateFarm(Farm farm) async {}
  @override
  Future<void> deleteFarm(String farmId) async {}
  @override
  Future<void> archiveFarm(String farmId) async {}
  @override
  FakeAuthService get auth => FakeAuthService();
  @override
  FakeDatabaseService get db => FakeDatabaseService();
}

class FakeOfflineSyncService extends ChangeNotifier
    implements OfflineSyncService {
  @override
  bool get isOnline => true;
  @override
  bool get isSyncing => false;
  @override
  bool get hasConflicts => false;
  @override
  String? get conflictMessage => null;
  @override
  Future<void> manualSync() async {}
}

void main() {
  testWidgets('HomeScreen shows dashboard and admin tiles',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: FakeAuthService()),
          Provider<DatabaseService>.value(value: FakeDatabaseService()),
          ChangeNotifierProvider<UserProvider>.value(value: FakeUserProvider()),
          ChangeNotifierProvider<FarmProvider>.value(value: TestFarmProvider()),
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
    await tester.pumpAndSettle();
    // Debug: print all dashboard tile text keys found
    final dashboardTileTextKeys = [
      'dashboard_tile_text_animals',
      'dashboard_tile_text_logs',
      'dashboard_tile_text_add_partner',
      'dashboard_tile_text_farm_dashboard',
      'dashboard_tile_text_admin_logs',
      'dashboard_tile_text_breed_management',
      'dashboard_tile_text_user_management',
      'dashboard_tile_text_admin_override',
      'dashboard_tile_text_animal_search_&_export',
      'dashboard_tile_text_log_search_&_export',
      'dashboard_tile_text_logout',
    ];
    for (final key in dashboardTileTextKeys) {
      final count = find.byKey(Key(key)).evaluate().length;
      // ignore: avoid_print
      print('DEBUG: Found $count widgets with key $key');
    }
    // Print all tile labels for further debugging
    final allTextWidgets = find.byType(Text).evaluate().toList();
    for (final w in allTextWidgets) {
      final widget = w.widget;
      if (widget is Text) {
        // ignore: avoid_print
        print('DEBUG: Text widget: "${widget.data}"');
      }
    }
    // Use key-based finder for dashboard tile (e.g., 'dashboard_farm_dashboard_tile')
    expect(find.byKey(const Key('dashboard_farm_dashboard_tile')), findsOneWidget);
    // Use key-based finder for Animals and Logs tile text to avoid duplicate text error
    expect(find.byKey(const Key('dashboard_tile_text_animals')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_tile_text_logs')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_tile_text_add_partner')), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });
}
