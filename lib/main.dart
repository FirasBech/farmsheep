import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'providers/user_provider.dart';
import 'services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/auth_wrapper.dart';
import 'screens/animal_list_screen.dart';
import 'screens/animal_detail_screen.dart';
import 'screens/add_animal_screen.dart';
import 'screens/log_history_screen.dart';
import 'screens/admin_activity_log_screen.dart';
import 'screens/add_manual_log_screen.dart';
import 'screens/add_partner_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/farm_provider.dart';
import 'screens/farm_list_screen.dart';
import 'screens/farm_dashboard_screen.dart';
import 'screens/farm_settings_screen.dart';
import 'screens/farm_activity_log_screen.dart';
import 'screens/breed_management_screen.dart';
import 'screens/user_management_screen.dart';
import 'screens/admin_override_screen.dart';
import 'services/offline_sync_service.dart';
import 'screens/animal_search_export_screen.dart';
import 'screens/log_search_export_screen.dart';
import 'services/notification_service.dart';
import 'screens/partners_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/edit_animal_screen.dart';
import 'models/animal.dart';

// Global flag to indicate Firebase initialization skip
bool _skipFirebaseGlobal = false;

/// App entry point. Set skipFirebase to true to bypass Firebase init (e.g., in integration tests).
Future<void> main({
  bool skipFirebase = false,
  AuthService? authService,
  DatabaseService? databaseService,
  ConnectivityStatus?
      connectivityStatus, // allow injecting connectivity for tests
  OfflineSyncService?
      offlineSyncService, // allow injecting offline sync for tests
  NotificationService?
      notificationService, // allow injecting notification service for tests
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  _skipFirebaseGlobal = skipFirebase;
  if (!skipFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kIsWeb) {
      await FirebaseFirestore.instance.enablePersistence();
    }
  }  // Only call NotificationService.init() if not injecting a mock
  if (notificationService == null) {
    await NotificationService.init();
  }
  final authService0 = authService ?? AuthService();
  final databaseService0 = databaseService ?? DatabaseService();
  final offlineSyncService0 = offlineSyncService ?? 
    (skipFirebase ? FakeOfflineSyncService() : OfflineSyncService());
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (_) => UserProvider(authService: authService0)),
      ChangeNotifierProvider(
          create: (_) =>
              FarmProvider(db: databaseService0, auth: authService0)),
      ChangeNotifierProvider(create: (_) => offlineSyncService0),
    ],
    child: MyApp(
      authService: authService0,
      databaseService: databaseService0,
      connectivityStatus: connectivityStatus,
    ),
  ));
}

class ConnectivityStatus extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityStatus() {
    Connectivity().onConnectivityChanged.listen((result) {
      final online = result != ConnectivityResult.none;
      if (online != _isOnline) {
        _isOnline = online;
        notifyListeners();
      }
    });
  }

// For testing only
  void setOnlineForTest(bool value) {
    assert(() {
      _isOnline = value;
      notifyListeners();
      return true;
    }());
  }

  // ...existing code...
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final DatabaseService databaseService;
  final ConnectivityStatus? connectivityStatus;
  const MyApp({
    super.key,
    required this.authService,
    required this.databaseService,
    this.connectivityStatus,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider(
            create: (_) => UserProvider(authService: authService)),
        Provider<DatabaseService>.value(value: databaseService),
        ChangeNotifierProvider<ConnectivityStatus>(
            create: (_) => connectivityStatus ?? ConnectivityStatus()),
        ChangeNotifierProvider(
            create: (_) =>
                FarmProvider(db: databaseService, auth: authService)),
      ],
      child: StreamProvider<User?>.value(
        value: authService.authStateChanges,
        initialData: null,
        child: MaterialApp(
          title: 'SheepFarm',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: Brightness.light,
              primary: const Color(0xFF388E3C),
              secondary: const Color(0xFF8BC34A),
              background: const Color(0xFFF5F5F5),
              surface: Colors.white,
              onPrimary: Colors.white,
              onSecondary: Colors.black,
              onBackground: Colors.black,
              onSurface: Colors.black,
            ),
            fontFamily: 'Roboto',
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF388E3C),
              foregroundColor: Colors.white,
              elevation: 1,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            cardTheme: CardTheme(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            buttonTheme: ButtonThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          darkTheme: ThemeData.dark(),
          // home: ConnectivityBanner(child: AuthWrapper()),
          routes: {
            '/': (context) => const ConnectivityBanner(child: AuthWrapper()),
            '/home': (context) => const ConnectivityBanner(child: HomeScreen()),
            '/animals': (context) => const AnimalListScreen(),
            '/animalDetail': (context) => const AnimalDetailScreen(),
            '/addAnimal': (context) => const AddAnimalScreen(),
            '/editAnimal': (context) => EditAnimalScreen(
                animal: ModalRoute.of(context)!.settings.arguments as Animal),
            '/logs': (context) => const LogHistoryScreen(),
            '/adminLogs': (context) => const AdminActivityLogScreen(),
            '/addManualLog': (context) => const AddManualLogScreen(),
            '/addPartner': (context) => const AddPartnerScreen(),
            '/register': (context) => const RegisterScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/farms': (context) => const FarmListScreen(),
            '/farmDashboard': (context) => const FarmDashboardScreen(),
            '/farmSettings': (context) => const FarmSettingsScreen(),
            '/farmActivityLog': (context) => const FarmActivityLogScreen(),
            '/breedManagement': (context) => const BreedManagementScreen(),
            '/userManagement': (context) => const UserManagementScreen(),
            '/adminOverride': (context) => const AdminOverrideScreen(),
            '/animalSearchExport': (context) => const AnimalSearchExportScreen(),
            '/logSearchExport': (context) => const LogSearchExportScreen(),
            '/partners': (context) => const PartnersScreen(),
            '/notifications': (context) => const NotificationsScreen(),
          },
        ),
      ),
    );
  }
}

class SyncStatusIndicator extends StatefulWidget {
  const SyncStatusIndicator({super.key});
  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  bool _hasPendingWrites = false;
  bool _isOnline = true;
  late final FirebaseFirestore _db;
  @override
  void initState() {
    super.initState();
    if (_skipFirebaseGlobal) return; // Skip entire setup when skipFirebase
    if (Firebase.apps.isEmpty) return; // Skip Firestore setup when skipped
    _db = FirebaseFirestore.instance;
    _db.snapshotsInSync().listen((_) async {
      final snap = await _db.collection('users').limit(1).get();
      setState(() {
        _hasPendingWrites = snap.metadata.hasPendingWrites;
      });
    });
    // Listen to connectivity
    final status = context.read<ConnectivityStatus>();
    _isOnline = status.isOnline;
    status.addListener(() {
      setState(() {
        _isOnline = status.isOnline;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_skipFirebaseGlobal) return const SizedBox.shrink();
    if (Firebase.apps.isEmpty) return const SizedBox.shrink();
    if (!_isOnline) return const SizedBox.shrink();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _hasPendingWrites
          ? Tooltip(
              message: 'Syncing changes to cloud',
              child: Semantics(
                label: 'Syncing changes',
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              ),
            )
          : Tooltip(
              message: 'All changes synced',
              child: Semantics(
                label: 'All changes synced',
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.cloud_done, color: Colors.green, size: 28),
                ),
              ),
            ),
    );
  }
}

class ConnectivityBanner extends StatelessWidget {
  final Widget child;
  const ConnectivityBanner({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityStatus>().isOnline;
    return Stack(
      children: [
        child,
        const Positioned(
          top: 0,
          right: 0,
          child: SyncStatusIndicator(),
        ),
        if (!isOnline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FocusableActionDetector(
              autofocus: true,
              child: Semantics(
                label:
                    'Offline banner. You are offline. Changes will sync when online.',
                liveRegion: true,
                child: Tooltip(
                  message: 'Offline. Changes will sync when online.',
                  child: Material(
                    color: Colors.red.shade700,
                    child: SafeArea(
                      child: Container(
                        key: const Key('offline_banner'),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'You are offline. Changes will sync when online.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
