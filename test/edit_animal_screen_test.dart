import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheepfarm/screens/edit_animal_screen.dart';
import 'package:sheepfarm/models/animal.dart';

void main() {
  if (Platform.isWindows) {
    print(
        'Skipping widget tests on Windows due to Firebase/platform channel limitations.');
    return;
  }

  testWidgets('EditAnimalScreen renders', (WidgetTester tester) async {
    final fakeAnimal = Animal(
      id: '1',
      tagNumber: 123,
      tagColor: '0xFF000000',
      type: 'sheep',
      breed: 'Damani',
      birthDate: DateTime(2020, 1, 1),
      farmId: 'testFarm',
    );
    await tester.pumpWidget(EditAnimalScreen(animal: fakeAnimal));
    // Add more expectations for form fields, update button, etc.
  });

  testWidgets('EditAnimalScreen shows form and update button',
      (WidgetTester tester) async {
    final fakeAnimal = Animal(
      id: '1',
      tagNumber: 123,
      tagColor: '0xFF000000',
      type: 'sheep',
      breed: 'Damani',
      birthDate: DateTime(2020, 1, 1),
      farmId: 'testFarm',
    );
    await tester
        .pumpWidget(MaterialApp(home: EditAnimalScreen(animal: fakeAnimal)));
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.byType(ElevatedButton), findsWidgets);
    expect(find.textContaining('Update'), findsWidgets);
    // Accessibility: check for color picker and date picker
    expect(find.byIcon(Icons.color_lens), findsWidgets);
    expect(find.byIcon(Icons.calendar_today), findsWidgets);
  });
}
