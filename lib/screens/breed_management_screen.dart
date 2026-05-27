import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/ai/presentation/providers/ai_notifier.dart';
import '../core/utils/l10n_extension.dart';

class BreedManagementScreen extends ConsumerStatefulWidget {
  const BreedManagementScreen({super.key});

  @override
  ConsumerState<BreedManagementScreen> createState() =>
      _BreedManagementScreenState();
}

class _BreedManagementScreenState
    extends ConsumerState<BreedManagementScreen> {
  final _breedController = TextEditingController();
  final List<String> _breeds = [
    'Damani',
    'Dimashqi',
    'Mixed',
  ];

  @override
  void dispose() {
    _breedController.dispose();
    super.dispose();
  }

  void _addBreed() {
    final breed = _breedController.text.trim();
    if (breed.isNotEmpty && !_breeds.contains(breed)) {
      setState(() {
        _breeds.add(breed);
        _breedController.clear();
      });
    }
  }

  void _removeBreed(String breed) {
    setState(() => _breeds.remove(breed));
  }

  void _showAiRecommendDialog(BuildContext context) {
    final l10n = context.l10n;
    final climates = ['Arid', 'Temperate', 'Tropical', 'Cold', 'Semi-arid'];
    final purposes = ['Meat', 'Milk', 'Wool', 'Mixed'];
    String climate = climates.first;
    String purpose = purposes.first;
    final prefsCtrl = TextEditingController();
    bool loading = false;
    String? result;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDs) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.auto_awesome,
                  color: Theme.of(ctx).colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(l10n.aiBreedRecommendationTitle),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (result == null && !loading) ...[
                    // ignore: deprecated_member_use
                    DropdownButtonFormField<String>(
                      initialValue: climate, // ignore: deprecated_member_use
                      decoration: InputDecoration(labelText: l10n.climateLabel),
                      items: climates
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setDs(() => climate = v!),
                    ),
                    const SizedBox(height: 12),
                    // ignore: deprecated_member_use
                    DropdownButtonFormField<String>(
                      initialValue: purpose, // ignore: deprecated_member_use
                      decoration: InputDecoration(labelText: l10n.purposeLabel),
                      items: purposes
                          .map((p) =>
                              DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (v) => setDs(() => purpose = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: prefsCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.additionalPreferencesLabel,
                        hintText: l10n.additionalPreferencesHint,
                      ),
                      maxLines: 2,
                    ),
                  ] else if (loading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(l10n.consultingAiSpecialist),
                          ],
                        ),
                      ),
                    )
                  else if (error != null)
                    Text(l10n.errorSaving(error!),
                        style: const TextStyle(color: Colors.red))
                  else
                    Text(result ?? '',
                        style: const TextStyle(height: 1.6)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.closeButton),
            ),
            if (result == null && !loading)
              ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text(l10n.getRecommendationsButton),
                onPressed: () async {
                  setDs(() {
                    loading = true;
                    error = null;
                  });
                  try {
                    final response = await ref
                        .read(aiNotifierProvider.notifier)
                        .recommendBreeds(
                          climate: climate,
                          purpose: purpose,
                          preferences: prefsCtrl.text.trim(),
                        );
                    setDs(() {
                      result = response;
                      loading = false;
                    });
                  } catch (e) {
                    setDs(() {
                      error = e.toString();
                      loading = false;
                    });
                  }
                },
              )
            else if (result != null)
              ElevatedButton(
                onPressed: () => setDs(() => result = null),
                child: Text(l10n.askAgainButton),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.breedManagementTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add breed input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.add_circle_outline,
                            size: 18, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 8),
                        Text(l10n.addBreedSectionTitle,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _breedController,
                            decoration: InputDecoration(
                              hintText: l10n.enterBreedName,
                              prefixIcon: const Icon(Icons.pets_outlined),
                            ),
                            onSubmitted: (_) => _addBreed(),
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _addBreed,
                          child: Text(l10n.addButton),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Breeds list
            Expanded(
              child: _breeds.isEmpty
                  ? Center(
                      child: Text(l10n.noBreedsAdded,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5))),
                    )
                  : Card(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _breeds.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16),
                        itemBuilder: (context, i) {
                          final breed = _breeds[i];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.pets,
                                  color: Color(0xFF2E7D32), size: 18),
                            ),
                            title: Text(breed,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              tooltip: l10n.removeBreedTooltip,
                              onPressed: () => _removeBreed(breed),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAiRecommendDialog(context),
        icon: const Icon(Icons.auto_awesome),
        label: Text(l10n.aiRecommendFab),
      ),
    );
  }
}
