#!/usr/bin/env dart
// run_tests_efficiently.dart
// Helper script to run tests with memory leak prevention and better resource management

import 'dart:io';

void main(List<String> args) async {
  print('🧪 Starting efficient test runner...');

  // Check if flutter is available
  final flutterPath = await findFlutterPath();
  if (flutterPath == null) {
    print(
        '❌ Flutter command not found. Please ensure Flutter is in your PATH.');
    print('💡 Alternative: Run tests manually with:');
    print('   flutter test integration_test/a11y_and_edge_cases_test.dart');
    print('   flutter test integration_test/app_flow_test.dart');
    exit(1);
  }

  // Set environment variables to reduce memory usage
  final env = Map<String, String>.from(Platform.environment);
  env['FLUTTER_TEST_TIMEOUT'] = '30'; // 30 second timeout per test
  env['FLUTTER_TEST_MEMORY_LIMIT'] = '2048'; // 2GB memory limit

  final testFiles = [
    'integration_test/a11y_and_edge_cases_test.dart',
    'integration_test/app_flow_test.dart',
  ];

  for (final testFile in testFiles) {
    print('\n📂 Running $testFile...');

    try {
      // Run each test file separately to prevent memory accumulation
      final result = await Process.run(
        flutterPath,
        ['test', testFile, '--dart-define=INTEGRATION_TEST=true'],
        environment: env,
        workingDirectory: Directory.current.path,
      );

      print('Exit code: ${result.exitCode}');
      if (result.stdout.isNotEmpty) {
        print('📤 STDOUT:\n${result.stdout}');
      }
      if (result.stderr.isNotEmpty) {
        print('📥 STDERR:\n${result.stderr}');
      }

      // Small delay between test files to allow cleanup
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      print('❌ Error running $testFile: $e');
    }
  }

  print('\n✅ Test runner complete!');
}

Future<String?> findFlutterPath() async {
  // Try common flutter command variations
  final commands = Platform.isWindows
      ? ['flutter.bat', 'flutter', 'flutter.exe']
      : ['flutter'];

  for (final cmd in commands) {
    try {
      final result = await Process.run(cmd, ['--version'], runInShell: true);
      if (result.exitCode == 0) {
        return cmd;
      }
    } catch (e) {
      // Command not found, try next
    }
  }

  return null;
}
