import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/animal.dart';
import '../services/database_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../providers/farm_provider.dart';

class EditAnimalScreen extends StatefulWidget {
  final Animal animal;
  const EditAnimalScreen({super.key, required this.animal});

  @override
  _EditAnimalScreenState createState() => _EditAnimalScreenState();
}

class _EditAnimalScreenState extends State<EditAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tagController;
  late Color _color;
  late String _type;
  late TextEditingController _breedController;
  late DateTime _birthDate;
  List<XFile> _newImageFiles = [];
  List<String> _existingPhotoUrls = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tagController =
        TextEditingController(text: widget.animal.tagNumber.toString());
    _color = Color(int.parse(widget.animal.tagColor));
    _type =
        widget.animal.type[0].toUpperCase() + widget.animal.type.substring(1);
    _breedController = TextEditingController(text: widget.animal.breed);
    _birthDate = widget.animal.birthDate;
    _existingPhotoUrls = List.from(widget.animal.photoUrls ?? []);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (date != null) setState(() => _birthDate = date);
  }

  Future<void> _pickImage() async {
    final pickedList = await _picker.pickMultiImage(maxWidth: 600);
    if (pickedList.isNotEmpty) {
      List<XFile> cropped = [];
      for (final img in pickedList) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: img.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
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
              title: 'Crop Image',
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.original,
              ],
            ),
          ],
        );
        if (croppedFile != null) {
          cropped.add(XFile(croppedFile.path));
        }
      }
      setState(() {
        _newImageFiles = List.from(_newImageFiles)..addAll(cropped);
      });
    }
  }

  void _removeExistingPhoto(String url) {
    setState(() {
      _existingPhotoUrls.remove(url);
    });
  }

  void _removeNewPhoto(XFile file) {
    setState(() {
      _newImageFiles.remove(file);
    });
  }

  void _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_existingPhotoUrls.isEmpty && _newImageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one photo is required.')),
      );
      return;
    }
    final tagNum = int.tryParse(_tagController.text);
    if (tagNum == null || tagNum <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tag number must be a positive integer.')),
      );
      return;
    }
    final farmProv = Provider.of<FarmProvider>(context, listen: false);
    final farmId = farmProv.selectedFarm?.id;
    if (farmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No farm selected.')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await Provider.of<DatabaseService>(context, listen: false).updateAnimal(
        id: widget.animal.id,
        tagId: tagNum,
        colorHex: '0x${_color.value.toRadixString(16)}',
        type: _type,
        breed: _breedController.text,
        birthDate: _birthDate,
        farmId: farmId,
        newImages: _newImageFiles,
        keepPhotoUrls: _existingPhotoUrls,
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating animal: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Edit Animal',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
      body: Padding(
        padding: EdgeInsets.all(isWide ? 32 : 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Semantics(
                label: 'Edit animal form',
                child: FocusTraversalGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        key: const Key('animal_tag_field'),
                        controller: _tagController,
                        decoration: const InputDecoration(
                          labelText: 'Tag Number',
                          labelStyle: TextStyle(fontSize: 20),
                          hintText: 'Enter unique ear tag number',
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 22),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final n = int.tryParse(v);
                          if (n == null || n <= 0) {
                            return 'Enter a valid positive number';
                          }
                          return null;
                        },
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                      ),
                      const SizedBox(height: 20),
                      Tooltip(
                        message: 'Select the color of the tag',
                        child: ListTile(
                          title:
                              const Text('Tag Color', style: TextStyle(fontSize: 20)),
                          trailing:
                              Container(width: 32, height: 32, color: _color),
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Pick Tag Color',
                                  style: TextStyle(fontSize: 22)),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: _color,
                                  onColorChanged: (color) =>
                                      setState(() => _color = color),
                                  showLabel: false,
                                  pickerAreaHeightPercent: 0.6,
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Done',
                                        style: TextStyle(fontSize: 18)))
                              ],
                            ),
                          ),
                          focusColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2),
                          hoverColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Tooltip(
                        message: 'Select the type of animal',
                        child: DropdownButtonFormField<String>(
                          value: _type,
                          decoration: const InputDecoration(
                              labelText: 'Type',
                              labelStyle: TextStyle(fontSize: 20)),
                          items: ['Sheep', 'Goat']
                              .map((t) => DropdownMenuItem(
                                  value: t,
                                  child:
                                      Text(t, style: const TextStyle(fontSize: 20))))
                              .toList(),
                          onChanged: (v) => setState(() => _type = v!),
                          style: const TextStyle(fontSize: 20),
                          focusColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        key: const Key('animal_breed_field'),
                        controller: _breedController,
                        decoration: const InputDecoration(
                          labelText: 'Breed',
                          labelStyle: TextStyle(fontSize: 20),
                          hintText: 'e.g. Dorper',
                        ),
                        style: const TextStyle(fontSize: 22),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                      ),
                      const SizedBox(height: 20),
                      Tooltip(
                        message: 'Select the birth date of the animal',
                        child: ListTile(
                          title: Text(
                              'Birth Date: \\${_birthDate.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(fontSize: 20)),
                          trailing: const Icon(Icons.calendar_today, size: 32),
                          onTap: _pickDate,
                          focusColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2),
                          hoverColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          enabled: true,
                          autofocus: false,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Tooltip(
                        message: 'Add photos of the animal',
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _pickImage,
                          icon: const Icon(Icons.photo_library, size: 32),
                          label: const Text('Add Photos',
                              style: TextStyle(fontSize: 20)),
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(180, 56)),
                        ),
                      ),
                      if (_existingPhotoUrls.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _existingPhotoUrls.map((url) {
                            return Stack(
                              children: [
                                Semantics(
                                  label: 'Existing animal photo',
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
                                        : () => _removeExistingPhoto(url),
                                    child: const Tooltip(
                                      message: 'Remove photo',
                                      child: Icon(Icons.cancel,
                                          size: 28, color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_newImageFiles.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _newImageFiles.map((img) {
                            return Stack(
                              children: [
                                Semantics(
                                  label: 'Newly added animal photo',
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
                                        : () => _removeNewPhoto(img),
                                    child: const Tooltip(
                                      message: 'Remove photo',
                                      child: Icon(Icons.cancel,
                                          size: 28, color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Tooltip(
                        message:
                            'Save the changes made to the animal\'s information',
                        child: ElevatedButton(
                          key: const Key('animal_save_button'),
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(180, 56)),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 3))
                              : const Text('Save Changes',
                                  style: TextStyle(fontSize: 22)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
