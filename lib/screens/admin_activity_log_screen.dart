import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/farm_provider.dart';
import '../services/database_service.dart';
import '../models/activity_log.dart';

class AdminActivityLogScreen extends StatelessWidget {
  const AdminActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    if (!userProv.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Activity Logs')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (userProv.role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Activity Logs')),
        body: const Center(
            child: Text('Access Denied', style: TextStyle(fontSize: 18))),
      );
    }
    final db = Provider.of<DatabaseService>(context, listen: false);
    final farmProv = Provider.of<FarmProvider>(context);
    final farmId = farmProv.selectedFarm?.id;
    if (farmId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Activity Logs')),
        body: const Center(child: Text('No farm selected.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
          title: const Text('Activity Logs',
              key: Key('admin_logs_screen_title'),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
      body: StreamBuilder<List<ActivityLog>>(
        stream: db.streamActivityLogs(farmId: farmId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Semantics(
                label: 'Loading admin activity logs',
                child: const CircularProgressIndicator(),
              ),
            );
          }
          final logs = snapshot.data!;
          if (logs.isEmpty) {
            return Center(
              child: Semantics(
                label: 'No admin activity logs found',
                child: const Text('No activity logs found.',
                    style: TextStyle(fontSize: 22)),
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
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (log.details.isNotEmpty)
                              Text(log.details, style: const TextStyle(fontSize: 16)),
                            Text(log.timestamp.toLocal().toString(),
                                style: const TextStyle(fontSize: 16)),
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
    );
  }
}
