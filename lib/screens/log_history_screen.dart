import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../features/log/presentation/providers/log_provider.dart';
import 'add_manual_log_screen.dart';
import '../core/utils/l10n_extension.dart';

class LogHistoryScreen extends ConsumerWidget {
  const LogHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final farmId = ref.watch(farmNotifierProvider).selectedFarm?.id;
    if (farmId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.manualLogsTitle)),
        body: Center(child: Text(l10n.noFarmSelected)),
      );
    }
    final logsAsync = ref.watch(logsStreamProvider(farmId));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.manualLogsTitle,
          key: const Key('logs_screen_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: logsAsync.when(
        loading: () => Center(
          child: Semantics(
            label: 'Loading manual logs',
            child: const CircularProgressIndicator(),
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Semantics(
                label: 'No manual logs found',
                child: Text(l10n.noLogsFound),
              ),
            );
          }
          return Semantics(
            label: 'Manual log history list',
            child: FocusTraversalGroup(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Semantics(
                    label:
                        'Log entry: ${log.type}, performed by ${log.performedBy}',
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Tooltip(
                          message: 'Log type',
                          child: Icon(Icons.list_alt,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        title: Text(log.type,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('At: ${log.timestamp.toLocal()}'),
                            if (log.animalIds != null &&
                                log.animalIds!.isNotEmpty)
                              Text('Animals: ${log.animalIds!.join(', ')}'),
                            if (log.notes.isNotEmpty)
                              Text('Notes: ${log.notes}'),
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
      floatingActionButton: Semantics(
        label: 'Add a new log',
        child: FloatingActionButton(
          key: const Key('add_log_fab'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddManualLogScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
