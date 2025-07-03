import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sheepfarm/models/manual_log.dart';
import 'package:sheepfarm/screens/log_history_screen.dart';
import 'package:sheepfarm/services/database_service.dart';

class FakeDatabaseService extends Fake implements DatabaseService {
  @override
  Stream<List<ManualLog>> streamManualLogs({required String farmId}) =>
      Stream.value([
        ManualLog(
          id: '1',
          type: 'Health',
          notes: 'Vaccinated',
          performedBy: 'admin',
          timestamp: DateTime(2024, 1, 1),
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

  testWidgets('LogHistoryScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const LogHistoryScreen());
    // Add more expectations for log entries, etc.
  });

  testWidgets('LogHistoryScreen shows log entries',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<DatabaseService>.value(
          value: FakeDatabaseService(),
          child: const LogHistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Manual Logs'), findsOneWidget);
    expect(find.textContaining('Vaccinated'), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
  });
}
