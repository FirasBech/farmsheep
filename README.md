# FarmSheep

Multi-farm sheep & goat management app built with Flutter + Firebase.

## Features

- Animal records with photos, health history, and breeding logs
- Manual action logs (feeding, vaccination, treatments)
- Admin audit trail of all create / edit / delete operations
- Role-based access (admin / partner)
- Offline support with automatic sync on reconnect
- AI-powered health risk assessment and chat
- Scheduled reminders for health checks
- Animal and log search with CSV export

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase — Firestore, Auth, Storage, Cloud Functions (Node.js)
- **State**: Provider
- **Notifications**: flutter_local_notifications

## Project Structure

```text
lib/
├── models/          # Animal, Farm, ManualLog, ActivityLog, Partner, User
├── providers/       # FarmProvider, UserProvider, AiProvider, ConnectivityProvider
├── screens/         # All UI screens (auth, farm, animal, log, admin, settings)
├── services/        # AuthService, DatabaseService, AiService, NotificationService, ReminderService, OfflineSyncService
├── widgets/         # AuthWrapper, ConnectivityBanner, AiHealthChatSheet, FormSection
├── firebase_options.dart
├── constants.dart
└── main.dart

functions/
└── index.js         # Cloud Functions: aiProxy, createPartner, deleteFarmCascade

android/
├── app/
│   ├── google-services.json   # Android Firebase config (not committed if contains secrets)
│   └── proguard-rules.pro
└── key.properties             # Signing credentials — never commit
```

## Setup

```bash
flutter pub get
flutter run
```

**Firebase deploy:**

```bash
firebase deploy --only firestore:rules,storage,functions
```

## Build

```bash
# Debug
flutter run -d <device>

# Release APK (sideload)
flutter build apk --release --android-skip-build-dependency-validation

# Release AAB (Play Store)
flutter build appbundle --release
```

## Tests

```bash
flutter test
flutter test integration_test/
```
