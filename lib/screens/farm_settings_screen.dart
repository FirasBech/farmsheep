import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../models/farm.dart';
import '../core/utils/l10n_extension.dart';

class FarmSettingsScreen extends ConsumerStatefulWidget {
  const FarmSettingsScreen({super.key});

  @override
  ConsumerState<FarmSettingsScreen> createState() => _FarmSettingsScreenState();
}

class _FarmSettingsScreenState extends ConsumerState<FarmSettingsScreen> {
  final _notesController = TextEditingController();
  final _breedsController = TextEditingController();
  int? _farmColor;
  Map<String, bool> _partnerPermissions = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final farm = ref.read(farmNotifierProvider).selectedFarm;
    _notesController.text = farm?.notes ?? '';
    _breedsController.text = farm?.preferredBreeds.join(', ') ?? '';
    _farmColor = farm?.color;
    _partnerPermissions =
        Map<String, bool>.from(farm?.partnerPermissions ?? {});
  }

  @override
  void dispose() {
    _notesController.dispose();
    _breedsController.dispose();
    super.dispose();
  }

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20))),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final farm = ref.watch(farmNotifierProvider).selectedFarm;
    if (farm == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.farmSettingsTitle)),
        body: Center(child: Text(l10n.noFarmSelected)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.farmSettingsTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.agriculture, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(farm.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1B5E20))),
                        if (farm.address.isNotEmpty)
                          Text(farm.address,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF388E3C))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _sectionCard(
              title: l10n.notesSectionTitle,
              icon: Icons.notes_outlined,
              children: [
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    hintText: l10n.notesHint,
                  ),
                  maxLines: 3,
                ),
              ],
            ),

            _sectionCard(
              title: l10n.preferredBreedsSectionTitle,
              icon: Icons.pets_outlined,
              children: [
                TextField(
                  controller: _breedsController,
                  decoration: InputDecoration(
                    hintText: l10n.preferredBreedsHint,
                    helperText: l10n.preferredBreedsHelper,
                  ),
                ),
              ],
            ),

            _sectionCard(
              title: l10n.farmColorSectionTitle,
              icon: Icons.palette_outlined,
              children: [
                Row(
                  children: [
                    Text(l10n.currentColorLabel),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () async {
                        final color = await showDialog<int>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.pickFarmColorDialogTitle),
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                pickerColor:
                                    Color(_farmColor ?? 0xFF388E3C),
                                onColorChanged: (c) =>
                                    Navigator.pop(context, c.toARGB32()),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.doneButton),
                              ),
                            ],
                          ),
                        );
                        if (color != null) setState(() => _farmColor = color);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(_farmColor ?? 0xFF388E3C),
                          border:
                              Border.all(color: const Color(0xFFA5D6A7), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.tapToChange,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),

            _sectionCard(
              title: l10n.partnerPermissionsSectionTitle,
              icon: Icons.security_outlined,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.allowPartnersAddAnimalsTitle),
                  subtitle: Text(l10n.allowPartnersAddAnimalsSubtitle),
                  value: _partnerPermissions['add_animals'] ?? false,
                  onChanged: (v) => setState(() {
                    _partnerPermissions['add_animals'] = v;
                  }),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.allowPartnersEditLogsTitle),
                  subtitle: Text(l10n.allowPartnersEditLogsSubtitle),
                  value: _partnerPermissions['edit_logs'] ?? false,
                  onChanged: (v) => setState(() {
                    _partnerPermissions['edit_logs'] = v;
                  }),
                ),
              ],
            ),

            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.saveSettingsButton),
                onPressed: () async {
                  final updated = Farm(
                    id: farm.id,
                    name: farm.name,
                    address: farm.address,
                    ownerId: farm.ownerId,
                    partnerIds: farm.partnerIds,
                    createdAt: farm.createdAt,
                    notes: _notesController.text,
                    archived: farm.archived,
                    preferredBreeds: _breedsController.text
                        .split(',')
                        .map((b) => b.trim())
                        .where((b) => b.isNotEmpty)
                        .toList(),
                    color: _farmColor ?? 0xFF388E3C,
                    partnerPermissions: _partnerPermissions,
                  );
                  await ref.read(farmNotifierProvider.notifier).updateFarm(updated);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.farmSettingsUpdated)),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
