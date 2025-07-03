import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../providers/farm_provider.dart';
import '../models/activity_log.dart';

class FarmActivityLogScreen extends StatelessWidget {
  const FarmActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farmProv = Provider.of<FarmProvider>(context);
    final db = Provider.of<DatabaseService>(context, listen: false);
    final farmId = farmProv.selectedFarm?.id;
    if (farmId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Farm Activity Log')),
        body: const Center(child: Text('No farm selected.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Farm Activity Log')),
      body: StreamBuilder<List<ActivityLog>>(
        stream: db.streamActivityLogs(farmId: farmId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snapshot.data!;
          if (logs.isEmpty) {
            return const Center(child: Text('No activity logs for this farm.'));
          }
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, i) {
              final log = logs[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text('${log.action} ${log.entity} #${log.entityId}'),
                  subtitle: Text(log.details),
                  trailing: Text(log.performedBy),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
