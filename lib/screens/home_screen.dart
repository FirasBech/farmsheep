import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;
import '../services/auth_service.dart';
import '../features/notification/presentation/providers/notification_notifier.dart';
import '../services/database_service.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../core/utils/l10n_extension.dart';

// Add keys for robust test targeting
class HomeScreen extends ConsumerStatefulWidget {
  static const Key animalsTileKey = Key('dashboard_animals_tile');
  static const Key logsTileKey = Key('dashboard_logs_tile');
  static const Key addPartnerTileKey = Key('dashboard_add_partner_tile');
  static const Key adminLogsTileKey = Key('dashboard_admin_logs_tile');
  static const Key logoutTileKey = Key('dashboard_logout_tile');
  static const Key dashboardTitleKey = Key('dashboard_title');

  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load farms and role into Riverpod providers
    final userId = p.Provider.of<AuthService>(context, listen: false)
        .currentUser
        ?.uid;
    if (userId != null) {
      ref.read(farmNotifierProvider.notifier).loadFarms(userId);
    } else {
      // No authenticated user — go back to login.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      });
    }
    if (!ref.read(authNotifierProvider).roleLoaded) {
      ref.read(authNotifierProvider.notifier).loadRole();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = context.l10n;
      ref.read(notificationNotifierProvider.notifier).show(
        title: l10n.welcomeNotificationTitle,
        body: l10n.welcomeNotificationBody,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final farmState = ref.watch(farmNotifierProvider);

    // Show spinner while loading farms from Firestore (including initial cold start).
    if (farmState.loading || !farmState.initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final l10n = context.l10n;
    final role = ref.watch(authNotifierProvider).role;
    final isWide = MediaQuery.of(context).size.width > 600;
    final authService = p.Provider.of<AuthService>(context, listen: false);
    final farms = farmState.activeFarms;
    final farm = farmState.selectedFarm;
    final db = p.Provider.of<DatabaseService>(context, listen: false);

    // If user has no farms, redirect to farm list
    if (farms.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/farms');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Build the list of tiles
    final List<_Tile> tiles = [
      _Tile(
          tileKey: HomeScreen.animalsTileKey,
          label: l10n.tileAnimals,
          icon: Icons.pets,
          route: '/animals'),
      _Tile(
          tileKey: const Key('dashboard_farm_dashboard_tile'),
          label: l10n.tileFarmDashboard,
          icon: Icons.dashboard,
          route: '/farmDashboard'),
      _Tile(
          tileKey: HomeScreen.logsTileKey,
          label: l10n.tileLogs,
          icon: Icons.list_alt,
          route: '/logs'),
      if (role == 'admin')
        _Tile(
            tileKey: const Key('dashboard_breed_management_tile'),
            label: l10n.tileBreedManagement,
            icon: Icons.category,
            route: '/breedManagement'),
    ];
    if (role == 'admin') {
      tiles.addAll([
        _Tile(
            tileKey: HomeScreen.addPartnerTileKey,
            label: l10n.tileAddPartner,
            icon: Icons.person_add,
            route: '/addPartner'),
        _Tile(
            tileKey: HomeScreen.adminLogsTileKey,
            label: l10n.tileAdminLogs,
            icon: Icons.admin_panel_settings,
            route: '/adminLogs'),
        _Tile(
            tileKey: const Key('dashboard_user_management_tile'),
            label: l10n.tileUserManagement,
            icon: Icons.supervisor_account,
            route: '/userManagement'),
        _Tile(
            tileKey: const Key('dashboard_admin_override_tile'),
            label: l10n.tileAdminOverride,
            icon: Icons.edit,
            route: '/adminOverride'),
      ]);
    }
    tiles.addAll([
      _Tile(
          tileKey: const Key('dashboard_animal_search_export_tile'),
          label: l10n.tileAnimalSearchExport,
          icon: Icons.search,
          route: '/animalSearchExport'),
      _Tile(
          tileKey: const Key('dashboard_log_search_export_tile'),
          label: l10n.tileLogSearchExport,
          icon: Icons.file_download,
          route: '/logSearchExport'),
      _Tile(
        tileKey: HomeScreen.logoutTileKey,
        label: l10n.tileLogout,
        icon: Icons.logout,
        action: () async {
          await authService.signOut();
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
    ]);
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      appBar: AppBar(
        key: HomeScreen.dashboardTitleKey,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (farm != null)
              Text(farm.name,
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: l10n.notificationsTooltip,
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outlined),
            tooltip: l10n.profileTooltip,
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats row on green background
          if (farm != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: FutureBuilder<List<int>>(
                future: Future.wait([
                  db.streamAnimals(farmId: farm.id).first.then((a) => a.length),
                  db.getPartnersForFarm(farm.id).then((p) => p.length),
                  db.streamManualLogs(farmId: farm.id).first.then((l) => l.length),
                ]),
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? [-1, -1, -1];
                  return Row(
                    children: [
                      _StatTile(icon: Icons.pets, label: l10n.statAnimals,
                          value: stats[0] < 0 ? '—' : stats[0].toString()),
                      const SizedBox(width: 12),
                      _StatTile(icon: Icons.people, label: l10n.statPartners,
                          value: stats[1] < 0 ? '—' : stats[1].toString()),
                      const SizedBox(width: 12),
                      _StatTile(icon: Icons.list_alt, label: l10n.statLogs,
                          value: stats[2] < 0 ? '—' : stats[2].toString()),
                    ],
                  );
                },
              ),
            ),
          // Main content on light background
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF1F8E9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isWide ? 24 : 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _DashboardGrid(tiles: tiles, isWide: isWide),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.notifications_active,
                              color: Color(0xFF2E7D32), size: 22),
                        ),
                        title: Text(l10n.alertsNotificationsTitle,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: Text(l10n.alertsNotificationsSubtitle,
                            style: const TextStyle(fontSize: 13)),
                        trailing: const Icon(Icons.chevron_right,
                            color: Color(0xFF2E7D32)),
                        onTap: () =>
                            Navigator.pushNamed(context, '/notifications'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardGrid extends ConsumerWidget {
  const _DashboardGrid({
    required this.tiles,
    required this.isWide,
  });

  final List<_Tile> tiles;
  final bool isWide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authNotifierProvider).role;
    return Semantics(
      label: 'Dashboard actions',
      child: FocusTraversalGroup(
        child: KeyedSubtree(
          key: ValueKey('dashboard_grid_${role ?? "none"}'),
          child: GridView.count(
            crossAxisCount: isWide ? 3 : 2,
            crossAxisSpacing: isWide ? 32 : 16,
            mainAxisSpacing: isWide ? 32 : 16,
            childAspectRatio: isWide ? 1.1 : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: tiles,
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? route;
  final VoidCallback? action;
  final Key? tileKey;
  const _Tile(
      {this.tileKey,
      required this.label,
      required this.icon,
      this.route,
      this.action});

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        button: true,
        child: Tooltip(
          message: label,
          child: Focus(
            canRequestFocus: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: action ?? () => Navigator.pushNamed(context, route!),
              child: Card(
                key: tileKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(icon,
                            size: 28, color: const Color(0xFF2E7D32)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        label,
                        key: Key(
                            'dashboard_tile_text_${label.replaceAll(' ', '_').toLowerCase()}'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B5E20),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
