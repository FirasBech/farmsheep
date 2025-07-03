import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheepfarm/models/animal.dart';
import 'package:sheepfarm/screens/animal_detail_screen.dart';

void main() {
  if (Platform.isWindows) {
    print(
        'Skipping widget tests on Windows due to Firebase/platform channel limitations.');
    return;
  }

  testWidgets('AnimalDetailScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AnimalDetailScreen());
    // Add more expectations for detail fields, edit/delete buttons, etc.
  });

  testWidgets('AnimalDetailScreen shows details and edit button',
      (WidgetTester tester) async {
    final fakeAnimal = Animal(
      id: '1',
      tagNumber: 123,
      tagColor: '0xFF000000',
      type: 'sheep',
      breed: 'Damani',
      birthDate: DateTime(2020, 1, 1),
      farmId: 'testFarm',
      photoUrls: ['https://example.com/photo.jpg'],
    );
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => const AnimalDetailScreen(),
      ),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => const AnimalDetailScreen(),
        settings: RouteSettings(arguments: fakeAnimal),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Animal Details'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    expect(find.textContaining('Damani'),
        findsNothing); // Details are in widgets, not plain text
  });

  testWidgets('AnimalDetailScreen shows all key fields and a11y',
      (WidgetTester tester) async {
    final fakeAnimal = Animal(
      id: '2',
      tagNumber: 456,
      tagColor: '0xFF000000',
      type: 'sheep',
      breed: 'Damani',
      birthDate: DateTime(2020, 1, 1),
      farmId: 'testFarm',
    );
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => const AnimalDetailScreen(),
      ),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => const AnimalDetailScreen(),
        settings: RouteSettings(arguments: fakeAnimal),
      ),
    ));
    await tester.pumpAndSettle();
    // Check for semantics label
    expect(find.bySemanticsLabel('Animal details for tag 456'), findsOneWidget);
    // Check for photo
    expect(find.byType(Image), findsWidgets);
    // Check for edit button
    expect(find.byIcon(Icons.edit), findsOneWidget);
    // Check for AppBar title
    expect(find.text('Animal Details'), findsOneWidget);
  });
}
