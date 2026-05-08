# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

光序 is a cross-platform Flutter application for students at Xi'an University of Architecture and Technology. It provides course management, scheduling, exam information, grades, campus bus schedules, and more.

## Common Commands

### Development
```bash
flutter pub get                    # Install dependencies
flutter run                        # Run app in debug mode
flutter analyze                    # Run static analysis
dart format .                      # Format all code
```

### Testing
```bash
flutter test                                    # Run all tests
flutter test test/unit/course_model_test.dart  # Run single test file
flutter test --coverage                        # Generate coverage report
scripts/check_coverage.sh                      # Check coverage meets 80% threshold
```

### Platform-Specific Builds
```bash
# Android
flutter build apk --obfuscate --split-debug-info=xx --no-tree-shake-icons --target-platform android-arm64 --split-per-abi

# iOS
flutter build ios

# macOS
flutter build macos

# Web (with WebAssembly)
flutter build web --no-tree-shake-icons --wasm

# Windows (MSIX package for Store)
dart run msix:create --store

```

## Architecture Overview

### State Management
The app uses **GetX** for state management. All stores are registered at app startup in `lib/state/init.dart`:
- `SettingsStore` - App settings and user preferences
- `UserStore` - User authentication and profile data
- `CourseStore` - Course information and schedules
- `ScheduleStore` - Schedule management
- `ElectricityStore` - Electricity usage tracking
- `PaymentStore` - Payment records and analysis
- `BusTileStore` - Campus bus schedules

Access stores via: `SettingsStore.to` or `Get.find<SettingsStore>()`

### Directory Structure

```
lib/
├── core/                 # Platform-agnostic core functionality
│   ├── models/           # Data models (Course, Score, User, etc.)
│   ├── services/         # Core services (network, time, storage)
│   └── utils/            # Utilities (image_load, performance_monitor, request_cache, platform_utils)
├── features/             # Feature modules organized by domain
│   ├── education/        # Education features (courses, grades, login)
│   └── system/           # System features (notifications, updates, widgets)
├── platform/             # Platform-specific implementations
│   ├── android/          # Android services (background, download, widgets)
│   ├── ios/              # iOS background services
│   └── macos/            # macOS UI components (sidebar)
├── routes/               # Navigation and routing configuration
├── state/                # GetX state stores
├── ui/                   # UI layer
│   ├── components/       # Reusable UI components
│   ├── layouts/          # Layout components
│   └── pages/            # Page components
├── main.dart             # App entry point
├── main_app.dart         # Main app widget and navigation
├── bottom_navigation.dart # Mobile bottom navigation
└── modern_sidebar.dart   # Desktop sidebar navigation
```

### Platform Detection and Cross-Platform Support

Use `PlatformUtils` from `lib/core/utils/platform_utils.dart` for platform detection:

```dart
import 'package:ios_club_app/core/utils/platform_utils.dart';

if (PlatformUtils.isWindows) { }
if (PlatformUtils.isMacOS) { }
if (PlatformUtils.isAndroid) { }
if (PlatformUtils.isIOS) { }
if (PlatformUtils.isDesktop) { }  // Windows || macOS || Linux
if (PlatformUtils.isWeb) { }

// For fonts on desktop
fontFamily: PlatformUtils.getWindowsFontFamily()  // Returns '微软雅黑' on Windows
fontFamily: PlatformUtils.getDesktopFontFamily(customFont)  // Returns customFont on desktop
```

### Navigation Architecture

The app has adaptive navigation:
- **Mobile** (iOS/Android): Bottom navigation bar (`BottomNavigation`)
- **Desktop** (Windows/Linux): Modern sidebar (`ModernSidebar`)
- **macOS**: Native macOS sidebar (`MacOSUISidebar`)

Routes are defined in `lib/routes/router.dart` using GetX navigation.

### Service Layer Pattern

Services follow a consistent pattern:
1. **Core Services** (`lib/core/services/`) - Low-level services used across features
   - `net_service.dart` - HTTP networking
   - `time_service.dart` - Time calculations and semester management
   - `xauat_login.dart` - University authentication

2. **Feature Services** (`lib/features/*/services/`) - Business logic services
   - `edu_api_service.dart` - Education system API
   - `auth_service.dart` - Club authentication
   - `notification_service.dart` - Push notifications

Services are typically stateless and inject dependencies. State is managed in GetX stores.

### Platform-Specific Code Organization

Platform-specific implementations live in `lib/platform/`:
- **Android**: Background services, app widgets, download management
- **iOS**: Background tasks, widget extensions
- **macOS**: Native UI components

Platform initialization happens in `main.dart`:
```dart
if (PlatformUtils.isAndroid) {
  await BackgroundService.initializeService();
  await FlutterDisplayMode.setHighRefreshRate();
}
```

### Performance Monitoring

The app includes built-in performance monitoring via `PerformanceMonitor`:
- Tracks widget build times
- Monitors route transitions
- HTTP request timing (integrated with `RequestCache`)

Initialized in `main.dart` before app launch.

## Code Standards

### Import Organization
1. Dart SDK imports (`dart:*`)
2. Flutter SDK imports (`package:flutter/*`)
3. Third-party packages
4. Local imports (`package:ios_club_app/*`)

Use relative imports only within the same module/directory.

### Naming Conventions
- Classes: `PascalCase` (CourseModel, UserService)
- Variables/methods: `camelCase` (courseName, getUserData)
- Constants: `lowerCamelCase` (kIsMPFlutter)
- Private members: prefix with `_` (_initializeData)

### Type Safety
- Always declare explicit types
- Use `final` for immutable variables
- Prefer `const` constructors where possible
- Use null-safety operators (`?.`, `??`, `!`) appropriately

### Error Handling
```dart
try {
  final result = await service.fetchData();
  return result ?? defaultValue;
} catch (e) {
  debugPrint('Error in methodName: $e');
  return defaultValue;  // Prefer returning safe defaults over null
}
```

### Testing Requirements
- Unit tests in `test/unit/` for models and business logic
- Widget tests in `test/widget/` for UI components
- Test names follow "should_X_when_Y" pattern
- **Minimum coverage: 80%** (enforced by `scripts/check_coverage.sh`)

## Environment Configuration

The app uses `.env` file for configuration:
```env
# Update channel options: gitee (default) | appstore
UPDATE_CHANNEL=gitee
```

- `gitee` - Check for updates from Gitee releases
- `appstore` - Disable update checking (for App Store builds)

## Widget Development for Android/iOS

### Android Widgets
Widget provider: `android/app/src/main/kotlin/com/luckyfishisdashen/ios_club_app/TodayCoursesWidgetProvider.kt`
- Displays today's courses on home screen
- Supports dark theme
- Updates via `CourseListRemoteViewsService`

Update widgets from Flutter:
```dart
import 'package:home_widget/home_widget.dart';
await HomeWidget.updateWidget();
```

### iOS Widgets
iOS widget extension located in `ios/` directory with SwiftUI implementation.

## Update Management

Update checking is handled by `CheckUpdateManager`:
- Initialized in `main.dart` after stores
- Android: Shows update dialog on launch if new version available
- Respects `UPDATE_CHANNEL` environment variable
- Uses Gitee releases API for version checking

## Important Notes

1. **Desktop font handling** - Use `PlatformUtils.getDesktopFontFamily()` for consistent font behavior
2. **High refresh rate** - Android automatically sets high refresh rate mode on app launch
3. **Background services** - Android and iOS have separate background service implementations
4. **State persistence** - User preferences stored via `shared_preferences` with keys defined in `lib/state/prefs_keys.dart`
5. **Network caching** - `RequestCache` provides automatic HTTP response caching with TTL
6. **macOS window configuration** - macOS uses native window utilities configured in `_configureMacosWindowUtils()`

## Git Repository

Primary repository: https://gitee.com/luckyfishisdashen/iOSClub.AppMobile.git

## License

MIT License
