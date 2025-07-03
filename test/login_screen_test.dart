import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheepfarm/screens/login_screen.dart';

void main() {
  if (Platform.isWindows) {
    print(
        'Skipping widget tests on Windows due to Firebase/platform channel limitations.');
    return;
  }

  testWidgets('LoginScreen shows form fields and login button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsWidgets);
    expect(find.textContaining('Login'), findsWidgets);
    // Accessibility: check for semantics label
    expect(find.bySemanticsLabel('SheepFarm Login'), findsOneWidget);
  });
}
