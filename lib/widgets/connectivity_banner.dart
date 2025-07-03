import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/offline_sync_service.dart';

class ConnectivityBanner extends StatelessWidget {
  final Widget child;
  const ConnectivityBanner({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final offlineSync = Provider.of<OfflineSyncService>(context);
    if (offlineSync.isOnline) return child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MaterialBanner(
          content: Row(
            children: [
              const Text('You are offline. Changes will sync when reconnected.'),
              if (offlineSync.isSyncing) ...[
                const SizedBox(width: 16),
                const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ],
              if (offlineSync.hasConflicts) ...[
                const SizedBox(width: 16),
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(offlineSync.conflictMessage ?? 'Sync conflict!'),
              ],
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: offlineSync.isSyncing
                    ? null
                    : () => offlineSync.manualSync(),
                child: const Text('Manual Sync'),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          actions: const [],
        ),
        Expanded(child: child),
      ],
    );
  }
}
