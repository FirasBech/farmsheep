import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheepfarm/main.dart';
import 'package:sheepfarm/screens/login_screen.dart';
import 'package:sheepfarm/services/auth_service.dart';
import 'package:sheepfarm/services/database_service.dart';

class FakeFirestore extends Fake implements FirebaseFirestore {}

class FakeAuthService extends Fake implements AuthService {}

class FakeDatabaseService extends Fake implements DatabaseService {}

void main() {
  if (Platform.isWindows) {
    print(
        'Skipping widget tests on Windows due to Firebase/platform channel limitations.');
    return;
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
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
