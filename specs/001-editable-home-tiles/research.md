# Research: 可编辑和可拖动的首页磁贴

**Date**: 2026-02-15
**Feature**: Editable Home Tiles
**Purpose**: Resolve technical unknowns and establish implementation approach

## Research Questions

### Q1: Which drag-and-drop package should we use for grid reordering?

**Decision**: Use **reorderable_grid_view** package with custom fallback for WeChat Mini Program

**Rationale**:
1. **Primary Solution**: `reorderable_grid_view` (v5.0.0+) provides purpose-built grid reordering with:
   - Cross-platform support (iOS, Android, Web, Desktop)
   - Touch and mouse input handling
   - Smooth built-in animations
   - Simple API similar to GridView
   - Active maintenance

2. **Fallback for WeChat Mini Program**: Custom tap-based reordering
   - MPFlutter has limited widget support for Draggable/DragTarget
   - Tap-to-select + tap-to-place provides reliable alternative
   - Uses existing PlatformUtils.isMPFlutter detection

3. **Project Alignment**:
   - Project already uses `flutter_staggered_grid_view` successfully
   - Follows existing pattern of platform-specific implementations
   - Integrates cleanly with GetX state management

**Alternatives Considered**:
- **flutter_reorderable_grid_view**: Less mature, fewer features
- **Custom Draggable/DragTarget**: High complexity, uncertain MPFlutter support
- **flutter_staggered_grid_view's ReorderableGridView**: Overkill for uniform grids

**Implementation Strategy**:
```dart
if (!PlatformUtils.isMPFlutter) {
  // Use reorderable_grid_view for full Flutter platforms
  return ReorderableGridView.builder(...);
} else {
  // Use tap-based reordering for WeChat Mini Program
  return _buildTapReorderGrid();
}
```

### Q2: How should we implement edit mode UI patterns?

**Decision**: Use animated state transitions with visual indicators

**Best Practices**:
1. **Edit Mode Toggle**:
   - Button in AppBar or next to section title
   - Text changes: "编辑" ↔ "完成"
   - Haptic feedback on mode change (mobile only)

2. **Visual Indicators**:
   - Wiggle animation on tiles (iOS-style, optional)
   - Show/hide controls (delete badges, drag handles)
   - Dimmed background or overlay effect
   - AnimatedSwitcher for smooth transitions

3. **State Management**:
   - Boolean flag in GetX controller: `isEditMode`
   - Reactive UI updates via Obx widgets
   - Auto-save on mode exit

**Example Pattern**:
```dart
class TileEditController extends GetxController {
  final RxBool isEditMode = false.obs;

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (isEditMode.value && !PlatformUtils.isMPFlutter) {
      HapticFeedback.mediumImpact();
    }
    if (!isEditMode.value) {
      saveTileConfiguration();
    }
  }
}
```

### Q3: How should we implement haptic feedback?

**Decision**: Platform-specific haptic feedback using Flutter's HapticFeedback API

**Implementation**:
```dart
class HapticHelper {
  static Future<void> lightImpact() async {
    if (PlatformUtils.isIOS || PlatformUtils.isAndroid) {
      await HapticFeedback.lightImpact();
    }
  }

  static Future<void> mediumImpact() async {
    if (PlatformUtils.isIOS || PlatformUtils.isAndroid) {
      await HapticFeedback.mediumImpact();
    }
  }
}
```

**Usage Points**:
- **Drag Start**: Medium impact when user begins dragging
- **Drag End**: Light impact when tile is dropped
- **Edit Mode Toggle**: Medium impact when entering/exiting edit mode
- **Hide/Show Tile**: Selection click when toggling visibility

**Platform Support**:
- iOS: Full support (light, medium, heavy, selection)
- Android: Full support
- Desktop/Web: No-op (gracefully ignored)
- WeChat Mini Program: No-op

### Q4: How should we persist tile configuration?

**Decision**: Extend existing TileService with structured configuration storage

**Current State**:
- Project uses `shared_preferences: ^2.5.3`
- TileService already has `getTiles()` and `setTiles()` methods
- PrefsService wrapper provides centralized access
- PrefsKeys defines all storage keys

**Enhancement Approach**:
1. **Data Structure**:
```dart
class TileConfiguration {
  final String id;           // "电费", "校车", "饭卡"
  final int order;           // Display order (0, 1, 2, ...)
  final bool isVisible;      // Show/hide state

  Map<String, dynamic> toJson();
  factory TileConfiguration.fromJson(Map<String, dynamic> json);
}
```

2. **Storage Format**:
```dart
// Store as JSON string in shared_preferences
// Key: PrefsKeys.TILE_CONFIGURATIONS
// Value: '[{"id":"电费","order":0,"isVisible":true}, ...]'
```

3. **Service Methods**:
```dart
class TileService {
  // Existing methods
  static Future<List<String>> getTiles() async { ... }
  static Future<void> setTiles(List<String> map) async { ... }

  // New methods
  static Future<List<TileConfiguration>> getTileConfigurations() async { ... }
  static Future<void> saveTileConfigurations(List<TileConfiguration> configs) async { ... }
  static Future<void> reorderTile(String tileId, int newIndex) async { ... }
  static Future<void> toggleTileVisibility(String tileId) async { ... }
}
```

**Migration Strategy**:
- Keep existing `getTiles()` for backward compatibility
- New code uses `getTileConfigurations()`
- First run: migrate from old format to new format
- Default configuration if no saved data exists

### Q5: How should we implement smooth animations?

**Decision**: Use Flutter's built-in animation widgets with performance monitoring

**Animation Types**:

1. **Drag Animations** (handled by reorderable_grid_view):
   - Scale up slightly when dragging (1.0 → 1.1)
   - Shadow/elevation increase
   - Smooth position transitions for other tiles

2. **Edit Mode Transitions**:
```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: isEditMode ? _buildEditGrid() : _buildNormalGrid(),
)
```

3. **Tile Visibility Changes**:
```dart
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 200),
  child: tile,
)
```

4. **Wiggle Animation** (optional, iOS-style):
```dart
class WiggleAnimation extends StatefulWidget {
  final Widget child;
  final bool enabled;

  // Subtle rotation animation: -2° to +2°
  // Duration: 300ms, repeating
}
```

**Performance Considerations**:
- Use `const` constructors where possible
- Avoid rebuilding entire grid on drag
- Profile with PerformanceMonitor
- Target: 60fps on all platforms, <100ms response time

## Technology Stack Summary

**New Dependencies**:
```yaml
dependencies:
  reorderable_grid_view: ^5.0.0  # Grid reordering with drag-and-drop
```

**Existing Dependencies** (no changes needed):
- GetX: State management
- shared_preferences: Local storage
- flutter_staggered_grid_view: Grid layout (already used)

**Platform Support Matrix**:

| Feature | iOS | Android | macOS | Windows | Linux | Web | WeChat MP |
|---------|-----|---------|-------|---------|-------|-----|-----------|
| Drag-and-drop | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ Fallback |
| Haptic feedback | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Edit mode UI | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Persistence | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Animations | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

## Implementation Risks and Mitigations

### Risk 1: WeChat Mini Program Compatibility
**Risk**: reorderable_grid_view may not work in MPFlutter environment
**Mitigation**: Implement tap-based fallback, test early in WeChat environment
**Severity**: Medium
**Status**: Mitigated by design

### Risk 2: Performance on Low-End Devices
**Risk**: Drag animations may lag on older devices
**Mitigation**: Profile with PerformanceMonitor, optimize animations, reduce complexity if needed
**Severity**: Low
**Status**: Monitoring required

### Risk 3: Data Migration
**Risk**: Existing users have tile data in old format
**Mitigation**: Implement migration logic in TileService, maintain backward compatibility
**Severity**: Low
**Status**: Mitigated by design

## Next Steps

1. **Phase 1: Design**
   - Create data-model.md with TileConfiguration schema
   - Define TileService API contract
   - Create quickstart.md for development setup

2. **Phase 2: Implementation** (via /speckit.tasks)
   - Add reorderable_grid_view dependency
   - Implement TileConfiguration model
   - Extend TileService with new methods
   - Create TileEditController
   - Update TilesWidget with drag-and-drop
   - Implement edit mode UI
   - Add tests (80% coverage)

3. **Phase 3: Testing**
   - Unit tests for models and services
   - Widget tests for UI components
   - Manual testing on all platforms
   - WeChat Mini Program fallback testing
   - Performance profiling
