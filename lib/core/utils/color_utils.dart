import 'package:flutter/material.dart';

Color parseTagColor(String colorHex) {
  try {
    final hex = colorHex
        .replaceAll('#', '')
        .replaceAll('0x', '')
        .replaceAll('0X', '');
    return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
  } catch (_) {
    return Colors.grey;
  }
}

Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'alive':
      return const Color(0xFF2E7D32);
    case 'pregnant':
      return Colors.blue;
    case 'sold':
      return Colors.orange;
    case 'dead':
      return Colors.red;
    case 'sick':
      return Colors.amber;
    case 'quarantined':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

String colorToHex(Color color) =>
    '0x${color.toARGB32().toRadixString(16).padLeft(8, '0')}';
