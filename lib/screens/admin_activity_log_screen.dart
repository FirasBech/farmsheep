import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../features/log/presentation/providers/log_provider.dart';
import '../core/utils/l10n_extension.dart';

class AdminActivityLogScreen extends ConsumerWidget {
  const AdminActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final authState = ref.watch(authNotifierProvider);
    if (!authState.roleLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.activityLogsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (authState.role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.activityLogsTitle)),
        body: Center(
            child: Text(l10n.accessDenied, style: const TextStyle(fontSize: 18))),
      );
    }
    final farmId = ref.watch(farmNotifierProvider).selectedFarm?.id;
    if (farmId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.activityLogsTitle)),
        body: Center(child: Text(l10n.noFarmSelected)),
      );
    }
    final logsAsync = ref.watch(activityLogsStreamProvider(farmId));
    return Scaffold(
      appBar: AppBar(
          title: Text(l10n.activityLogsTitle,
              key: const Key('admin_logs_screen_title'),
              style: const TextStyle(fontWeight: FontWeight.bold))),
      body: logsAsync.when(
        loading: () => Center(
          child: Semantics(
            label: 'Loading admin activity logs',
            child: const CircularProgressIndicator(),
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Semantics(
                label: 'No admin activity logs found',
                child: Text(l10n.noActivityLogsFound),
              ),
            );
          }
          return Semantics(
            label: 'Admin activity log history list',
            child: FocusTraversalGroup(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Semantics(
                    label:
                        'Activity log: ${log.action} ${log.entity} ${log.entityId}, by ${log.performedBy}',
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Tooltip(
                          message: 'Admin action',
                          child: Icon(Icons.admin_panel_settings,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        title: Text(
                            '${log.action} ${log.entity} #${log.entityId}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (log.details.isNotEmpty) Text(log.details),
                            Text(log.timestamp.toLocal().toString()),
                          ],
                        ),
                        trailing: Text(log.performedBy,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
