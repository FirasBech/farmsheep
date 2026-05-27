import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../features/animal/presentation/providers/animals_provider.dart';
import '../features/log/presentation/providers/log_provider.dart';
import '../features/ai/presentation/providers/ai_notifier.dart';
import '../services/auth_service.dart';
import '../core/utils/l10n_extension.dart';

class FarmDashboardScreen extends ConsumerWidget {
  const FarmDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final farm = ref.watch(farmNotifierProvider).selectedFarm;
    if (farm == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.farmDashboardTitle)),
        body: Center(child: Text(l10n.noFarmSelected)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.farmDashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.farmSettingsTooltip,
            onPressed: () => Navigator.pushNamed(context, '/farmSettings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(farm.name,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(farm.address,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    )),
            if (farm.notes != null && farm.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(farm.notes!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      )),
            ],
            const SizedBox(height: 20),

            _AiHerdSummaryCard(farmId: farm.id),

            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _DashboardTile(
                  icon: Icons.pets,
                  label: l10n.tileAnimals,
                  onTap: () => Navigator.pushNamed(context, '/animals'),
                ),
                _DashboardTile(
                  icon: Icons.people,
                  label: l10n.statPartners,
                  onTap: () => Navigator.pushNamed(context, '/partners'),
                ),
                _DashboardTile(
                  icon: Icons.list_alt,
                  label: l10n.tileLogs,
                  onTap: () => Navigator.pushNamed(context, '/logs'),
                ),
                _DashboardTile(
                  icon: Icons.history,
                  label: l10n.tileFarmActivity,
                  onTap: () =>
                      Navigator.pushNamed(context, '/farmActivityLog'),
                ),
                _DashboardTile(
                  icon: Icons.account_circle,
                  label: l10n.tileProfileUsers,
                  onTap: () async {
                    final authService =
                        p.Provider.of<AuthService>(context, listen: false);
                    final role = await authService.getUserRole();
                    if (context.mounted) {
                      if (role == 'admin') {
                        Navigator.pushNamed(context, '/userManagement');
                      } else {
                        Navigator.pushNamed(context, '/profile');
                      }
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

class _AiHerdSummaryCard extends ConsumerWidget {
  final String farmId;
  const _AiHerdSummaryCard({required this.farmId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiNotifierProvider);
    final farm = ref.watch(farmNotifierProvider).selectedFarm;

    return Card(
      color: const Color(0xFFE8F5E9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFA5D6A7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome,
                    color: Color(0xFF2E7D32), size: 20),
                const SizedBox(width: 8),
                Text(
                  context.l10n.aiHerdSummaryTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B5E20),
                      ),
                ),
                const Spacer(),
                if (aiState.summaryGeneratedAt != null)
                  Text(
                    'Updated ${_timeAgo(aiState.summaryGeneratedAt!)}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF388E3C)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (aiState.summaryLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (aiState.summaryError != null)
              Text('Error: ${aiState.summaryError}',
                  style: const TextStyle(color: Colors.red, fontSize: 13))
            else if (aiState.herdSummary != null)
              Text(aiState.herdSummary!,
                  style: const TextStyle(fontSize: 14, height: 1.5))
            else
              Text(
                context.l10n.aiHerdSummaryGenerateTap,
                style: const TextStyle(fontSize: 13, color: Color(0xFF388E3C)),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text(aiState.summaryLoading
                    ? context.l10n.generatingLabel
                    : aiState.herdSummary != null
                        ? context.l10n.refreshSummaryButton
                        : context.l10n.generateAiSummaryButton),
                onPressed: aiState.summaryLoading || farm == null
                    ? null
                    : () async {
                        final animals = await ref
                            .read(animalsStreamProvider(farmId).future);
                        final logs = await ref
                            .read(logsStreamProvider(farmId).future);
                        await ref
                            .read(aiNotifierProvider.notifier)
                            .refreshHerdSummary(
                              farm: farm,
                              animals: animals,
                              recentLogs: logs,
                            );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA5D6A7)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
