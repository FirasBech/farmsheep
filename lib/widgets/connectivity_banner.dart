import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/offline_sync_service.dart';
import '../main.dart' show ConnectivityStatus;

class ConnectivityBanner extends StatelessWidget {
  final Widget child;
  const ConnectivityBanner({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final offlineSync = Provider.of<OfflineSyncService>(context);
    final connectivity =
        Provider.of<ConnectivityStatus?>(context, listen: false);
    final isOnline = (connectivity?.isOnline ?? true) && offlineSync.isOnline;
    if (isOnline) return child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MaterialBanner(
          key: const Key('offline_banner'),
          content: Row(
            children: [
              const Text(
                  'You are offline. Changes will sync when reconnected.'),
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
