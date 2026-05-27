import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/animal.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' hide colorToHex;
import 'package:image_cropper/image_cropper.dart';

import '../features/animal/presentation/providers/animals_provider.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../core/utils/color_utils.dart';
import '../core/utils/validation_utils.dart';
import '../core/utils/l10n_extension.dart';

class EditAnimalScreen extends ConsumerStatefulWidget {
  final Animal animal;
  const EditAnimalScreen({super.key, required this.animal});

  @override
  ConsumerState<EditAnimalScreen> createState() => _EditAnimalScreenState();
}

class _EditAnimalScreenState extends ConsumerState<EditAnimalScreen> {
  final _formKey = GlobalKey<FormState>();

  // Identification
  late TextEditingController _tagController;
  late Color _color;
  late TextEditingController _microchipController;

  // Animal Details
  late String _type;
  late String _sex;
  late TextEditingController _breedController;
  late DateTime _birthDate;

  // Origin
  late String _acquisitionType;
  late TextEditingController _purchasePriceController;
  late TextEditingController _purchaseSourceController;
  DateTime? _purchaseDate;

  // Lineage
  late TextEditingController _sireNameController;
  late TextEditingController _sireIdController;
  late TextEditingController _damNameController;
  late TextEditingController _damIdController;

  // Physical
  late TextEditingController _weightController;
  double? _bcs;

  // Notes
  late TextEditingController _notesController;

  // Photos
  List<XFile> _newImageFiles = [];
  List<String> _existingPhotoUrls = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  static const _sexOptions = ['Female', 'Male', 'Wether', 'Unknown'];
  static const _acquisitionOptions = ['Born on Farm', 'Purchased', 'Gifted'];
  static const _bcsOptions = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0];

  @override
  void initState() {
    super.initState();
    final a = widget.animal;
    _tagController = TextEditingController(text: a.tagNumber.toString());
    _color = parseTagColor(a.tagColor);
    _microchipController = TextEditingController(text: a.microchipId ?? '');
    _type = a.type[0].toUpperCase() + a.type.substring(1);
    _sex = _sexOptions.contains(a.sex) ? a.sex : 'Unknown';
    _breedController = TextEditingController(text: a.breed);
    _birthDate = a.birthDate;
    _acquisitionType = _acquisitionOptions.contains(a.acquisitionType)
        ? a.acquisitionType
        : '';
    _purchasePriceController =
        TextEditingController(text: a.purchasePrice?.toString() ?? '');
    _purchaseSourceController =
        TextEditingController(text: a.purchaseSource ?? '');
    _purchaseDate = a.purchaseDate;
    _sireNameController = TextEditingController(text: a.sireName ?? '');
    _sireIdController = TextEditingController(text: a.sireId ?? '');
    _damNameController = TextEditingController(text: a.damName ?? '');
    _damIdController = TextEditingController(text: a.damId ?? '');
    _weightController =
        TextEditingController(text: a.currentWeightKg?.toString() ?? '');
    _bcs = a.bcs;
    _notesController = TextEditingController(text: a.notes ?? '');
    _existingPhotoUrls = List.from(a.photoUrls ?? []);
  }

  @override
  void dispose() {
    _tagController.dispose();
    _microchipController.dispose();
    _breedController.dispose();
    _purchasePriceController.dispose();
    _purchaseSourceController.dispose();
    _sireNameController.dispose();
    _sireIdController.dispose();
    _damNameController.dispose();
    _damIdController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isBirth}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: isBirth ? _birthDate : (_purchaseDate ?? now),
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (date != null) {
      setState(() {
        if (isBirth) {
          _birthDate = date;
        } else {
          _purchaseDate = date;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final cropTitle = context.l10n.cropImageTitle;
    try {
      final pickedList = await _picker.pickMultiImage(maxWidth: 600);
      if (pickedList.isEmpty) return;
      List<XFile> cropped = [];
      for (final img in pickedList) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: img.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: cropTitle,
              toolbarColor: Colors.green,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.original,
              ],
            ),
            IOSUiSettings(
              title: cropTitle,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.original,
              ],
            ),
          ],
        );
        // Use cropped result; fall back to original if user cancelled crop
        cropped.add(croppedFile != null ? XFile(croppedFile.path) : img);
      }
      if (!mounted) return;
      setState(() {
        _newImageFiles = List.from(_newImageFiles)..addAll(cropped);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.couldNotPickImage(e.toString()))),
      );
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final tagNum = int.tryParse(_tagController.text);
    if (tagNum == null || tagNum <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.tagNumberMustBePositive)));
      return;
    }
    final farmId = ref.read(farmNotifierProvider).selectedFarm?.id;
    if (farmId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.noFarmSelected)));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final extraFields = <String, dynamic>{
        'sex': _sex,
        if (_acquisitionType.isNotEmpty) 'acquisitionType': _acquisitionType,
        if (_microchipController.text.isNotEmpty)
          'microchipId': _microchipController.text.trim(),
        if (_weightController.text.isNotEmpty)
          'currentWeightKg':
              double.tryParse(_weightController.text.trim()),
        if (_bcs != null) 'bcs': _bcs,
        if (_notesController.text.isNotEmpty)
          'notes': _notesController.text.trim(),
        if (_acquisitionType == 'Born on Farm') ...{
          if (_sireNameController.text.isNotEmpty)
            'sireName': _sireNameController.text.trim(),
          if (_sireIdController.text.isNotEmpty)
            'sireId': _sireIdController.text.trim(),
          if (_damNameController.text.isNotEmpty)
            'damName': _damNameController.text.trim(),
          if (_damIdController.text.isNotEmpty)
            'damId': _damIdController.text.trim(),
        },
        if (_acquisitionType == 'Purchased') ...{
          if (_purchasePriceController.text.isNotEmpty)
            'purchasePrice':
                double.tryParse(_purchasePriceController.text.trim()),
          if (_purchaseSourceController.text.isNotEmpty)
            'purchaseSource': _purchaseSourceController.text.trim(),
          if (_purchaseDate != null) 'purchaseDate': _purchaseDate,
        },
      };

      await ref.read(animalNotifierProvider.notifier).update(
            id: widget.animal.id,
            tagId: tagNum,
            colorHex: colorToHex(_color),
            type: _type,
            breed: _breedController.text,
            birthDate: _birthDate,
            farmId: farmId,
            newImagePaths: _newImageFiles.map((f) => f.path).toList(),
            keepPhotoUrls: _existingPhotoUrls,
            extraFields: extraFields,
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.errorUpdatingAnimal(e.toString()))));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1B5E20))),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.green.shade200)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isWide = MediaQuery.of(context).size.width > 600;
    final farmBreeds =
        ref.read(farmNotifierProvider).selectedFarm?.preferredBreeds ?? [];
    final breeds =
        farmBreeds.isNotEmpty ? farmBreeds : const ['Damani', 'Dimashqi', 'Mixed'];
    final breedOptions = breeds.contains(_breedController.text)
        ? breeds
        : [_breedController.text, ...breeds];

    return Scaffold(
      appBar: AppBar(
          title: Text(l10n.editAnimalScreenTitle,
              style: const TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: EdgeInsets.all(isWide ? 32 : 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ── Identification ─────────────────────────────────────────
              _sectionHeader(l10n.identificationSection, Icons.label_outline),
              TextFormField(
                key: const Key('animal_tag_field'),
                controller: _tagController,
                decoration: InputDecoration(
                    labelText: l10n.tagNumberFieldLabel,
                    hintText: l10n.tagNumberFieldHint),
                keyboardType: TextInputType.number,
                validator: validateTagNumber,
                autofocus: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(l10n.tagColorTileTitle),
                trailing: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        color: _color,
                        borderRadius: BorderRadius.circular(6))),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(l10n.pickTagColorDialogTitle),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: _color,
                        onColorChanged: (c) => setState(() => _color = c),
                        labelTypes: const [],
                        pickerAreaHeightPercent: 0.6,
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.doneButton,
                              style: const TextStyle(fontSize: 18)))
                    ],
                  ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _microchipController,
                decoration: InputDecoration(
                    labelText: l10n.microchipRfidLabel,
                    hintText: l10n.microchipRfidHint),
                textInputAction: TextInputAction.next,
              ),

              // ── Animal Details ─────────────────────────────────────────
              _sectionHeader(l10n.animalDetailsSection, Icons.pets_outlined),
              // ignore: deprecated_member_use
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(labelText: l10n.typeLabel),
                items: ['Sheep', 'Goat']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              // ignore: deprecated_member_use
              DropdownButtonFormField<String>(
                initialValue: _sex,
                decoration: InputDecoration(labelText: l10n.sexLabel),
                items: _sexOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _sex = v!),
              ),
              const SizedBox(height: 16),
              // ignore: deprecated_member_use
              DropdownButtonFormField<String>(
                key: const Key('animal_breed_field'),
                initialValue: _breedController.text.isNotEmpty
                    ? _breedController.text
                    : null,
                decoration: InputDecoration(labelText: l10n.breedLabel),
                items: breedOptions
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _breedController.text = v ?? ''),
                validator: (v) => validateRequired(v, 'Select a breed'),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.cake_outlined),
                title: Text(
                    '${l10n.birthDatePrefix}${_birthDate.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today, size: 32),
                onTap: () => _pickDate(isBirth: true),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),

              // ── Origin ─────────────────────────────────────────────────
              _sectionHeader(l10n.originSection, Icons.info_outline),
              // ignore: deprecated_member_use
              DropdownButtonFormField<String>(
                initialValue: _acquisitionType.isEmpty ? null : _acquisitionType,
                hint: Text(l10n.howWasAnimalAcquired),
                decoration: InputDecoration(labelText: l10n.acquisitionTypeLabel),
                items: _acquisitionOptions
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) => setState(() => _acquisitionType = v ?? ''),
              ),
              if (_acquisitionType == 'Purchased') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _purchaseSourceController,
                  decoration: InputDecoration(
                      labelText: l10n.purchaseSourceLabel,
                      hintText: l10n.purchaseSourceHint),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _purchasePriceController,
                  decoration: InputDecoration(
                      labelText: l10n.purchasePriceLabel,
                      hintText: l10n.purchasePriceHint),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: Text(_purchaseDate == null
                      ? l10n.purchaseDateTile
                      : '${l10n.purchasedDatePrefix}${_purchaseDate!.toLocal().toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(isBirth: false),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ],

              // ── Lineage ────────────────────────────────────────────────
              if (_acquisitionType == 'Born on Farm') ...[
                _sectionHeader(l10n.lineageSection, Icons.account_tree_outlined),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sireNameController,
                      decoration: InputDecoration(
                          labelText: l10n.sireTagNameLabel,
                          hintText: l10n.sireTagNameHint),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _sireIdController,
                      decoration: InputDecoration(
                          labelText: l10n.sireIdLabel,
                          hintText: l10n.sireIdHint),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _damNameController,
                      decoration: InputDecoration(
                          labelText: l10n.damTagNameLabel,
                          hintText: l10n.damTagNameHint),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _damIdController,
                      decoration: InputDecoration(
                          labelText: l10n.damIdLabel,
                          hintText: l10n.sireIdHint),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ]),
              ],

              // ── Physical ───────────────────────────────────────────────
              _sectionHeader(l10n.physicalSection, Icons.monitor_weight_outlined),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                    labelText: l10n.currentWeightLabel,
                    hintText: l10n.currentWeightHint),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              Text(l10n.bodyConditionScoreLabel,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _bcsOptions.map((v) {
                  final selected = _bcs == v;
                  return ChoiceChip(
                    label: Text(v.toString()),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _bcs = selected ? null : v),
                    selectedColor: const Color(0xFF388E3C),
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : null,
                        fontWeight: selected ? FontWeight.bold : null),
                  );
                }).toList(),
              ),

              // ── Notes ──────────────────────────────────────────────────
              _sectionHeader(l10n.notesSection, Icons.notes_outlined),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                    labelText: l10n.notesLabel,
                    hintText: l10n.notesHint,
                    alignLabelWithHint: true),
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),

              // ── Photos ─────────────────────────────────────────────────
              _sectionHeader(l10n.photosSection, Icons.photo_library_outlined),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _pickImage,
                icon: const Icon(Icons.photo_library, size: 28),
                label: Text(l10n.galleryButton),
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
              ),
              if (_existingPhotoUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _existingPhotoUrls
                      .map((url) => Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(url,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: _isSaving
                                      ? null
                                      : () => setState(() =>
                                          _existingPhotoUrls.remove(url)),
                                  child: const Icon(Icons.cancel,
                                      size: 28, color: Colors.red),
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ],
              if (_newImageFiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _newImageFiles
                      .map((img) => Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(img.path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: _isSaving
                                      ? null
                                      : () => setState(
                                          () => _newImageFiles.remove(img)),
                                  child: const Icon(Icons.cancel,
                                      size: 28, color: Colors.red),
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                key: const Key('animal_save_button'),
                onPressed: _isSaving ? null : _save,
                style:
                    ElevatedButton.styleFrom(minimumSize: const Size(0, 56)),
                child: _isSaving
                    ? const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 3))
                    : Text(l10n.saveChangesButton,
                        style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
