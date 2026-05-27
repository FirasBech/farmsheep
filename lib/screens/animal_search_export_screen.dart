import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/animal.dart';

import '../features/animal/presentation/providers/animals_provider.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../core/utils/export_utils.dart';
import '../core/utils/l10n_extension.dart';

class AnimalSearchExportScreen extends ConsumerStatefulWidget {
  const AnimalSearchExportScreen({super.key});

  @override
  ConsumerState<AnimalSearchExportScreen> createState() =>
      _AnimalSearchExportScreenState();
}

class _AnimalSearchExportScreenState
    extends ConsumerState<AnimalSearchExportScreen> {
  String _search = '';
  String _type = 'All';

  List<Animal> _applyFilters(List<Animal> animals) {
    return animals.where((a) {
      final matchSearch = _search.isEmpty ||
          a.tagNumber.toString().contains(_search) ||
          a.breed.toLowerCase().contains(_search.toLowerCase());
      final matchType = _type == 'All' || a.type == _type;
      return matchSearch && matchType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final farmId =
        ref.watch(farmNotifierProvider).selectedFarm?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.animalSearchExportTitle),
      ),
      body: farmId == null
          ? Center(child: Text(l10n.noFarmSelected))
          : _buildBody(farmId),
    );
  }

  Widget _buildBody(String farmId) {
    final l10n = context.l10n;
    final animalsAsync = ref.watch(animalsStreamProvider(farmId));

    return animalsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (animals) {
        final filtered = _applyFilters(animals);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: l10n.searchByTagOrBreed),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _type,
                    items: ['All', 'Sheep', 'Goat']
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: l10n.exportCsvTooltip,
                    onPressed: filtered.isEmpty
                        ? null
                        : () => exportAnimalsCsv(filtered),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final a = filtered[i];
                  return ListTile(
                    title: Text('#${a.tagNumber} - ${a.type}'),
                    subtitle: Text(
                        '${a.breed}, ${a.birthDate.toLocal().toString().split(' ')[0]}'),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
