import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sheepfarm/models/activity_log.dart';
import 'package:sheepfarm/screens/admin_activity_log_screen.dart';
import 'package:sheepfarm/services/database_service.dart';

class FakeDatabaseService extends Fake implements DatabaseService {
  @override
  Stream<List<ActivityLog>> streamActivityLogs({required String farmId}) =>
      Stream.value([
        ActivityLog(
          id: '1',
          action: 'Created',
          entity: 'Animal',
          entityId: '1',
          details: 'Added new sheep',
          performedBy: 'admin',
          timestamp: DateTime(2024, 1, 1),
          farmId: farmId, // Add if required by model
        ),
      ]);
}

void main() {
  if (Platform.isWindows) {
    print(
        'Skipping widget tests on Windows due to Firebase/platform channel limitations.');
    return;
  }

  testWidgets('AdminActivityLogScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AdminActivityLogScreen());
    // Add more expectations for activity log entries, etc.
  });

  testWidgets('AdminActivityLogScreen shows activity log entries',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<DatabaseService>.value(
          value: FakeDatabaseService(),
          child: const AdminActivityLogScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Added new sheep'), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
  });
}
