import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/animal.dart';

import '../features/animal/presentation/providers/animals_provider.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../core/utils/color_utils.dart';
import '../core/utils/export_utils.dart';
import '../core/utils/l10n_extension.dart';

class AnimalListScreen extends ConsumerStatefulWidget {
  const AnimalListScreen({super.key});

  @override
  ConsumerState<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends ConsumerState<AnimalListScreen> {
  String _search = '';
  String? _typeFilter;
  String? _statusFilter;

  List<Animal> _applyFilters(List<Animal> animals) {
    var result = animals;
    if (_search.isNotEmpty) {
      result = result
          .where((a) =>
              a.tagId.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }
    if (_typeFilter != null) {
      result = result
          .where((a) => a.type.toLowerCase() == _typeFilter!.toLowerCase())
          .toList();
    }
    if (_statusFilter != null) {
      result = result
          .where((a) =>
              a.status.toLowerCase() == _statusFilter!.toLowerCase())
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final farmId = ref.watch(farmNotifierProvider).selectedFarm?.id;
    if (farmId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.animalsScreenTitle)),
        body: Center(child: Text(l10n.noFarmSelected)),
      );
    }

    final animalsAsync = ref.watch(animalsStreamProvider(farmId));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.animalsScreenTitle, key: const Key('animals_screen_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: l10n.exportCsvTooltip,
            onPressed: () {
              final animals = animalsAsync.valueOrNull ?? [];
              exportAnimalsCsv(_applyFilters(animals));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addAnimalTooltip,
            onPressed: () => Navigator.pushNamed(context, '/addAnimal'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchFilter(),
            const SizedBox(height: 24),
            Expanded(
              child: animalsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text(l10n.errorWithMessage(e.toString()))),
                data: (animals) {
                  final filtered = _applyFilters(animals);
                  if (filtered.isEmpty) return _emptyState();
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _animalCard(filtered[index], index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilter() {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search & Filter',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: l10n.searchByTagIdLabel,
              hintText: l10n.searchByTagIdHint,
              prefixIcon: const Icon(Icons.search_outlined),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _search = ''),
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _search = v.trim()),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _filterDropdown<String>(
                value: _typeFilter,
                hint: l10n.allTypesHint,
                items: ['sheep', 'goat'],
                label: (t) => t[0].toUpperCase() + t.substring(1),
                onChanged: (v) => setState(() => _typeFilter = v),
              )),
              const SizedBox(width: 12),
              Expanded(child: _filterDropdown<String>(
                value: _statusFilter,
                hint: l10n.allStatusesHint,
                items: ['Alive', 'Pregnant', 'Sold', 'Dead', 'Sick', 'Quarantined'],
                label: (s) => s,
                onChanged: (v) => setState(() => _statusFilter = v),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) label,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButton<T>(
        value: value,
        hint: Text(hint),
        isExpanded: true,
        underline: const SizedBox(),
        items: [
          DropdownMenuItem<T>(value: null, child: Text(hint)),
          ...items.map((item) =>
              DropdownMenuItem<T>(value: item, child: Text(label(item)))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _emptyState() {
    final l10n = context.l10n;
    return Center(
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
              Icons.pets_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noAnimalsFound,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _search.isNotEmpty ||
                    _typeFilter != null ||
                    _statusFilter != null
                ? l10n.tryAdjustingFilters
                : l10n.addFirstAnimal,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _animalCard(Animal animal, int index) {
    final tagColor = parseTagColor(animal.tagColor);
    final sc = statusColor(animal.status);
    return Container(
      key: Key('animal_card_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              Navigator.pushNamed(context, '/animalDetail', arguments: animal),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: (animal.photoUrls != null &&
                            animal.photoUrls!.isNotEmpty)
                        ? null
                        : tagColor,
                    image: (animal.photoUrls != null &&
                            animal.photoUrls!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(animal.photoUrls!.first),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (animal.photoUrls == null ||
                          animal.photoUrls!.isEmpty)
                      ? Center(
                          child: Text(
                            animal.tagNumber.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${animal.tagNumber} - ${animal.type}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        animal.breed,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: sc.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              animal.status,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: sc,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Born: ${animal.birthDate.year}/${animal.birthDate.month}/${animal.birthDate.day}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
