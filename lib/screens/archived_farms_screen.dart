import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../models/farm.dart';
import '../core/utils/l10n_extension.dart';

class ArchivedFarmsScreen extends ConsumerWidget {
  const ArchivedFarmsScreen({super.key});

  Future<void> _restoreFarm(
      BuildContext context, WidgetRef ref, Farm farm) async {
    await ref
        .read(farmNotifierProvider.notifier)
        .updateFarm(farm.copyWith(archived: false));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.farmRestored(farm.name))),
      );
    }
  }

  Future<void> _deleteFarm(
      BuildContext context, WidgetRef ref, Farm farm) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteFarmPermanentlyTitle),
        content: Text(l10n.deleteFarmPermanentlyContent(farm.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelButton),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteButton, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        final uid = ref.read(farmNotifierProvider).selectedFarm?.ownerId ?? '';
        await ref
            .read(farmNotifierProvider.notifier)
            .deleteFarm(farm.id, uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.farmPermanentlyDeleted(farm.name))),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.errorDeletingFarm(e.toString()))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final archived = ref.watch(farmNotifierProvider).archivedFarms;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.archivedFarmsTitle),
      ),
      body: archived.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.archive_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.noArchivedFarms,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.farmsYouArchiveWillAppear,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: archived.length,
              itemBuilder: (context, i) {
                final farm = archived[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.archive_outlined,
                              color: Colors.orange, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                farm.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              if (farm.address.isNotEmpty)
                                Text(
                                  farm.address,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                ),
                              if (farm.notes != null && farm.notes!.isNotEmpty)
                                Text(
                                  farm.notes!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            Tooltip(
                              message: l10n.restoreFarmTooltip,
                              child: IconButton(
                                icon: const Icon(Icons.restore,
                                    color: Colors.green),
                                onPressed: () =>
                                    _restoreFarm(context, ref, farm),
                              ),
                            ),
                            Tooltip(
                              message: l10n.deletePermanentlyTooltip,
                              child: IconButton(
                                icon: Icon(Icons.delete_forever,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error),
                                onPressed: () =>
                                    _deleteFarm(context, ref, farm),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
