# FarmSheep

## Project Details

- **Project Name**: FarmSheep
- **Project ID**: farmsheep-85d86
- **Project Number**: 269978444014
- **Web API Key**: AIzaSyDDm8TfHIhYV9UuYugXLP3xWru-XN2VL10

A shared farm management app for sheep & goats, featuring:

- Animal records (photos, health & breeding history)
- Manual action logs (feeding, vaccination, treatments)
- Admin audit trail of all create/edit/delete operations)
- Role-based access (admin / partner)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Setup

Use PowerShell from the project root:

```powershell
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for Android, iOS, Web
flutterfire configure --project=farmsheep-85d86 --out=lib/firebase_options.dart --platforms=android,ios,web

# Deploy security rules & indexes
firebase deploy --only firestore:rules,firestore:indexes,storage:rules
```

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com).
2. Enable **Authentication** (Email/Password) and **Cloud Firestore**.
3. Deploy **Security Rules** from `firestore.rules` and **Indexes** from `firestore.indexes.json`:
   ```bash
   firebase deploy --only firestore:rules
   firebase deploy --only firestore:indexes
   ```
4. Install FlutterFire CLI and configure your app:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
5. Make sure `lib/firebase_options.dart` is generated and imported in `main.dart`:
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

## Development

Use PowerShell:

```powershell
# Install dependencies
flutter pub get

# Run on Windows
flutter run -d windows

# Run on Web
flutter run -d chrome
```

## Code Structure

- `lib/services`: AuthService & DatabaseService
- `lib/models`: Animal, ManualLog, ActivityLog
- `lib/providers`: UserProvider (role & auth state)
- `lib/screens`: UI screens (login, dashboard, CRUD, logs)
- `lib/widgets`: Reusable widgets (AuthWrapper, FormSection)

## CI/CD & Documentation

- Automated tests: Run with `flutter test` and integration tests in `integration_test/`.
- CI/CD: Recommended to use GitHub Actions or similar for build, test, and deploy (see ENHANCEMENTS.md for pipeline setup).
- Documentation: See `PROJECT_OVERVIEW.md`, `PROJECT_OVERVIEW_DETAILED.md`, and `ENHANCEMENTS.md` for roadmap, features, and ongoing improvements.
