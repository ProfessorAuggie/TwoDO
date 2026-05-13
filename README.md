# TwoDO

TwoDO is a collaborative Flutter workspace app for couples, duos, trios, and small teams. It focuses on shared notes, tasks, files, and real-time sync backed by Firebase.

## What it does

- Shared workspaces with member roles and invite flows
- Real-time notes and task management
- File sharing with Firebase Storage
- Authentication with Firebase Auth and social sign-in
- Cross-platform support for mobile, web, and desktop

## Tech Stack

- Flutter and Dart
- Firebase Auth, Firestore, Storage, Messaging, Analytics, and Crashlytics
- Riverpod for state management
- GoRouter for navigation
- Flutter Quill, Flutter Animate, Shimmer, and cached_network_image for the UI layer

## Project Layout

- `lib/core/` for constants, enums, extensions, theme, and utilities
- `lib/data/` for data sources, models, and repository implementations
- `lib/domain/` for entities and repository contracts
- `lib/presentation/` for pages, providers, and widgets
- `lib/routes/` for routing setup
- `lib/services/` for Firebase and app services
- `firestore.rules` and `firebase.json` for Firebase configuration

## Requirements

- Flutter 3.16 or newer
- Dart 3.11 or newer
- A Firebase project with Auth, Firestore, and Storage enabled

## Setup

1. Install dependencies.

```bash
flutter pub get
```

2. Configure Firebase if you are setting up a new environment.

```bash
flutterfire configure
```

3. Run code generation if your changes need it.

```bash
flutter pub run build_runner build
```

4. Start the app.

```bash
flutter run
```

## Useful Commands

```bash
flutter test
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
flutter build web --release
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

## Notes

- The app is configured for multiple platforms, but platform-specific setup still depends on your Firebase project and local toolchain.
- Refer to [README_PRODUCTION.md](README_PRODUCTION.md) for the longer deployment and production checklist.
- Refer to [PHASE2_DOCUMENTATION.md](PHASE2_DOCUMENTATION.md) and [COMPLETE_DOCUMENTATION.md](COMPLETE_DOCUMENTATION.md) for deeper implementation details.
