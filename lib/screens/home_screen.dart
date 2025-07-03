import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../providers/farm_provider.dart';
import '../widgets/connectivity_banner.dart';
import '../services/notification_service.dart';
import '../services/database_service.dart';
import 'notifications_screen.dart';

// Add keys for robust test targeting
class HomeScreen extends StatefulWidget {
  static const Key animalsTileKey = Key('dashboard_animals_tile');
  static const Key logsTileKey = Key('dashboard_logs_tile');
  static const Key addPartnerTileKey = Key('dashboard_add_partner_tile');
  static const Key adminLogsTileKey = Key('dashboard_admin_logs_tile');
  static const Key logoutTileKey = Key('dashboard_logout_tile');
  static const Key dashboardTitleKey = Key('dashboard_title');

  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).loadUserRole();
    // Demo: Show a notification on dashboard open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.showNotification(
        title: 'Welcome',
        body: 'Check your animals and logs for today!',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: HomeScreen build called');
    final userProv = Provider.of<UserProvider>(context);
    final role = userProv.role;
    final isWide = MediaQuery.of(context).size.width > 600;
    final authService = Provider.of<AuthService>(context, listen: false);
    final farmProv = Provider.of<FarmProvider>(context);
    final farms = farmProv.farms;
    final db = Provider.of<DatabaseService>(context, listen: false);
    final farm = farmProv.selectedFarm;
    // If user has no farms, force to farm list
    if (farms.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/farms');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Build the list of tiles
    final List<_Tile> tiles = [
      const _Tile(
          tileKey: HomeScreen.animalsTileKey,
          label: 'Animals',
          icon: Icons.pets,
          route: '/animals'),
      const _Tile(
          tileKey: Key('dashboard_farm_dashboard_tile'),
          label: 'Farm Dashboard',
          icon: Icons.dashboard,
          route: '/farmDashboard'),
      const _Tile(
          tileKey: HomeScreen.logsTileKey,
          label: 'Logs',
          icon: Icons.list_alt,
          route: '/logs'),
      if (role == 'admin')
        const _Tile(
            tileKey: Key('dashboard_breed_management_tile'),
            label: 'Breed Management',
            icon: Icons.category,
            route: '/breedManagement'),
    ];
    if (role == 'admin') {
      tiles.addAll([
        const _Tile(
            tileKey: HomeScreen.addPartnerTileKey,
            label: 'Add Partner',
            icon: Icons.person_add,
            route: '/addPartner'),
        const _Tile(
            tileKey: HomeScreen.adminLogsTileKey,
            label: 'Admin Logs',
            icon: Icons.admin_panel_settings,
            route: '/adminLogs'),
        const _Tile(
            tileKey: Key('dashboard_user_management_tile'),
            label: 'User Management',
            icon: Icons.supervisor_account,
            route: '/userManagement'),
        const _Tile(
            tileKey: Key('dashboard_admin_override_tile'),
            label: 'Admin Override',
            icon: Icons.edit,
            route: '/adminOverride'),
      ]);
    }
    tiles.addAll([
      const _Tile(
          tileKey: Key('dashboard_animal_search_export_tile'),
          label: 'Animal Search & Export',
          icon: Icons.search,
          route: '/animalSearchExport'),
      const _Tile(
          tileKey: Key('dashboard_log_search_export_tile'),
          label: 'Log Search & Export',
          icon: Icons.file_download,
          route: '/logSearchExport'),
      _Tile(
        tileKey: HomeScreen.logoutTileKey,
        label: 'Logout',
        icon: Icons.logout,
        action: () async {
          await authService.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
    ]);
    print('DEBUG: HomeScreen tile keys: ${tiles.map((t) => t.tileKey.toString()).join(', ')}');
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.waving_hand, color: Colors.amber, size: 32),
            const SizedBox(width: 12),
            const Text('Welcome, ', style: TextStyle(fontSize: 26)),
            Text(
              Provider.of<UserProvider>(context).displayName ?? 'Farmer',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ],
        ),
        actions: const [
          // ...existing code...
        ],
      ),
      body: Column(
        children: [
          ConnectivityBanner(
            child: Container(), // Placeholder, replace with actual child
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isWide ? 32 : 16),
              child: _DashboardGrid(tiles: tiles, isWide: isWide),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.amber[50],
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Icon(Icons.waving_hand, color: Colors.amber, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Welcome, ${Provider.of<UserProvider>(context).displayName ?? 'Farmer'}! Here are your latest stats:',
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Advanced dashboard UI: Stat tiles with live data
          if (farm != null)
            FutureBuilder<List<int>>(
              future: Future.wait([
                db.streamAnimals(farmId: farm.id).first.then((a) => a.length),
                db.getPartnersForFarm(farm.id).then((p) => p.length),
                db
                    .streamManualLogs(farmId: farm.id)
                    .first
                    .then((l) => l.length),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatTile(
                          icon: Icons.pets, label: 'Animals', value: '...'),
                      _StatTile(
                          icon: Icons.people, label: 'Partners', value: '...'),
                      _StatTile(
                          icon: Icons.list_alt, label: 'Logs', value: '...'),
                    ],
                  );
                }
                final stats = snapshot.data!;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatTile(
                        icon: Icons.pets,
                        label: 'Animals',
                        value: stats[0].toString()),
                    _StatTile(
                        icon: Icons.people,
                        label: 'Partners',
                        value: stats[1].toString()),
                    _StatTile(
                        icon: Icons.list_alt,
                        label: 'Logs',
                        value: stats[2].toString()),
                  ],
                );
              },
            ),
          const SizedBox(height: 16),
          // Customizable dashboard tile for alerts/notifications
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              color: Colors.blue[50],
              elevation: 0,
              child: ListTile(
                leading: const Icon(Icons.notifications_active,
                    color: Colors.blue, size: 32),
                title: const Text('Alerts & Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle:
                    const Text('Tap to view or manage your farm notifications.'),
                onTap: () => Navigator.pushNamed(context, '/notifications'),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid({
    required this.tiles,
    required this.isWide,
  });

  final List<_Tile> tiles;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final role = userProv.role;
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
        label: label, // Semantics label for a11y and test
        button: true,
        child: Tooltip(
          message: label,
          child: Focus(
            canRequestFocus: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: action ??
                  () {
                    Navigator.pushNamed(context, route!);
                  },
              child: Card(
                key: tileKey, // Attach key to Card for test targeting
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon,
                          size: 56,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(label,
                          key: Key('dashboard_tile_text_${label.replaceAll(' ', '_').toLowerCase()}'),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
