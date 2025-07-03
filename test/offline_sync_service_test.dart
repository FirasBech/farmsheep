// test/offline_sync_service_test.dart
// Unit test for offline/online sync and error state handling in ConnectivityStatus.
import 'package:flutter_test/flutter_test.dart';
import 'package:sheepfarm/main.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  group('ConnectivityStatus', () {
    test('notifies listeners on online/offline change', () {
      final status = ConnectivityStatus();
      bool notified = false;
      status.addListener(() => notified = true);
      status.setOnlineForTest(false);
      expect(status.isOnline, isFalse);
      expect(notified, isTrue);
      notified = false;
      status.setOnlineForTest(true);
      expect(status.isOnline, isTrue);
      expect(notified, isTrue);
    });
  });
}
