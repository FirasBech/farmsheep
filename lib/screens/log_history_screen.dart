import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/manual_log.dart';
import 'add_manual_log_screen.dart';
import '../providers/farm_provider.dart';

class LogHistoryScreen extends StatelessWidget {
  const LogHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final farmProv = Provider.of<FarmProvider>(context);
    final farmId = farmProv.selectedFarm?.id;
    if (farmId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manual Logs')),
        body: const Center(child: Text('No farm selected.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manual Logs',
          key: Key('logs_screen_title'),
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<ManualLog>>(
        stream: db.streamManualLogs(farmId: farmId),
        builder: (context, snapshot) {
          print(
              'DEBUG: LogHistoryScreen StreamBuilder snapshot.hasData = \\${snapshot.hasData}, logs = \\${snapshot.data?.length}');
          if (!snapshot.hasData) {
            return Center(
              child: Semantics(
                label: 'Loading manual logs',
                child: const CircularProgressIndicator(),
              ),
            );
          }
          final logs = snapshot.data!;
          if (logs.isEmpty) {
            print('DEBUG: LogHistoryScreen empty state shown');
            return Center(
              child: Semantics(
                label: 'No manual logs found',
                child: const Text(
                  'No logs found.',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            );
          }
          print('DEBUG: LogHistoryScreen showing \\${logs.length} logs');
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
                        'Log entry: \\${log.type}, performed by \\${log.performedBy}',
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
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'At: \\${log.timestamp.toLocal()}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (log.animalIds != null &&
                                log.animalIds!.isNotEmpty)
                              Text(
                                'Animals: \\${log.animalIds!.join(', ')}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            if (log.notes.isNotEmpty)
                              Text(
                                'Notes: \\${log.notes}',
                                style: const TextStyle(fontSize: 16),
                              ),
                          ],
                        ),
                        trailing: Text(log.performedBy,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          print(
              'DEBUG: LogHistoryScreen FAB built, context: \\${context.widget.runtimeType}');
          return Semantics(
            label: 'Add a new log',
            child: FloatingActionButton(
              key: const Key('add_log_fab'),
              onPressed: () {
                print('DEBUG: Add Log FAB pressed');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddManualLogScreen()),
                );
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
