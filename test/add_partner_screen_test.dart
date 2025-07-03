import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheepfarm/screens/add_partner_screen.dart';

void main() {
  if (Platform.isWindows) {
    print(
        'Skipping widget tests on Windows due to Firebase/platform channel limitations.');
    return;
  }

  testWidgets('AddPartnerScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddPartnerScreen()));
    // Add more expectations for partner form, etc.
  });

  testWidgets('AddPartnerScreen shows partner form',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddPartnerScreen()));
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.byType(ElevatedButton), findsWidgets);
    expect(find.textContaining('Add'), findsWidgets);
  });
}
