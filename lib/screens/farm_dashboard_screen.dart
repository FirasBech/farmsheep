import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../services/auth_service.dart';

class FarmDashboardScreen extends StatelessWidget {
  const FarmDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farmProv = Provider.of<FarmProvider>(context);
    final farm = farmProv.selectedFarm;
    if (farm == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Farm Dashboard')),
        body: const Center(child: Text('No farm selected.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Farm Settings',
            onPressed: () => Navigator.pushNamed(context, '/farmSettings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(farm.name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(farm.address, style: Theme.of(context).textTheme.bodyLarge),
            if (farm.notes != null && farm.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${farm.notes}', style: const TextStyle(fontSize: 16)),
            ],
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _DashboardTile(
                  icon: Icons.pets,
                  label: 'Animals',
                  onTap: () => Navigator.pushNamed(context, '/animals'),
                ),
                _DashboardTile(
                  icon: Icons.people,
                  label: 'Partners',
                  onTap: () => Navigator.pushNamed(context, '/partners'),
                ),
                _DashboardTile(
                  icon: Icons.list_alt,
                  label: 'Logs',
                  onTap: () => Navigator.pushNamed(context, '/logs'),
                ),
                _DashboardTile(
                  icon: Icons.history,
                  label: 'Farm Activity',
                  onTap: () => Navigator.pushNamed(context, '/farmActivityLog'),
                ),
                _DashboardTile(
                  icon: Icons.account_circle,
                  label: 'Profile / Users',
                  onTap: () async {
                    final authService =
                        Provider.of<AuthService>(context, listen: false);
                    final role = await authService.getUserRole();
                    if (role == 'admin') {
                      Navigator.pushNamed(context, '/userManagement');
                    } else {
                      Navigator.pushNamed(context, '/profile');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DashboardTile(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
