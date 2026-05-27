import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/animal.dart';
import 'date_utils.dart' as du;

Future<Uint8List> generateAnimalPdf(Animal animal) async {
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Animal Record',
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Divider(),
          pw.SizedBox(height: 12),
          _row('Tag Number', '#${animal.tagNumber}'),
          _row('Tag Color', animal.tagColor),
          _row('Type', animal.type),
          _row('Breed', animal.breed),
          _row('Birth Date', du.formatDate(animal.birthDate)),
          _row('Status', animal.status),
          pw.SizedBox(height: 16),
          if (animal.healthLogs.isNotEmpty) ...[
            pw.Text('Health Logs',
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            ...animal.healthLogs.map((h) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                      '• ${h['type'] ?? ''}: ${h['notes'] ?? ''}',
                      style: const pw.TextStyle(fontSize: 11)),
                )),
            pw.SizedBox(height: 12),
          ],
          if (animal.pregnancyHistory.isNotEmpty) ...[
            pw.Text('Pregnancy History',
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            ...animal.pregnancyHistory.map((p) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                      '• Month ${p['month'] ?? ''}, Offspring: ${p['count'] ?? ''}',
                      style: const pw.TextStyle(fontSize: 11)),
                )),
            pw.SizedBox(height: 12),
          ],
          if (animal.birthLog.isNotEmpty) ...[
            pw.Text('Birth Log',
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            ...animal.birthLog.map((b) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                      '• Date: ${b['date'] ?? ''}, Offspring: ${b['offspring'] ?? ''}',
                      style: const pw.TextStyle(fontSize: 11)),
                )),
          ],
        ],
      ),
    ),
  );
  return doc.save();
}

pw.Widget _row(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text('$label:',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ),
        pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
      ],
    ),
  );
}
