# iOS Club App

## Project Overview
This is a cross-platform Flutter application for students at Xi'an University of Architecture and Technology. It provides course management, scheduling, grades, campus bus info, electricity tracking, and more.

## Core Technologies & Architecture
- **Framework:** Flutter (SDK >=3.5.3 <4.0.0)
- **State Management:** Riverpod (`lib/state/`) - Stores are implemented as `Notifier` or `AsyncNotifier` and accessed via `ref.watch()` or `ref.read()`.
- **Networking:** Dio with custom `RequestCache` (`lib/core/services/net_service.dart`).
- **Storage:** Transitioning from `SharedPreferences` to `Hive` and `flutter_secure_storage` for improved performance and security (see `CACHE_IMPROVEMENT_PLAN.md`).

## Directory Structure
- `lib/core/`: Platform-agnostic core functionality (models, services, utils).
- `lib/features/`: Feature modules (education, system) containing their respective services.
- `lib/platform/`: Platform-specific implementations (Android background services, iOS widgets, macOS UI).
- `lib/routes/`: GetX navigation and routing configuration.
- `lib/state/`: GetX state stores (`SettingsStore`, `UserStore`, `CourseStore`, etc.).
- `lib/ui/`: UI components, layouts, and pages.
- `test/`: Contains `unit/` and `widget/` tests.
- `scripts/`: Contains utility scripts for building, testing, and formatting.

## Development Commands
```bash
flutter pub get                    # Install dependencies
flutter run                        # Run app in debug mode
flutter analyze                    # Run static analysis
dart format .                      # Format all code
```

## Testing
- **Run all tests:** `flutter test`
- **Run specific test:** `flutter test test/unit/course_model_test.dart`
- **Generate coverage:** `flutter test --coverage`
- **Check coverage threshold (80%):** `scripts/check_coverage.sh`
- **Naming Pattern:** Tests should follow the "should_X_when_Y" naming pattern.

## Critical Development Conventions

### 1. Platform Detection
Use `PlatformUtils` from `lib/core/utils/platform_utils.dart` for platform detection:
```dart
import 'package:ios_club_app/core/utils/platform_utils.dart';
if (PlatformUtils.isWindows) { ... }
```

### 2. Code Standards
- **Naming:** Classes use `PascalCase`, variables/methods use `camelCase`, private members prefix with `_`.
- **Typing:** Use strict typing and prefer `final` for immutable variables. Use `const` constructors where possible.
- **Imports:** Order: Dart SDK -> Flutter SDK -> Third-party -> Local (relative imports within the same module).
- **Error Handling:** Avoid returning `null`. Catch exceptions, log contextually, and return sensible default values instead.

### 3. State & Services
- **Services** (in `lib/core/services/` or `lib/features/*/services/`) should contain business logic and network calls. They are usually stateless.
- **Stores** (in `lib/state/`) handle application state and reactively update the UI using GetX.

### 4. UI & Navigation
- The app uses adaptive navigation: `BottomNavigation` (Mobile), `ModernSidebar` (Desktop), and native macOS sidebar.
- Desktop typography should utilize `PlatformUtils.getDesktopFontFamily()`.
