import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Animal {
  String id;
  int tagNumber;
  String tagColor;
  String type; // sheep or goat
  String breed;
  DateTime birthDate;
  String farmId;
  List<Map<String, dynamic>> pregnancyHistory;
  List<Map<String, dynamic>> birthLog;
  List<Map<String, dynamic>> healthLogs;
  Map<String, dynamic>? saleInfo;
  List<String>? photoUrls;
  Map<String, dynamic> customFields;

  // Breeder profile fields
  String sex; // 'Female', 'Male', 'Wether', 'Unknown'
  double? currentWeightKg;
  List<Map<String, dynamic>> weightHistory; // [{date, weightKg, notes}]
  String acquisitionType; // 'Born on Farm', 'Purchased', 'Gifted', ''
  String? sireId;
  String? sireName;
  String? damId;
  String? damName;
  double? purchasePrice;
  String? purchaseSource;
  DateTime? purchaseDate;
  double? bcs; // Body Condition Score 1.0–5.0
  String? microchipId;
  String? notes;

  Animal({
    required this.id,
    required this.tagNumber,
    required this.tagColor,
    required this.type,
    required this.breed,
    required this.birthDate,
    required this.farmId,
    this.pregnancyHistory = const [],
    this.birthLog = const [],
    this.healthLogs = const [],
    this.saleInfo,
    this.photoUrls,
    this.customFields = const {},
    this.sex = '',
    this.currentWeightKg,
    this.weightHistory = const [],
    this.acquisitionType = '',
    this.sireId,
    this.sireName,
    this.damId,
    this.damName,
    this.purchasePrice,
    this.purchaseSource,
    this.purchaseDate,
    this.bcs,
    this.microchipId,
    this.notes,
  });

  factory Animal.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Animal(
      id: doc.id,
      tagNumber: data['earTag']['id'],
      tagColor: data['earTag']['color'],
      type: data['type'],
      breed: data['breed'],
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      farmId: data['farmId'],
      pregnancyHistory:
          List<Map<String, dynamic>>.from(data['pregnancyHistory'] ?? []),
      birthLog: List<Map<String, dynamic>>.from(data['birthLog'] ?? []),
      healthLogs: List<Map<String, dynamic>>.from(data['healthLogs'] ?? []),
      saleInfo: data['saleInfo'],
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      customFields: Map<String, dynamic>.from(data['customFields'] ?? {}),
      sex: data['sex'] ?? '',
      currentWeightKg: (data['currentWeightKg'] as num?)?.toDouble(),
      weightHistory:
          List<Map<String, dynamic>>.from(data['weightHistory'] ?? []),
      acquisitionType: data['acquisitionType'] ?? '',
      sireId: data['sireId'],
      sireName: data['sireName'],
      damId: data['damId'],
      damName: data['damName'],
      purchasePrice: (data['purchasePrice'] as num?)?.toDouble(),
      purchaseSource: data['purchaseSource'],
      purchaseDate: data['purchaseDate'] != null
          ? (data['purchaseDate'] as Timestamp).toDate()
          : null,
      bcs: (data['bcs'] as num?)?.toDouble(),
      microchipId: data['microchipId'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() => {
        'earTag': {'id': tagNumber, 'color': tagColor},
        'type': type,
        'breed': breed,
        'birthDate': birthDate,
        'farmId': farmId,
        'pregnancyHistory': pregnancyHistory,
        'birthLog': birthLog,
        'healthLogs': healthLogs,
        if (saleInfo != null) 'saleInfo': saleInfo,
        'photoUrls': photoUrls ?? [],
        'customFields': customFields,
        if (sex.isNotEmpty) 'sex': sex,
        if (currentWeightKg != null) 'currentWeightKg': currentWeightKg,
        if (weightHistory.isNotEmpty) 'weightHistory': weightHistory,
        if (acquisitionType.isNotEmpty) 'acquisitionType': acquisitionType,
        if (sireId != null) 'sireId': sireId,
        if (sireName != null) 'sireName': sireName,
        if (damId != null) 'damId': damId,
        if (damName != null) 'damName': damName,
        if (purchasePrice != null) 'purchasePrice': purchasePrice,
        if (purchaseSource != null) 'purchaseSource': purchaseSource,
        if (purchaseDate != null) 'purchaseDate': purchaseDate,
        if (bcs != null) 'bcs': bcs,
        if (microchipId != null) 'microchipId': microchipId,
        if (notes != null) 'notes': notes,
      };

  String get tagId => tagNumber.toString();
  String get status {
    if (saleInfo != null && saleInfo!['sold'] == true) return 'Sold';
    if (healthLogs.any((log) => log['type'] == 'death')) return 'Dead';
    if (healthLogs.any((log) => log['type'] == 'sick')) return 'Sick';
    if (healthLogs.any((log) => log['type'] == 'quarantined')) {
      return 'Quarantined';
    }
    if (pregnancyHistory.isNotEmpty) return 'Pregnant';
    // Add more logic as needed
    return 'Alive';
  }

  /// Generates a single-page PDF for this animal record.
  Future<Uint8List> generatePdf() async {
    final doc = pw.Document();
    final dateStr =
        '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Animal Record',
                style: pw.TextStyle(
                    fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Divider(),
            pw.SizedBox(height: 12),
            _pdfRow('Tag Number', '#$tagNumber'),
            _pdfRow('Tag Color', tagColor),
            _pdfRow('Type', type),
            _pdfRow('Breed', breed),
            _pdfRow('Birth Date', dateStr),
            _pdfRow('Status', status),
            pw.SizedBox(height: 16),
            if (healthLogs.isNotEmpty) ...[
              pw.Text('Health Logs',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              ...healthLogs.map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                        '• ${h['type'] ?? ''}: ${h['notes'] ?? ''}',
                        style: const pw.TextStyle(fontSize: 11)),
                  )),
              pw.SizedBox(height: 12),
            ],
            if (pregnancyHistory.isNotEmpty) ...[
              pw.Text('Pregnancy History',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              ...pregnancyHistory.map((p) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                        '• Month ${p['month'] ?? ''}, Offspring: ${p['count'] ?? ''}',
                        style: const pw.TextStyle(fontSize: 11)),
                  )),
              pw.SizedBox(height: 12),
            ],
            if (birthLog.isNotEmpty) ...[
              pw.Text('Birth Log',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              ...birthLog.map((b) => pw.Padding(
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

  static pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text('$label:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold,
                    fontSize: 12)),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
