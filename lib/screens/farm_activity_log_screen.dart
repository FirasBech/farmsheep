import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../features/log/presentation/providers/log_provider.dart';
import '../core/utils/l10n_extension.dart';

class FarmActivityLogScreen extends ConsumerWidget {
  const FarmActivityLogScreen({super.key});

  IconData _iconForAction(String action) {
    switch (action.toLowerCase()) {
      case 'added':
        return Icons.add_circle_outline;
      case 'deleted':
        return Icons.delete_outline;
      case 'edited':
        return Icons.edit_outlined;
      case 'override':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.history;
    }
  }

  Color _colorForAction(String action) {
    switch (action.toLowerCase()) {
      case 'added':
        return const Color(0xFF2E7D32);
      case 'deleted':
        return Colors.red;
      case 'edited':
        return Colors.orange;
      case 'override':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dt) {
    final d = dt.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final farmId = ref.watch(farmNotifierProvider).selectedFarm?.id;
    if (farmId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.farmActivityLogTitle)),
        body: Center(child: Text(l10n.noFarmSelected)),
      );
    }
    final logsAsync = ref.watch(activityLogsStreamProvider(farmId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.farmActivityLogTitle)),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorSaving(e.toString()))),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.history,
                        size: 64, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.noActivityYet,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(l10n.farmActionsWillAppear,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          )),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, i) {
              final log = logs[i];
              final actionColor = _colorForAction(log.action);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: actionColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_iconForAction(log.action),
                            color: actionColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${log.action} ${log.entity} #${log.entityId}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (log.details.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(log.details,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7))),
                            ],
                            const SizedBox(height: 4),
                            Text(_formatTime(log.timestamp),
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text(
                        log.performedBy.length > 8
                            ? '${log.performedBy.substring(0, 8)}…'
                            : log.performedBy,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
