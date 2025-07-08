import 'package:flutter/material.dart';

class FirebaseStorageIssueDialog extends StatelessWidget {
  const FirebaseStorageIssueDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Storage Issue Detected'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Firebase Storage is not properly configured.'),
          SizedBox(height: 8),
          Text('Options:'),
          Text('• Continue without photos (animals will be saved)'),
          Text('• Add photos later when storage is fixed'),
          Text('• Cancel and contact support'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop('cancel'),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop('continue'),
          child: const Text('Continue Without Photos'),
        ),
      ],
    );
  }

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const FirebaseStorageIssueDialog(),
    );
  }
}
