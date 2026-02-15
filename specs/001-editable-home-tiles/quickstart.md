# Quickstart: 可编辑和可拖动的首页磁贴

**Feature**: Editable Home Tiles
**Date**: 2026-02-15
**Purpose**: Developer guide for implementing and testing the editable tiles feature

## Prerequisites

Before starting development, ensure you have:

- ✅ Flutter SDK 3.x installed
- ✅ Dart SDK 3.x installed
- ✅ iOS Club App repository cloned
- ✅ Branch `001-editable-home-tiles` checked out
- ✅ Dependencies installed (`flutter pub get`)
- ✅ Read the feature specification (`spec.md`)
- ✅ Read the implementation plan (`plan.md`)
- ✅ Read the data model (`data-model.md`)

## Development Setup

### 1. Install New Dependency

Add the drag-and-drop package to `pubspec.yaml`:

```yaml
dependencies:
  # ... existing dependencies ...
  reorderable_grid_view: ^5.0.0  # NEW: Grid drag-and-drop
```

Run:
```bash
flutter pub get
```

### 2. Add New PrefsKeys

Update `lib/state/prefs_keys.dart`:

```dart
class PrefsKeys {
  // ... existing keys ...

  // NEW: Tile configuration storage
  static const String TILE_CONFIGURATIONS = 'tile_configurations';
}
```

### 3. Project Structure Overview

```
lib/
├── core/
│   └── models/
│       └── tile_configuration.dart          # NEW: Create this
├── features/
│   └── system/
│       ├── tile_service.dart                 # EXISTING: Extend this
│       └── tile_edit_controller.dart         # NEW: Create this
├── state/
│   └── init.dart                             # EXISTING: Register controller
└── ui/
    ├── pages/
    │   └── homePages/
    │       └── tiles_widget.dart             # EXISTING: Major updates
    └── components/
        └── tiles/
            ├── editable_tile_wrapper.dart    # NEW: Create this
            └── tile_edit_controls.dart       # NEW: Create this

test/
├── unit/
│   ├── tile_configuration_test.dart          # NEW: Create this
│   └── tile_service_test.dart                # NEW: Create this
└── widget/
    ├── tiles_widget_test.dart                # NEW: Create this
    └── tile_edit_controls_test.dart          # NEW: Create this
```

## Implementation Order

Follow this order to minimize dependencies and enable incremental testing:

### Phase 1: Data Layer (Day 1)

**Goal**: Implement data models and storage

1. **Create TileConfiguration model** (`lib/core/models/tile_configuration.dart`)
   - Define TileConfiguration class
   - Implement toJson() and fromJson()
   - Add validation methods
   - Write unit tests

2. **Create TileConfigurationList model** (same file)
   - Define TileConfigurationList class
   - Implement operations (reorder, toggle, filter)
   - Add serialization
   - Write unit tests

3. **Extend TileService** (`lib/features/system/tile_service.dart`)
   - Add getTileConfigurations()
   - Add saveTileConfigurations()
   - Add reorderTile()
   - Add toggleTileVisibility()
   - Add resetToDefault()
   - Add migration logic
   - Write unit tests

**Validation**: Run unit tests
```bash
flutter test test/unit/tile_configuration_test.dart
flutter test test/unit/tile_service_test.dart
```

### Phase 2: State Management (Day 2)

**Goal**: Implement GetX controller for edit mode

1. **Create TileEditController** (`lib/features/system/tile_edit_controller.dart`)
   - Define reactive state (isEditMode, config)
   - Implement toggleEditMode()
   - Implement reorderTile()
   - Implement toggleVisibility()
   - Add auto-save on exit
   - Write unit tests

2. **Register controller** (`lib/state/init.dart`)
   - Add TileEditController to GetX registration
   - Ensure proper initialization order

**Validation**: Run controller tests
```bash
flutter test test/unit/tile_edit_controller_test.dart
```

### Phase 3: UI Components (Day 3-4)

**Goal**: Build reusable UI components

1. **Create EditableTileWrapper** (`lib/ui/components/tiles/editable_tile_wrapper.dart`)
   - Wrap existing tile widgets
   - Add drag-and-drop support (reorderable_grid_view)
   - Add edit mode visual indicators
   - Add haptic feedback
   - Write widget tests

2. **Create TileEditControls** (`lib/ui/components/tiles/tile_edit_controls.dart`)
   - Edit button in header
   - Done button
   - Hide/show toggle buttons
   - Empty state message
   - Write widget tests

**Validation**: Run widget tests
```bash
flutter test test/widget/editable_tile_wrapper_test.dart
flutter test test/widget/tile_edit_controls_test.dart
```

### Phase 4: Integration (Day 5)

**Goal**: Integrate components into home page

1. **Update TilesWidget** (`lib/ui/pages/homePages/tiles_widget.dart`)
   - Replace GridView with ReorderableGridView
   - Add edit mode toggle
   - Connect to TileEditController
   - Add platform-specific behavior (WeChat fallback)
   - Write widget tests

2. **Update HomePage** (`lib/ui/pages/home_page.dart`)
   - Minor updates if needed
   - Ensure edit mode state is preserved

**Validation**: Manual testing on device/simulator
```bash
flutter run
```

### Phase 5: Testing & Polish (Day 6-7)

**Goal**: Comprehensive testing and refinement

1. **Cross-platform testing**
   - Test on iOS simulator
   - Test on Android emulator
   - Test on desktop (Windows/macOS)
   - Test on web browser
   - Test on WeChat Mini Program (if available)

2. **Performance testing**
   - Profile drag operations
   - Verify <100ms response time
   - Check 60fps animations
   - Monitor storage operations

3. **Edge case testing**
   - Hide all tiles
   - Drag with single tile
   - Rapid drag operations
   - Screen rotation during drag
   - App backgrounding during drag

4. **Coverage check**
   ```bash
   flutter test --coverage
   scripts/check_coverage.sh
   ```
   - Ensure 80% coverage threshold met

## Running Tests

### Unit Tests Only
```bash
flutter test test/unit/
```

### Widget Tests Only
```bash
flutter test test/widget/
```

### All Tests
```bash
flutter test
```

### With Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # View coverage report
```

### Coverage Threshold Check
```bash
scripts/check_coverage.sh
```

## Manual Testing Checklist

### Basic Functionality
- [ ] Enter edit mode via edit button
- [ ] Exit edit mode via done button
- [ ] Drag tile to new position (mobile)
- [ ] Drag tile to new position (desktop)
- [ ] Hide a tile
- [ ] Show a hidden tile
- [ ] Configuration persists after app restart

### Edge Cases
- [ ] Hide all tiles (should show warning)
- [ ] Drag with only one tile
- [ ] Rapid consecutive drags
- [ ] Screen rotation during drag
- [ ] App backgrounding during drag
- [ ] Invalid data in storage (should reset to default)

### Platform-Specific
- [ ] iOS: Haptic feedback on drag
- [ ] Android: Haptic feedback on drag
- [ ] Desktop: Mouse drag works
- [ ] Web: Drag works in browser
- [ ] WeChat MP: Fallback UI works (if available)

### Performance
- [ ] Drag response <100ms
- [ ] Animations at 60fps
- [ ] Storage operations <100ms
- [ ] No UI lag during edit mode

## Debugging Tips

### Enable Debug Logging

Add to TileService:
```dart
static const bool _debug = true;

static void _log(String message) {
  if (_debug) {
    debugPrint('[TileService] $message');
  }
}
```

### Inspect Storage

```dart
// In debug console or test
final prefs = await SharedPreferences.getInstance();
final configJson = prefs.getString(PrefsKeys.TILE_CONFIGURATIONS);
print('Stored config: $configJson');
```

### Performance Profiling

```dart
import 'package:ios_club_app/core/utils/performance_monitor.dart';

// Wrap drag operations
PerformanceMonitor.startOperation('tile_drag');
// ... drag logic ...
PerformanceMonitor.endOperation('tile_drag');
```

### Platform Detection

```dart
import 'package:ios_club_app/core/utils/platform_utils.dart';

print('Platform: ${PlatformUtils.currentPlatform}');
print('Is MPFlutter: ${PlatformUtils.isMPFlutter}');
```

## Common Issues & Solutions

### Issue: Drag not working on WeChat Mini Program

**Solution**: Ensure fallback UI is implemented
```dart
if (PlatformUtils.isMPFlutter) {
  return _buildTapReorderGrid();  // Fallback
} else {
  return ReorderableGridView.builder(...);  // Full drag
}
```

### Issue: Configuration not persisting

**Solution**: Check PrefsKeys constant and storage permissions
```dart
// Verify key is correct
print(PrefsKeys.TILE_CONFIGURATIONS);

// Check if save is called
await TileService.saveTileConfigurations(config);
print('Saved successfully');
```

### Issue: Duplicate orders after reorder

**Solution**: Normalize orders after reorder
```dart
void _normalizeOrders() {
  final visible = getVisibleTiles();
  for (int i = 0; i < visible.length; i++) {
    visible[i].order = i;
  }
}
```

### Issue: Tests failing with GetX errors

**Solution**: Initialize GetX in test setup
```dart
setUp(() {
  Get.testMode = true;
  Get.put(TileEditController());
});

tearDown(() {
  Get.reset();
});
```

## Code Style Guidelines

Follow existing project conventions:

### Import Order
```dart
// 1. Dart SDK
import 'dart:convert';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:get/get.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

// 4. Local imports
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
```

### Naming Conventions
- Classes: `PascalCase` (TileConfiguration)
- Variables: `camelCase` (isEditMode)
- Constants: `lowerCamelCase` (kDefaultTiles)
- Private: `_prefixWithUnderscore` (_loadConfig)

### Type Safety
```dart
// ✅ Good: Explicit types
final List<TileConfiguration> tiles = [];
final bool isEditMode = false;

// ❌ Bad: Implicit types
var tiles = [];
var isEditMode = false;
```

### Null Safety
```dart
// ✅ Good: Safe operators
final config = await TileService.getTileConfigurations();
final firstTile = config.configurations.firstOrNull;

// ❌ Bad: Force unwrap
final firstTile = config.configurations.first!;
```

## Performance Targets

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Drag response time | <100ms | PerformanceMonitor |
| Animation frame rate | 60fps | Flutter DevTools |
| Storage read | <50ms | Stopwatch in code |
| Storage write | <100ms | Stopwatch in code |
| Test coverage | ≥80% | check_coverage.sh |

## Next Steps

After completing implementation:

1. **Generate tasks** (if not already done):
   ```bash
   /speckit.tasks
   ```

2. **Create pull request**:
   - Ensure all tests pass
   - Verify coverage ≥80%
   - Run `flutter analyze` (no errors)
   - Run `dart format .`
   - Test on at least 3 platforms

3. **Documentation**:
   - Update CHANGELOG.md
   - Add feature to README.md (if user-facing)
   - Document any breaking changes

4. **Deployment**:
   - Follow project deployment process
   - Test on production-like environment
   - Monitor for errors after release

## Resources

- **Feature Spec**: `specs/001-editable-home-tiles/spec.md`
- **Implementation Plan**: `specs/001-editable-home-tiles/plan.md`
- **Data Model**: `specs/001-editable-home-tiles/data-model.md`
- **API Contract**: `specs/001-editable-home-tiles/contracts/tile_service_api.md`
- **Research**: `specs/001-editable-home-tiles/research.md`
- **Project Constitution**: `.specify/memory/constitution.md`
- **Project Guide**: `CLAUDE.md`

## Support

If you encounter issues:

1. Check this quickstart guide
2. Review the research.md for technical decisions
3. Check existing code patterns in the project
4. Consult the project constitution for architectural guidance
5. Ask team members or create an issue

Happy coding! 🚀
