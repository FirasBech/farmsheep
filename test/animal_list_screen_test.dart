import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sheepfarm/models/animal.dart';
import 'package:sheepfarm/screens/animal_list_screen.dart';
import 'package:sheepfarm/services/database_service.dart';

class FakeDatabaseService extends Fake implements DatabaseService {
  @override
  Stream<List<Animal>> streamAnimals({required String farmId}) => Stream.value([
        Animal(
          id: '1',
          tagNumber: 101,
          tagColor: '0xFF000000',
          type: 'sheep',
          breed: 'Damani',
          birthDate: DateTime(2020, 1, 1),
          farmId: farmId,
        ),
      ]);
}

void main() {
  if (Platform.isWindows) {
    print(
        'Skipping widget tests on Windows due to Firebase/platform channel limitations.');
    return;
  }

  testWidgets('AnimalListScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AnimalListScreen());
    // Add more expectations for animal cards, buttons, etc.
    expect(find.text('Animals'), findsOneWidget);
  });

  testWidgets('AnimalListScreen shows animal cards and taps',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<DatabaseService>.value(
          value: FakeDatabaseService(),
          child: const AnimalListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Animals'), findsOneWidget);
    expect(find.textContaining('Damani'), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
    // Simulate tap on the first animal card
    await tester.tap(find.byType(Card).first);
    // No navigation will occur in this test context, but tap is triggered
  });
}
