import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheepfarm/screens/add_animal_screen.dart';

void main() {
  if (Platform.isWindows) {
    print(
        'Skipping widget tests on Windows due to Firebase/platform channel limitations.');
    return;
  }

  testWidgets('AddAnimalScreen shows form and save button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddAnimalScreen()));
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.byType(ElevatedButton), findsWidgets);
    expect(find.textContaining('Add'), findsWidgets);
    // Accessibility: check for color picker and date picker
    expect(find.byIcon(Icons.color_lens), findsWidgets);
    expect(find.byIcon(Icons.calendar_today), findsWidgets);
  });
}
