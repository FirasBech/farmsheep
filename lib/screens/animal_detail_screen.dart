import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../models/animal.dart';
import 'edit_animal_screen.dart';
import '../features/ai/presentation/providers/ai_notifier.dart';

import '../widgets/ai_health_chat_sheet.dart';
import '../core/utils/color_utils.dart';
import '../core/utils/date_utils.dart' as du;
import '../core/utils/pdf_utils.dart';
import '../features/animal/presentation/providers/animals_provider.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../core/utils/l10n_extension.dart';

class AnimalDetailScreen extends ConsumerStatefulWidget {
  const AnimalDetailScreen({super.key});

  @override
  ConsumerState<AnimalDetailScreen> createState() =>
      _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends ConsumerState<AnimalDetailScreen> {
  late Animal animal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    animal = ModalRoute.of(context)!.settings.arguments as Animal;
  }

  Future<void> _navigateToEdit() async {
    final farmId = ref.read(farmNotifierProvider).selectedFarm?.id ?? '';
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditAnimalScreen(animal: animal)),
    );
    if (updated == true) {
      final animals =
          await ref.read(animalsStreamProvider(farmId).future);
      final refreshed =
          animals.firstWhere((a) => a.id == animal.id, orElse: () => animal);
      if (!mounted) return;
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AnimalDetailScreen(),
          settings: RouteSettings(arguments: refreshed),
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAnimalDialogTitle),
        content: Text(l10n.deleteAnimalDialogContent),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancelButton)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(animalNotifierProvider.notifier).delete(
            animal.id,
            farmId: ref.read(farmNotifierProvider).selectedFarm?.id,
          );
      if (!mounted) return;
      Navigator.pop(context, 'deleted');
    }
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF558B2F)),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1B5E20))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tagColor = parseTagColor(animal.tagColor);
    final sc = statusColor(animal.status);
    final hasPhotos =
        animal.photoUrls != null && animal.photoUrls!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          key: const Key('animal_details_screen_title'),
          '#${animal.tagNumber} — ${animal.type}',
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit),
              tooltip: l10n.editMenuItem,
              onPressed: _navigateToEdit),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: l10n.askAiTooltip,
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AiHealthChatSheet(animal: animal),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: l10n.exportPdfTooltip,
            onPressed: () async {
              try {
                final pdfBytes = await generateAnimalPdf(animal);
                await Printing.sharePdf(
                    bytes: pdfBytes,
                    filename: 'animal_${animal.tagNumber}.pdf');
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.pdfFailed(e.toString()))));
                }
              }
            },
          ),
          IconButton(
            key: const Key('delete_animal_button'),
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.deleteButton,
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (hasPhotos)
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: animal.photoUrls!.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(animal.photoUrls![i],
                        fit: BoxFit.cover, width: 220),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: tagColor.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: tagColor, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Text('Tag #${animal.tagNumber}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${animal.type} · ${animal.breed}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: sc.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(animal.status,
                            style: TextStyle(
                                color: sc,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _infoRow(l10n.tagNumberLabel, '#${animal.tagNumber}',
                      Icons.label_outline),
                  _infoRow(l10n.bornLabel, du.formatDate(animal.birthDate),
                      Icons.cake_outlined),
                  _infoRow(l10n.ageLabel, du.calcAge(animal.birthDate),
                      Icons.calendar_today_outlined),
                  Row(
                    children: [
                      const Icon(Icons.color_lens_outlined,
                          size: 18, color: Color(0xFF558B2F)),
                      const SizedBox(width: 12),
                      Text(l10n.tagColorLabel,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 13)),
                      const Spacer(),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                            color: tagColor,
                            borderRadius: BorderRadius.circular(6)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ── Physical ──────────────────────────────────────────────────
          if (animal.sex.isNotEmpty ||
              animal.currentWeightKg != null ||
              animal.bcs != null) ...[
            _sectionHeader(l10n.physicalSectionHeader, Icons.monitor_weight_outlined),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (animal.sex.isNotEmpty)
                      _infoRow(l10n.sexLabel, animal.sex, Icons.male),
                    if (animal.currentWeightKg != null)
                      _infoRow(l10n.weightLabel, '${animal.currentWeightKg} kg',
                          Icons.scale_outlined),
                    if (animal.bcs != null)
                      _infoRow(l10n.bcsLabel,
                          animal.bcs!.toString(), Icons.health_and_safety_outlined),
                    if (animal.microchipId != null)
                      _infoRow(l10n.microchipLabel, animal.microchipId!,
                          Icons.nfc_outlined),
                  ],
                ),
              ),
            ),
          ],
          // ── Origin ────────────────────────────────────────────────────
          if (animal.acquisitionType.isNotEmpty) ...[
            _sectionHeader(l10n.originSectionHeader, Icons.info_outline),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(l10n.acquiredLabel, animal.acquisitionType,
                        Icons.swap_horiz_outlined),
                    if (animal.purchaseSource != null)
                      _infoRow(l10n.sourceLabel, animal.purchaseSource!,
                          Icons.store_outlined),
                    if (animal.purchasePrice != null)
                      _infoRow(l10n.priceLabel, animal.purchasePrice!.toString(),
                          Icons.attach_money),
                    if (animal.purchaseDate != null)
                      _infoRow(
                          l10n.purchaseDateLabel,
                          animal.purchaseDate!
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                          Icons.event_outlined),
                  ],
                ),
              ),
            ),
          ],
          // ── Lineage ───────────────────────────────────────────────────
          if (animal.sireName != null || animal.damName != null) ...[
            _sectionHeader(l10n.lineageSectionHeader, Icons.account_tree_outlined),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (animal.sireName != null)
                      _infoRow(l10n.sireFatherLabel, animal.sireName!,
                          Icons.male),
                    if (animal.sireId != null)
                      _infoRow(l10n.sireIdLabel, animal.sireId!,
                          Icons.label_outline),
                    if (animal.damName != null)
                      _infoRow(l10n.damMotherLabel, animal.damName!,
                          Icons.female),
                    if (animal.damId != null)
                      _infoRow(l10n.damIdLabel, animal.damId!,
                          Icons.label_outline),
                  ],
                ),
              ),
            ),
          ],
          // ── Notes ─────────────────────────────────────────────────────
          if (animal.notes != null && animal.notes!.isNotEmpty) ...[
            _sectionHeader(l10n.notesSectionHeader, Icons.notes_outlined),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(animal.notes!,
                    style: const TextStyle(fontSize: 14, height: 1.5)),
              ),
            ),
          ],
          if (animal.pregnancyHistory.isNotEmpty) ...[
            _sectionHeader(
                '${l10n.pregnancyHistoryHeader} (${animal.pregnancyHistory.length})',
                Icons.pregnant_woman),
            Card(
              child: Column(
                children: animal.pregnancyHistory
                    .map((e) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.pregnant_woman,
                              color: Color(0xFF2E7D32), size: 20),
                          title: Text('Month ${e['month']}'),
                          trailing: Text('${e['count']} births',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),
            ),
          ],
          if (animal.birthLog.isNotEmpty) ...[
            _sectionHeader(
                '${l10n.birthLogHeader} (${animal.birthLog.length})',
                Icons.child_care),
            Card(
              child: Column(
                children: animal.birthLog
                    .map((e) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.child_care,
                              color: Color(0xFF2E7D32), size: 20),
                          title: Text(e['date']
                              .toDate()
                              .toLocal()
                              .toString()
                              .split(' ')[0]),
                          trailing: Text('${e['babies']} babies',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),
            ),
          ],
          if (animal.healthLogs.isNotEmpty) ...[
            _sectionHeader(
                '${l10n.healthLogsHeader} (${animal.healthLogs.length})',
                Icons.healing),
            Card(
              child: Column(
                children: animal.healthLogs
                    .map((e) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.healing,
                              color: Color(0xFF2E7D32), size: 20),
                          title: Text(
                              '${e['type']}: ${e['notes'] ?? ''}'),
                          subtitle: Text(
                              e['date']
                                  .toDate()
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                              style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            _AiRiskAssessmentButton(animal: animal),
          ],
          if (animal.saleInfo != null) ...[
            _sectionHeader(l10n.saleInfoHeader, Icons.sell),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(l10n.buyerLabel,
                        animal.saleInfo?['buyer'] ?? '—', Icons.person_outline),
                    _infoRow(
                      l10n.dateLabel,
                      animal.saleInfo?['date'] != null
                          ? (animal.saleInfo!['date'] is Timestamp
                              ? (animal.saleInfo!['date'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]
                              : animal.saleInfo!['date'].toString())
                          : '—',
                      Icons.event_outlined,
                    ),
                    _infoRow(
                        l10n.priceLabel,
                        animal.saleInfo?['price']?.toString() ?? '—',
                        Icons.attach_money),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AiRiskAssessmentButton extends ConsumerStatefulWidget {
  final Animal animal;
  const _AiRiskAssessmentButton({required this.animal});

  @override
  ConsumerState<_AiRiskAssessmentButton> createState() =>
      _AiRiskAssessmentButtonState();
}

class _AiRiskAssessmentButtonState
    extends ConsumerState<_AiRiskAssessmentButton> {
  bool _loading = false;
  bool _slowStatus = false;

  Future<void> _assess() async {
    setState(() {
      _loading = true;
      _slowStatus = false;
    });
    final slowTimer = Future.delayed(const Duration(seconds: 10),
        () { if (mounted) setState(() => _slowStatus = true); });
    String? result;
    String? error;
    try {
      result = await ref.read(aiNotifierProvider.notifier).predictHealthRisks(widget.animal);
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() { _loading = false; _slowStatus = false; });
    }
    await slowTimer.timeout(Duration.zero, onTimeout: () {});
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, sc) => Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              color: const Color(0xFF2E7D32),
              child: Row(
                children: [
                  const Icon(Icons.monitor_heart_outlined,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(context.l10n.aiHealthRiskAssessmentTitle,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: sc,
                padding: const EdgeInsets.all(20),
                child: error != null
                    ? Text('Error: $error',
                        style: const TextStyle(color: Colors.red))
                    : Text(result ?? '',
                        style:
                            const TextStyle(fontSize: 15, height: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OutlinedButton.icon(
      icon: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.monitor_heart_outlined),
      label: Text(_loading
          ? (_slowStatus ? l10n.stillWorkingLabel : l10n.analyzingLabel)
          : l10n.aiRiskAssessmentButton),
      onPressed: _loading ? null : _assess,
    );
  }
}
