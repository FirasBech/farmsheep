import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';

const _supportedLocales = [
  (locale: Locale('en'), label: 'English', flag: '🇬🇧'),
  (locale: Locale('fr'), label: 'Français', flag: '🇫🇷'),
  (locale: Locale('ar'), label: 'العربية (تونسي)', flag: '🇹🇳'),
];

class LanguageSelectorTile extends ConsumerWidget {
  const LanguageSelectorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    final entry = _supportedLocales.firstWhere(
      (e) => e.locale.languageCode == current.languageCode,
      orElse: () => _supportedLocales.first,
    );

    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('Language / Langue / لغة'),
      subtitle: Text('${entry.flag}  ${entry.label}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showPicker(context, ref, current),
    );
  }

  void _showPicker(BuildContext context, WidgetRef ref, Locale current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select Language',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          ..._supportedLocales.map((e) {
            final selected =
                e.locale.languageCode == current.languageCode;
            return ListTile(
              leading: Text(e.flag, style: const TextStyle(fontSize: 28)),
              title: Text(e.label),
              trailing: selected
                  ? const Icon(Icons.check_circle,
                      color: Color(0xFF2E7D32))
                  : null,
              onTap: () {
                ref
                    .read(localeProvider.notifier)
                    .setLocale(e.locale);
                Navigator.pop(ctx);
              },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
