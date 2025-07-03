import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sheepfarm/main.dart';

class FakeFirestore extends Fake implements FirebaseFirestore {}

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
  group('ConnectivityBanner', () {
    testWidgets('shows offline banner when offline',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityStatus>(
          create: (_) {
            final status = ConnectivityStatus();
            status.setOnlineForTest(false);
            return status;
          },
          child: MaterialApp(
            home: ConnectivityBanner(child: Container()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('You are offline. Changes will sync when online.'),
          findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('shows sync indicator when online',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ConnectivityStatus>(
          create: (_) => ConnectivityStatus(),
          child: MaterialApp(
            home: ConnectivityBanner(child: Container()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Should show either spinner or cloud_done icon
      expect(
        find.byWidgetPredicate(
            (w) => w is Icon && (w.icon == Icons.cloud_done)),
        findsOneWidget,
      );
    });
  });
}
