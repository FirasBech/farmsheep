import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;
import '../services/auth_service.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../core/utils/l10n_extension.dart';

class FarmListScreen extends ConsumerWidget {
  const FarmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final farmState = ref.watch(farmNotifierProvider);
    final farms = farmState.activeFarms;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.yourFarmsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.unarchive_outlined),
            tooltip: l10n.viewArchivedFarms,
            onPressed: () =>
                Navigator.pushNamed(context, '/archivedFarms'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: farmState.loading
            ? const Center(child: CircularProgressIndicator())
            : farms.isEmpty
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
                        Icons.agriculture_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.noFarmsFound,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.addFirstFarm,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: farms.length,
                itemBuilder: (context, i) {
                  final farm = farms[i];
                  final isSelected = farmState.selectedFarm?.id == farm.id;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1)
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.agriculture,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.7),
                          size: 24,
                        ),
                      ),
                      title: Text(
                        farm.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      subtitle: Text(
                        farm.address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.archive_outlined),
                            tooltip: l10n.archiveFarmTitle,
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.orange.withValues(alpha: 0.1),
                              foregroundColor: Colors.orange,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(l10n.archiveFarmTitle),
                                  content: Text(l10n.archiveFarmConfirm),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text(l10n.cancelButton),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: Text(l10n.archiveButton),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && context.mounted) {
                                await ref
                                    .read(farmNotifierProvider.notifier)
                                    .archiveFarm(farm.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(l10n.farmArchived)),
                                  );
                                }
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: l10n.deleteFarmTitle,
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withValues(alpha: 0.1),
                              foregroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(l10n.deleteFarmTitle),
                                  content: Text(l10n.deleteFarmConfirm),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text(l10n.cancelButton),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .error),
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: Text(l10n.deleteButton,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && context.mounted) {
                                final callerUid = p.Provider.of<AuthService>(
                                        context,
                                        listen: false)
                                    .currentUser
                                    ?.uid ?? '';
                                await ref
                                    .read(farmNotifierProvider.notifier)
                                    .deleteFarm(farm.id, callerUid);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(l10n.farmDeleted)),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        ref
                            .read(farmNotifierProvider.notifier)
                            .selectFarm(farm);
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFarmDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.addFarmFab),
      ),
    );
  }

  void _showAddFarmDialog(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addNewFarmDialogTitle),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.farmNameLabel,
                    hintText: l10n.farmNameHint,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.farmNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: l10n.addressLabel,
                    hintText: l10n.addressHint,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.addressRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: l10n.notesOptionalLabel,
                    hintText: l10n.additionalFarmInfo,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelButton),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final ownerId = p.Provider.of<AuthService>(context, listen: false)
                      .currentUser
                      ?.uid ?? '';
                  await ref.read(farmNotifierProvider.notifier).addFarm(
                    nameController.text.trim(),
                    addressController.text.trim(),
                    notes: notesController.text.trim(),
                    ownerId: ownerId,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l10n.farmAddedSuccessfully)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.errorAddingFarm(e.toString()))),
                    );
                  }
                }
              }
            },
            child: Text(l10n.addFarmFab),
          ),
        ],
      ),
    );
  }
}
