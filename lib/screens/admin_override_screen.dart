import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/animal.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../features/animal/presentation/providers/animals_provider.dart';
import '../features/log/presentation/providers/log_provider.dart';
import '../core/utils/l10n_extension.dart';

class AdminOverrideScreen extends ConsumerStatefulWidget {
  const AdminOverrideScreen({super.key});

  @override
  ConsumerState<AdminOverrideScreen> createState() =>
      _AdminOverrideScreenState();
}

class _AdminOverrideScreenState extends ConsumerState<AdminOverrideScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showOverrideDialog(Animal animal) async {
    final breedCtrl = TextEditingController(text: animal.breed);
    final typeCtrl = TextEditingController(text: animal.type);
    final reasonCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool saving = false;
    final adminUid =
        ref.read(authNotifierProvider.notifier).currentUser?.uid;
    final l10n = context.l10n;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.admin_panel_settings,
                  color: Theme.of(ctx).colorScheme.error),
              const SizedBox(width: 8),
              Text(l10n.overrideAnimalDialogTitle(animal.tagNumber.toString())),
            ],
          ),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: typeCtrl,
                    decoration: InputDecoration(labelText: l10n.typeLabel),
                    validator: (v) =>
                        v == null || v.isEmpty ? l10n.requiredValidation : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: breedCtrl,
                    decoration: InputDecoration(labelText: l10n.breedLabel),
                    validator: (v) =>
                        v == null || v.isEmpty ? l10n.requiredValidation : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: reasonCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.reasonForOverrideLabel,
                      hintText: l10n.reasonForOverrideHint,
                      prefixIcon: const Icon(Icons.info_outline),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(ctx).colorScheme.error),
                      ),
                    ),
                    maxLines: 2,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.reasonRequiredValidation
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(ctx),
              child: Text(l10n.cancelButton),
            ),
            ElevatedButton.icon(
              icon: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(l10n.saveOverrideButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => saving = true);
                      try {
                        await ref
                            .read(animalNotifierProvider.notifier)
                            .update(
                              id: animal.id,
                              tagId: animal.tagNumber,
                              colorHex: animal.tagColor,
                              type: typeCtrl.text.trim(),
                              breed: breedCtrl.text.trim(),
                              birthDate: animal.birthDate,
                              farmId: animal.farmId,
                              keepPhotoUrls: animal.photoUrls,
                              adminUserId: adminUid,
                              overrideReason: reasonCtrl.text.trim(),
                            );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.overrideSaved)),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => saving = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(l10n.errorSaving(e.toString()))),
                          );
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authNotifierProvider);
    if (authState.role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adminRecordOverrideTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(l10n.adminAccessRequired,
                  style: const TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final farmId = ref.watch(farmNotifierProvider).selectedFarm?.id;
    if (farmId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.adminRecordOverrideTitle)),
        body: Center(child: Text(l10n.noFarmSelected)),
      );
    }

    final animalsAsync = ref.watch(animalsStreamProvider(farmId));
    final overridesAsync = ref.watch(activityLogsStreamProvider(farmId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminRecordOverrideTitle),
        actions: [
          Tooltip(
            message: 'All overrides are logged in the audit trail',
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.info_outline,
                  color: Theme.of(context).appBarTheme.foregroundColor),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.searchAnimalsByTagOrBreed,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),

          // Animal list
          Expanded(
            flex: 2,
            child: animalsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (allAnimals) {
                var animals = allAnimals;
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  animals = animals
                      .where((a) =>
                          a.tagId.toLowerCase().contains(q) ||
                          a.breed.toLowerCase().contains(q) ||
                          a.type.toLowerCase().contains(q))
                      .toList();
                }
                if (animals.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'No animals match "$_searchQuery"'
                          : 'No animals in this farm.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: animals.length,
                  itemBuilder: (context, i) {
                    final animal = animals[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.errorContainer,
                          child: Text(
                            animal.tagNumber.toString(),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                            '#${animal.tagNumber} — ${animal.type} (${animal.breed})'),
                        subtitle: Text(
                            'Status: ${animal.status} · Born: ${animal.birthDate.year}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_note,
                              color: Colors.orange),
                          tooltip: l10n.overrideThisRecord,
                          onPressed: () => _showOverrideDialog(animal),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Recent overrides audit log
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.history,
                    size: 18,
                    color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 6),
                Text(
                  l10n.recentOverridesHeader,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: overridesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (logs) {
                final overrides = logs
                    .where((log) => log.action == 'override')
                    .toList()
                  ..sort(
                      (a, b) => b.timestamp.compareTo(a.timestamp));
                if (overrides.isEmpty) {
                  return Center(
                    child: Text(l10n.noOverridesRecorded,
                        style: const TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: overrides.length,
                  itemBuilder: (context, i) {
                    final log = overrides[i];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.edit_note,
                          size: 18, color: Colors.orange),
                      title: Text(log.details,
                          style: const TextStyle(fontSize: 13)),
                      subtitle: Text(
                        'Animal ${log.entityId} · ${log.timestamp.toLocal().toString().substring(0, 16)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Text(
                        log.performedBy.length > 6
                            ? log.performedBy.substring(0, 6)
                            : log.performedBy,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
