import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/animal.dart';
import '../../models/manual_log.dart';

Future<void> exportAnimalsCsv(List<Animal> animals) async {
  final csv = StringBuffer();
  csv.writeln('Tag Number,Tag Color,Type,Breed,Birth Date,Status');
  for (final a in animals) {
    csv.writeln(
        '${a.tagNumber},${a.tagColor},${a.type},${a.breed},${a.birthDate.toIso8601String()},${a.status}');
  }
  await _shareOrSave(csv.toString(), 'animals_export');
}

Future<void> exportLogsCsv(List<ManualLog> logs) async {
  final csv = StringBuffer();
  csv.writeln('Type,Timestamp,Animal IDs,Notes,Performed By');
  for (final l in logs) {
    csv.writeln(
        '${l.type},${l.timestamp.toIso8601String()},${l.animalIds?.join(";") ?? ''},"${l.notes.replaceAll('"', '""')}",${l.performedBy}');
  }
  await _shareOrSave(csv.toString(), 'logs_export');
}

Future<void> _shareOrSave(String content, String baseName) async {
  try {
    await SharePlus.instance.share(
      ShareParams(text: content, subject: baseName),
    );
  } catch (_) {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/${baseName}_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(content);
  }
}
