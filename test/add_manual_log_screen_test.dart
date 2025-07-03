import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheepfarm/screens/add_manual_log_screen.dart';

void main() {
  if (Platform.isWindows) {
    print(
        'Skipping widget tests on Windows due to Firebase/platform channel limitations.');
    return;
  }

  testWidgets('AddManualLogScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddManualLogScreen()));
    // Add more expectations for manual log form, etc.
  });

  testWidgets('AddManualLogScreen shows manual log form',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddManualLogScreen()));
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.byType(ElevatedButton), findsWidgets);
    expect(find.textContaining('Add'), findsWidgets);
  });
}
