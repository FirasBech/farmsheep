import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rv;
import 'package:firebase_auth/firebase_auth.dart';
import 'l10n/app_localizations.dart';
import 'core/providers/locale_provider.dart';
import 'config.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/offline_sync_service.dart';
import 'providers/connectivity_provider.dart';
import 'widgets/auth_wrapper.dart';
import 'widgets/connectivity_banner.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/animal_list_screen.dart';
import 'screens/animal_detail_screen.dart';
import 'screens/add_animal_screen.dart';
import 'screens/edit_animal_screen.dart';
import 'screens/log_history_screen.dart';
import 'screens/admin_activity_log_screen.dart';
import 'screens/add_manual_log_screen.dart';
import 'screens/add_partner_screen.dart';
import 'screens/farm_list_screen.dart';
import 'screens/farm_dashboard_screen.dart';
import 'screens/farm_settings_screen.dart';
import 'screens/farm_activity_log_screen.dart';
import 'screens/breed_management_screen.dart';
import 'screens/user_management_screen.dart';
import 'screens/admin_override_screen.dart';
import 'screens/animal_search_export_screen.dart';
import 'screens/log_search_export_screen.dart';
import 'screens/partners_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/archived_farms_screen.dart';
import 'models/animal.dart';

// Public so widgets/connectivity_banner.dart can reference it in tests.
bool skipFirebaseGlobal = false;

/// App entry point. Set skipFirebase to true to bypass Firebase init (e.g., in integration tests).
Future<void> main({
  bool skipFirebase = false,
  AuthService? authService,
  DatabaseService? databaseService,
  ConnectivityStatus? connectivityStatus,
  OfflineSyncService? offlineSyncService,
  NotificationService? notificationService,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  skipFirebaseGlobal = skipFirebase;
  if (skipFirebase) {
    NotificationService.disableForTests();
  }
  if (!skipFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    try {
      final snap = await FirebaseFirestore.instance
          .collection('config')
          .doc('server')
          .get();
      final url = snap.data()?['url'] as String?;
      if (url != null && url.isNotEmpty) kServerUrl = url;
    } catch (_) {
      // keep the compile-time fallback
    }
  }
  if (notificationService == null) {
    await NotificationService.init();
  }
  final authService0 = authService ?? AuthService();
  final databaseService0 = databaseService ?? DatabaseService();
  final offlineSyncService0 = offlineSyncService ??
      (skipFirebase ? FakeOfflineSyncService() : OfflineSyncService());
  final container = rv.ProviderContainer();
  await container.read(localeProvider.notifier).load();
  runApp(rv.UncontrolledProviderScope(
    container: container,
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => offlineSyncService0),
      ],
      child: MyApp(
        authService: authService0,
        databaseService: databaseService0,
        connectivityStatus: connectivityStatus,
      ),
    ),
  ));
}

class MyApp extends rv.ConsumerWidget {
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
  Widget build(BuildContext context, rv.WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<DatabaseService>.value(value: databaseService),
        ChangeNotifierProvider<ConnectivityStatus>(
            create: (_) => connectivityStatus ?? ConnectivityStatus()),
      ],
      child: StreamProvider<User?>.value(
        value: authService.authStateChanges,
        initialData: null,
        child: MaterialApp(
          title: 'FarmSheep',
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2E7D32),
              brightness: Brightness.light,
              primary: const Color(0xFF2E7D32),
              onPrimary: Colors.white,
              primaryContainer: const Color(0xFFA5D6A7),
              onPrimaryContainer: const Color(0xFF1B5E20),
              secondary: const Color(0xFF558B2F),
              onSecondary: Colors.white,
              secondaryContainer: const Color(0xFFDCEDC8),
              tertiary: const Color(0xFF795548),
              onTertiary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1B5E20),
            ),
            scaffoldBackgroundColor: const Color(0xFFF1F8E9),
            useMaterial3: true,
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
              ),
              iconTheme: IconThemeData(color: Colors.white),
              actionsIconTheme: IconThemeData(color: Colors.white),
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.zero,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF9FBF7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFA5D6A7)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFA5D6A7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFC62828)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFC62828), width: 2),
              ),
              labelStyle: const TextStyle(color: Color(0xFF558B2F)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIconColor: const Color(0xFF558B2F),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(color: Color(0xFF2E7D32)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            listTileTheme: const ListTileThemeData(
              iconColor: Color(0xFF2E7D32),
            ),
            dividerTheme: const DividerThemeData(
              color: Color(0xFFDCEDC8),
              thickness: 1,
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: const Color(0xFF1B5E20),
              contentTextStyle: const TextStyle(color: Colors.white),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              behavior: SnackBarBehavior.floating,
            ),
            chipTheme: ChipThemeData(
              backgroundColor: const Color(0xFFDCEDC8),
              selectedColor: const Color(0xFF2E7D32),
              labelStyle: const TextStyle(color: Color(0xFF1B5E20)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          darkTheme: ThemeData.dark(),
          routes: {
            '/': (context) => const ConnectivityBanner(child: AuthWrapper()),
            '/home': (context) =>
                const ConnectivityBanner(child: HomeScreen()),
            '/animals': (context) => const AnimalListScreen(),
            '/animalDetail': (context) => const AnimalDetailScreen(),
            '/addAnimal': (context) => const AddAnimalScreen(),
            '/editAnimal': (context) => EditAnimalScreen(
                animal:
                    ModalRoute.of(context)!.settings.arguments as Animal),
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
            '/animalSearchExport': (context) =>
                const AnimalSearchExportScreen(),
            '/logSearchExport': (context) => const LogSearchExportScreen(),
            '/partners': (context) => const PartnersScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/login': (context) => const LoginScreen(),
            '/archivedFarms': (context) => const ArchivedFarmsScreen(),
          },
        ),
      ),
    );
  }
}
