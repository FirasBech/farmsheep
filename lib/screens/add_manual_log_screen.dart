import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/form_section.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../features/log/presentation/providers/log_provider.dart';
import '../features/animal/presentation/providers/animals_provider.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../features/ai/presentation/providers/ai_notifier.dart';
import '../core/utils/l10n_extension.dart';

class AddManualLogScreen extends ConsumerStatefulWidget {
  const AddManualLogScreen({super.key});

  @override
  ConsumerState<AddManualLogScreen> createState() =>
      _AddManualLogScreenState();
}

class _AddManualLogScreenState extends ConsumerState<AddManualLogScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Feeding';
  final _animalIdsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;
  bool _aiLoading = false;

  final List<String> _actionTypes = [
    'Feeding',
    'Deworming',
    'Cleaning',
    'Vaccination',
    'Medication',
    'Treatment',
    'Health Check',
    'Observation',
    'Other'
  ];

  @override
  void dispose() {
    _animalIdsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getAiSuggestion() async {
    final farmId = ref.read(farmNotifierProvider).selectedFarm?.id;
    if (farmId == null) return;
    setState(() => _aiLoading = true);
    try {
      final animals =
          await ref.read(animalsStreamProvider(farmId).future);
      final logs = await ref.read(logsStreamProvider(farmId).future);

      final inputIds = _animalIdsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final animal = inputIds.isNotEmpty
          ? animals.firstWhere((a) => a.id == inputIds.first,
              orElse: () =>
                  animals.isNotEmpty ? animals.first : animals.first)
          : animals.isNotEmpty
              ? animals.first
              : null;

      if (animal == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.addAnimalsFirst)),
          );
        }
        return;
      }

      final suggestion = await ref
          .read(aiNotifierProvider.notifier)
          .suggestLogEntry(animal: animal, recentLogs: logs);

      if (mounted) {
        final suggestedType = suggestion['type'] ?? '';
        if (_actionTypes.contains(suggestedType)) {
          setState(() => _type = suggestedType);
        }
        _notesController.text = suggestion['notes'] ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.aiSuggestionApplied)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.aiSuggestionFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  void _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final userId =
        ref.read(authNotifierProvider.notifier).currentUser?.uid;
    final farmId = ref.read(farmNotifierProvider).selectedFarm?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.userNotSignedIn)));
      setState(() => _isSaving = false);
      return;
    }
    if (farmId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.noFarmSelected)));
      setState(() => _isSaving = false);
      return;
    }

    final ids = _animalIdsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    try {
      await ref.read(logNotifierProvider.notifier).createLog(
            type: _type,
            animalIds: ids,
            notes: _notesController.text,
            performedBy: userId,
            farmId: farmId,
          );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.errorSaving(e.toString()))));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
          title: Text(l10n.addManualLogTitle,
              style: const TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isWide ? 32 : 16),
            child: Form(
              key: _formKey,
              child: Semantics(
                label: 'Add manual log form',
                child: FocusTraversalGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Tooltip(
                        message: 'Manual log icon',
                        child: Icon(Icons.list_alt,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 24),
                      FormSection(
                        title: l10n.logDetailsSectionTitle,
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _type,
                            decoration: InputDecoration(
                                labelText: l10n.actionTypeLabel,
                                labelStyle: const TextStyle()),
                            items: _actionTypes
                                .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t,
                                        style: const TextStyle())))
                                .toList(),
                            onChanged: (v) => setState(() => _type = v!),
                            style: const TextStyle(),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _animalIdsController,
                            decoration: InputDecoration(
                                labelText: l10n.animalIdsLabel,
                                labelStyle: const TextStyle()),
                            style: const TextStyle(),
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _notesController,
                            decoration: InputDecoration(
                                labelText: l10n.notesLabel,
                                labelStyle: const TextStyle()),
                            maxLines: 3,
                            style: const TextStyle(),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _save(),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            icon: _aiLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.auto_awesome, size: 18),
                            label: Text(_aiLoading
                                ? l10n.gettingSuggestion
                                : l10n.getAiSuggestionButton),
                            onPressed:
                                _aiLoading ? null : _getAiSuggestion,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Tooltip(
                          message: l10n.saveManualLogTooltip,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save, size: 32),
                            label: _isSaving
                                ? Semantics(
                                    label: 'Saving manual log',
                                    child: const SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 3)))
                                : Text(l10n.saveButton,
                                    style: const TextStyle()),
                            onPressed: _isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(180, 56)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
