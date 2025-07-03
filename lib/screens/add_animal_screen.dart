import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../providers/farm_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_cropper/image_cropper.dart';

bool isIntegrationTest = false;

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  _AddAnimalScreenState createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagController = TextEditingController();
  Color _color = Colors.black;
  String _type = 'Sheep';
  final _breedController = TextEditingController();
  DateTime? _birthDate;
  List<XFile> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  bool get _isIntegrationTest => isIntegrationTest;

  final List<String> _breeds = [
    'Damani',
    'Dimashqi',
    'Mixed',
  ];

  @override
  void initState() {
    super.initState();
    // TODO: Load breeds from persistent storage (Firestore or local DB)
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
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
        _imageFiles = List.from(_imageFiles)..addAll(cropped);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picked =
        await _picker.pickImage(source: ImageSource.camera, maxWidth: 600);
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        _imageFiles = List.from(_imageFiles)..add(picked);
      });
    }
  }

  void _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Birth date is required.')),
      );
      return;
    }
    if (_imageFiles.isEmpty && !_isIntegrationTest) {
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
      await Provider.of<DatabaseService>(context, listen: false).createAnimal(
        tagId: tagNum,
        colorHex: '0x${_color.value.toRadixString(16)}',
        type: _type,
        breed: _breedController.text,
        birthDate: _birthDate!,
        farmId: farmId,
        images: _imageFiles,
      );
      // Record admin activity
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;
      if (userId != null) {
        await Provider.of<DatabaseService>(context, listen: false)
            .logAdminAction(
          action: 'added',
          entity: 'animal',
          entityId: tagNum.toString(),
          details:
              'Color: 0x${_color.value.toRadixString(16)}, Type: $_type, Breed: ${_breedController.text}',
          userId: userId,
          farmId: farmId,
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving animal: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Animal',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            key: Key('add_animal_screen_title')),
      ),
      body: Padding(
        padding: EdgeInsets.all(isWide ? 32 : 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Semantics(
                label: 'Add animal form',
                child: FocusTraversalGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        label: 'Tag Number',
                        child: TextFormField(
                          key: const Key('animal_tag_field'),
                          controller: _tagController,
                          decoration: const InputDecoration(
                              labelText: 'Tag Number',
                              labelStyle: TextStyle(fontSize: 20),
                              hintText: 'Enter unique ear tag number'),
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
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        key: const Key('animal_color_tile'),
                        leading: const Icon(Icons.color_lens),
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
                      const SizedBox(height: 20),
                      Semantics(
                        label: 'Type',
                        child: DropdownButtonFormField<String>(
                          key: const Key('animal_type_dropdown'),
                          value: _type,
                          items: ['Sheep', 'Goat']
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _type = val!),
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            labelStyle: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Semantics(
                        label: 'Breed',
                        child: DropdownButtonFormField<String>(
                          key: const Key('animal_breed_field'),
                          value: _breeds.contains(_breedController.text)
                              ? _breedController.text
                              : null,
                          items: _breeds
                              .map((breed) => DropdownMenuItem(
                                    value: breed,
                                    child: Text(breed),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _breedController.text = val ?? '';
                            });
                          },
                          decoration: const InputDecoration(
                              labelText: 'Breed',
                              labelStyle: TextStyle(fontSize: 20),
                              hintText: 'Select breed'),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Semantics(
                        label: 'Birth Date',
                        child: ListTile(
                          key: const Key('animal_birthdate_tile'),
                          title: Text(_birthDate == null
                              ? 'Pick birth date'
                              : 'Birth Date: ${_birthDate!.toLocal().toString().split(' ')[0]}'),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              label: 'Add photo',
                              child: ElevatedButton.icon(
                                key: const Key('animal_camera_button'),
                                onPressed: _isSaving ? null : _takePhoto,
                                icon: const Icon(Icons.camera_alt, size: 32),
                                label: const Text('Camera',
                                    style: TextStyle(fontSize: 20)),
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(180, 56)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Semantics(
                              label: 'Add photo',
                              child: ElevatedButton.icon(
                                key: const Key('animal_select_photos_button'),
                                onPressed: _isSaving ? null : _pickImage,
                                icon: const Icon(Icons.photo_library, size: 32),
                                label: const Text('Select Photos',
                                    style: TextStyle(fontSize: 20)),
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(180, 56)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_imageFiles.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _imageFiles.map((img) {
                            return Stack(
                              children: [
                                Semantics(
                                  label: 'Selected animal photo',
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
                                            () => _imageFiles.remove(img)),
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
                        const SizedBox(height: 24),
                      ],
                      ElevatedButton(
                        key: const Key('animal_save_button'),
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(180, 56)),
                        child: _isSaving
                            ? const SizedBox(
                                width: 28,
                                height: 28,
                                child:
                                    CircularProgressIndicator(strokeWidth: 3))
                            : const Text('Save', style: TextStyle(fontSize: 22)),
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
