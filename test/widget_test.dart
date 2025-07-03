// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter_test/flutter_test.dart';
import 'package:sheepfarm/main.dart';
import 'package:sheepfarm/screens/login_screen.dart';
import 'package:sheepfarm/services/auth_service.dart';
import 'package:sheepfarm/services/database_service.dart';

class FakeFirestore extends Fake implements FirebaseFirestore {}

class FakeStorage extends Fake implements storage.FirebaseStorage {}

class FakeAuthService extends Fake implements AuthService {}

class FakeDatabaseService extends Fake implements DatabaseService {
  // Add stubs for required methods if needed
}

void main() {
  if (Platform.isWindows) {
    print(
        'Skipping widget tests on Windows due to Firebase/platform channel limitations.');
    return;
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Do not initialize Firebase, mock all Firebase dependencies instead
  });

  testWidgets('Shows login screen when not authenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      authService: FakeAuthService(),
      databaseService: FakeDatabaseService(),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
