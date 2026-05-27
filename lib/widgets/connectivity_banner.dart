import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/l10n_extension.dart';
import '../providers/connectivity_provider.dart';

class SyncStatusIndicator extends StatefulWidget {
  const SyncStatusIndicator({super.key});
  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  bool _hasPendingWrites = false;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    if (Firebase.apps.isEmpty) return;
    // Use a cache-only get to check pending writes without a network round-trip.
    FirebaseFirestore.instance.snapshotsInSync().listen((_) {
      FirebaseFirestore.instance
          .collection('users')
          .limit(1)
          .get(const GetOptions(source: Source.cache))
          .then((snap) {
        if (mounted) {
          setState(() => _hasPendingWrites = snap.metadata.hasPendingWrites);
        }
      }).catchError((_) {});
    });
    final status = context.read<ConnectivityStatus>();
    _isOnline = status.isOnline;
    status.addListener(() {
      if (mounted) setState(() => _isOnline = status.isOnline);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) return const SizedBox.shrink();
    if (!_isOnline) return const SizedBox.shrink();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _hasPendingWrites
          ? Tooltip(
              message: context.l10n.syncingChanges,
              child: Semantics(
                label: context.l10n.syncingChanges,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              ),
            )
          : Tooltip(
              message: context.l10n.allChangesSynced,
              child: Semantics(
                label: context.l10n.allChangesSynced,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.cloud_done, color: Colors.green, size: 28),
                ),
              ),
            ),
    );
  }
}

class ConnectivityBanner extends StatelessWidget {
  final Widget child;
  const ConnectivityBanner({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityStatus>().isOnline;
    return Stack(
      children: [
        child,
        const Positioned(
          top: 0,
          right: 0,
          child: SyncStatusIndicator(),
        ),
        if (!isOnline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FocusableActionDetector(
              autofocus: true,
              child: Semantics(
                label: context.l10n.offlineBannerText,
                liveRegion: true,
                child: Tooltip(
                  message: context.l10n.offlineTooltip,
                  child: Material(
                    color: Colors.red.shade700,
                    child: SafeArea(
                      child: Container(
                        key: const Key('offline_banner'),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.offlineBannerText,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
