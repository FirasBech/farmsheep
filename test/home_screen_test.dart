import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rv;
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
import 'package:sheepfarm/services/notification_service.dart';
import 'package:sheepfarm/features/farm/presentation/providers/farm_notifier.dart';
import 'package:sheepfarm/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sheepfarm/features/notification/presentation/providers/notification_notifier.dart';

void _initTestEnv() {
  NotificationService.skipInitForTests = true;
}

class FakeUserProvider extends ChangeNotifier implements UserProvider {
  @override
  String get role => 'admin';
  @override
  bool get isInitialized => true;
  @override
  Future<void> loadUserRole() async {}
  @override
  String get displayName => 'Test User';
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
  @override
  String get uid => 'test-uid';
}

class FakeDatabaseService extends Fake implements DatabaseService {
  @override
  Stream<List<Animal>> streamAnimals({required String farmId}) =>
      Stream.value([
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
}

class TestFarmProvider extends ChangeNotifier implements FarmProvider {
  static final _farm = Farm(
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
  Farm? get selectedFarm => _farm;
  @override
  List<Farm> get farms => [_farm];
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

// Riverpod fake notifiers ──────────────────────────────────────────────────────

class _FakeFarmNotifier extends FarmNotifier {
  @override
  FarmState build() => FarmState(
        farms: [TestFarmProvider._farm],
        selectedFarm: TestFarmProvider._farm,
      );

  @override
  Future<void> loadFarms(String userId) async {}
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(role: 'admin', roleLoaded: true);

  @override
  Future<void> loadRole() async {}
}

class _FakeNotificationNotifier extends NotificationNotifier {
  @override
  NotificationState build() => const NotificationState(
        notificationsEnabled: false,
        dailySummary: false,
        scheduled: [],
        loaded: true,
      );

  @override
  Future<void> show({required String title, required String body}) async {}
}

void main() {
  _initTestEnv();
  testWidgets('HomeScreen shows dashboard and admin tiles',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      rv.ProviderScope(
        overrides: [
          farmNotifierProvider.overrideWith(() => _FakeFarmNotifier()),
          authNotifierProvider.overrideWith(() => _FakeAuthNotifier()),
          notificationNotifierProvider
              .overrideWith(() => _FakeNotificationNotifier()),
        ],
        child: MultiProvider(
          providers: [
            Provider<AuthService>.value(value: FakeAuthService()),
            Provider<DatabaseService>.value(value: FakeDatabaseService()),
            ChangeNotifierProvider<UserProvider>.value(
                value: FakeUserProvider()),
            ChangeNotifierProvider<FarmProvider>.value(
                value: TestFarmProvider()),
            ChangeNotifierProvider<OfflineSyncService>.value(
                value: FakeOfflineSyncService()),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
            onGenerateRoute: (settings) {
              if (settings.name == '/farms') {
                return MaterialPageRoute(
                    builder: (_) =>
                        const Scaffold(body: Text('Farms Page')));
              }
              return null;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
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
    final allTextWidgets = find.byType(Text).evaluate().toList();
    for (final w in allTextWidgets) {
      final widget = w.widget;
      if (widget is Text) {
        // ignore: avoid_print
        print('DEBUG: Text widget: "${widget.data}"');
      }
    }
    expect(
        find.byKey(const Key('dashboard_farm_dashboard_tile')), findsOneWidget);
    expect(
        find.byKey(const Key('dashboard_tile_text_animals')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_tile_text_logs')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_tile_text_add_partner')),
        findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });
}
