import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/form_section.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../providers/farm_provider.dart';

class AddManualLogScreen extends StatefulWidget {
  const AddManualLogScreen({super.key});

  @override
  _AddManualLogScreenState createState() => _AddManualLogScreenState();
}

class _AddManualLogScreenState extends State<AddManualLogScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Feeding';
  final _animalIdsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  final List<String> _actionTypes = [
    'Feeding',
    'Deworming',
    'Cleaning',
    'Vaccination',
    'Medication',
    'Other'
  ];

  void _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;
    final farmProv = Provider.of<FarmProvider>(context, listen: false);
    final farmId = farmProv.selectedFarm?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('User not signed in')));
      setState(() => _isSaving = false);
      return;
    }
    if (farmId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No farm selected.')));
      setState(() => _isSaving = false);
      return;
    }
    final ids = _animalIdsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    try {
      await Provider.of<DatabaseService>(context, listen: false)
          .createManualLog(
        type: _type,
        animalIds: ids,
        notes: _notesController.text,
        performedBy: userId,
        farmId: farmId,
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Add Manual Log',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
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
                        title: 'Log Details',
                        children: [
                          DropdownButtonFormField<String>(
                            value: _type,
                            decoration: const InputDecoration(
                                labelText: 'Action Type',
                                labelStyle: TextStyle(fontSize: 20)),
                            items: _actionTypes
                                .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t,
                                        style: const TextStyle(fontSize: 20))))
                                .toList(),
                            onChanged: (v) => setState(() => _type = v!),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _animalIdsController,
                            decoration: const InputDecoration(
                                labelText: 'Animal IDs (comma-separated)',
                                labelStyle: TextStyle(fontSize: 20)),
                            style: const TextStyle(fontSize: 22),
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                                labelText: 'Notes',
                                labelStyle: TextStyle(fontSize: 20)),
                            maxLines: 3,
                            style: const TextStyle(fontSize: 22),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _save(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Tooltip(
                          message: 'Save manual log',
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
                                : const Text('Save', style: TextStyle(fontSize: 22)),
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
