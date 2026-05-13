# Twoदो - Premium Collaborative Workspace

A production-ready Flutter app for couples, duos, trios, and teams to collaborate in real-time with shared notes, tasks, files, and more.

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![Flutter](https://img.shields.io/badge/flutter-3.16%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

### Core Features
- **User Authentication**: Email/Password & Google Sign-in
- **Collaborative Spaces**: Create and manage shared workspaces for couples, duos, trios, and teams
- **Real-time Notes**: Collaborative note-taking with rich text support
- **Task Management**: Shared tasks with priorities, due dates, and assignees
- **File Sharing**: Upload and share files with team members
- **Real-time Sync**: Firestore-powered real-time updates across all devices
- **Member Management**: Invite members and manage roles (Admin, Editor, Viewer, Member)
- **Presence Indicators**: See who's online in real-time

### UI/UX
- **Premium Design**: Material 3 with glassmorphism effects
- **Dark Mode**: Full dark mode support with system theme detection
- **Smooth Animations**: Flutter Animate for beautiful transitions and hero animations
- **Responsive Layout**: Mobile, tablet, and web support with adaptive layouts
- **Loading States**: Shimmer loading skeletons for better UX
- **Empty States**: Beautiful empty state designs with actionable hints
- **Accessible**: WCAG compliant with proper contrast and semantic structure

### Advanced Features
- **Emoji Reactions**: React to notes and tasks with emoji
- **Comments**: Threaded conversations on notes and tasks
- **Search**: Full-text search across spaces
- **Activity Feed**: Track all space activities with timestamps
- **Archive System**: Archive notes and tasks
- **Pinned Items**: Pin important notes and tasks to top
- **QR Invite Codes**: Share spaces via QR codes
- **Push Notifications**: FCM-powered notifications
- **Presence System**: Real-time online/offline status

## 🏗️ Architecture

### Clean Architecture Pattern
The app follows clean architecture with separation of concerns:

```
lib/
├── core/                      # Core functionality
│   ├── constants/             # App constants
│   ├── enums/                 # Enums for types, statuses, roles
│   ├── extensions/            # Dart extensions for String, DateTime, etc.
│   ├── theme/                 # App theme, colors, text styles
│   └── utils/                 # Exceptions, validators, helpers
├── data/                      # Data layer
│   ├── datasources/           # Remote and local data sources
│   ├── models/                # Firestore models with serialization
│   └── repositories/          # Repository implementations
├── domain/                    # Domain layer
│   ├── entities/              # Domain entities
│   └── repositories/          # Abstract repository interfaces
├── presentation/              # Presentation layer
│   ├── pages/                 # Feature pages (auth, home, spaces, etc.)
│   ├── providers/             # Riverpod state management
│   └── widgets/               # Reusable UI components
├── routes/                    # Go Router navigation
├── services/                  # Firebase and third-party services
└── main.dart                  # App entry point
```

### State Management
- **Riverpod**: Modern, testable, and powerful state management
- **Async Providers**: Handling loading, success, and error states
- **StateNotifier**: Mutable state containers for complex logic
- **Watchers**: Reactive dependencies and side effects

### Firebase Integration
- **Authentication**: Firebase Auth with email/password and Google Sign-in
- **Firestore**: Real-time database for all data
- **Cloud Storage**: File uploads with image compression
- **Analytics**: Event tracking and user insights
- **Crashlytics**: Crash reporting and monitoring
- **Messaging**: FCM for push notifications

## 🔐 Security

### Firestore Security Rules
- **Role-based Access Control (RBAC)**: Admin, Editor, Viewer, Member roles
- **Member-only Access**: Only space members can access data
- **Space Owner Permissions**: Exclusive permissions for space owners
- **Activity Logging**: All actions are logged for auditing
- **Invite System**: Secure invitation mechanism for adding members

### Firebase Storage
- **User Avatar Uploads**: Profile picture management with ACLs
- **Space Image Uploads**: Space branding and customization
- **File Uploads**: With size limits (50MB) and MIME type validation
- **Download URL Generation**: Temporary URLs with expiration
- **Automatic Cleanup**: TTL-based deletion of temporary files

### Authentication
- **Email/Password Auth**: With validation and strength requirements
- **Google Sign-in**: Secure OAuth 2.0 integration
- **Email Verification**: Optional email verification flow
- **Password Reset**: Secure password recovery mechanism
- **Session Management**: Automatic logout on inactivity

## 📱 Platform Support

- ✅ **Android**: API 24+ (Android 7.0+)
- ✅ **iOS**: 11.0+
- ✅ **Web**: Chrome, Firefox, Safari, Edge
- ✅ **macOS**: 10.14+
- ✅ **Windows**: 10+
- ✅ **Linux**: Ubuntu 18.04+

## 🚀 Getting Started

### Prerequisites
- Flutter 3.16.0 or higher
- Dart 3.11.5 or higher
- Firebase project with Firestore, Storage, and Auth enabled
- Google Cloud project for additional features

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/ProfessorAuggie/TwoDO.git
cd TwoDO
```

2. **Install dependencies**
```bash
flutter pub get
flutter pub global activate build_runner
```

3. **Setup Firebase**
```bash
flutterfire configure
```

4. **Code Generation** (if needed)
```bash
flutter pub run build_runner build
```

5. **Run the app**
```bash
flutter run
```

## 📱 Build Commands

### Android
```bash
# APK for testing
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release

# APK split by architecture
flutter build apk --release --split-per-abi
```

### iOS
```bash
# Build for simulator
flutter build ios --sim --release

# Build for device
flutter build ios --release

# Archive for App Store
flutter build ios --release
```

### Web
```bash
# Build for web
flutter build web --release

# With optimizations
flutter build web --release --web-renderer=auto
```

### Desktop
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/path/to/test.dart
```

### Coverage Report
```bash
flutter test --coverage
lcov --list coverage/lcov.info
```

## 📦 Deployment

### Firebase Hosting (Web)
Automatic deployment via GitHub Actions CI/CD when pushing to main branch.

### Google Play Store (Android)
- Requires Play Store developer account
- Build app bundle: `flutter build appbundle --release`
- Upload via Play Console

### Apple App Store (iOS)
- Requires Apple Developer account
- Build with Xcode or `flutter build ios --release`
- Upload via App Store Connect

## 🔧 Configuration

### Environment Variables
Create a `.env.production` and `.env.dev` file:
```
FIREBASE_PROJECT_ID=twodo-auggie
FIREBASE_WEB_API_KEY=your_api_key
GOOGLE_CLIENT_ID=your_google_client_id
```

### Feature Flags
Control features via constants in `core/constants/app_constants.dart`

### Localization
Multi-language support can be added using `intl` package

## 🎨 Theming

### Color Scheme
- **Primary**: Purple (#7C3AED)
- **Secondary**: Cyan (#06B6D4)
- **Tertiary**: Emerald (#10B981)
- **Error**: Red (#EF4444)
- **Warning**: Amber (#F59E0B)
- **Success**: Green (#10B981)

### Typography
- **Headlines**: Poppins (SemiBold)
- **Body**: Inter (Regular)
- **Labels**: Inter (Bold)

### Dark Mode
Automatic theme selection based on system settings with Material 3 support

## 📚 Documentation

### Generated Documentation
```bash
dart doc
open doc/api/index.html
```

### Additional Guides
- **Architecture**: See clean architecture pattern explanation above
- **Firebase Setup**: Follow Firebase documentation
- **Deployment**: Use CI/CD pipeline or manual deployment

## 🤝 Contributing

### Development Setup
1. Create a feature branch: `git checkout -b feature/amazing-feature`
2. Follow Dart style guide
3. Add tests for new features
4. Run analysis: `flutter analyze`
5. Format code: `dart format .`
6. Commit with clear messages: `git commit -m 'Add amazing feature'`
7. Push and create Pull Request

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `dart format` for automatic formatting
- Run `flutter analyze` before committing
- Maximum line length: 80 characters
- Proper error handling and null safety

## 📝 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) - Amazing framework
- [Firebase](https://firebase.google.com) - Backend services
- [Riverpod](https://riverpod.dev) - State management
- [Material Design](https://material.io) - Design guidelines
- All contributors and users

## 📞 Support

For support:
- 📧 Email: support@twodo.app
- 🐛 GitHub Issues: https://github.com/ProfessorAuggie/TwoDO/issues
- 💬 Discussions: https://github.com/ProfessorAuggie/TwoDO/discussions

## 🗺️ Roadmap

### Version 2.1 (Q3 2024)
- [ ] Video/Audio calls with WebRTC
- [ ] Calendar integration and scheduling
- [ ] Advanced task analytics
- [ ] Custom themes and wallpapers

### Version 2.2 (Q4 2024)
- [ ] Offline-first support with sync
- [ ] Export to PDF/CSV
- [ ] Third-party integrations (Slack, Google Drive, Zapier)
- [ ] Advanced search with filters

### Version 3.0 (2025)
- [ ] AI-powered suggestions
- [ ] Multi-language support (i18n)
- [ ] Mobile app improvements
- [ ] Desktop app refinements
- [ ] Custom domain support

---

**Made with ❤️ by the Twoदो team**

[Website](https://twodo.app) • [GitHub](https://github.com/ProfessorAuggie/TwoDO) • [Twitter](https://twitter.com/twodo_app)
