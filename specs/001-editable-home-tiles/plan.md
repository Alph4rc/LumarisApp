# Implementation Plan: 可编辑和可拖动的首页磁贴

**Branch**: `001-editable-home-tiles` | **Date**: 2026-02-15 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-editable-home-tiles/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Enable users to customize their home page by dragging tiles to reorder them and showing/hiding tiles through an edit mode. The feature provides an intuitive edit mode with visual feedback for drag operations, persistent storage of tile configurations, and consistent behavior across all supported platforms (iOS, Android, macOS, Windows, Linux, Web, WeChat Mini Program).

## Technical Context

**Language/Version**: Dart 3.x with Flutter 3.x (current project standard)
**Primary Dependencies**:
- GetX (state management - existing)
- shared_preferences (local storage - existing via PrefsService)
- reorderable_grid_view ^5.0.0 (NEW - grid drag-and-drop with WeChat fallback)
- flutter_staggered_grid_view (existing - grid layout)
**Storage**: Local storage via shared_preferences (existing TileService infrastructure, extended with TileConfiguration model)
**Testing**: Flutter test framework with widget tests and unit tests (80% coverage requirement)
**Target Platform**: Cross-platform (iOS, Android, macOS, Windows, Linux, Web, WeChat Mini Program)
**Project Type**: Mobile (Flutter cross-platform application)
**Performance Goals**: <100ms drag response time, <100ms storage operations, 60fps animations
**Constraints**: Must work on all 7+ platforms, must use PlatformUtils for platform detection, must integrate with existing TileService, WeChat Mini Program requires tap-based fallback
**Scale/Scope**: Single feature affecting home page only, ~3-5 tile types, minimal data storage (<1KB)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### ✅ I. Platform-First Architecture
- Feature MUST support all platforms (iOS, Android, macOS, Windows, Linux, Web, WeChat Mini Program)
- Platform detection MUST use PlatformUtils (no direct dart:io Platform usage)
- Drag interactions MUST adapt: touch for mobile, mouse for desktop
- Status: COMPLIANT - Spec explicitly requires cross-platform support (FR-012)

### ✅ II. State Management via GetX
- Tile edit state MUST be managed through GetX store
- Store MUST be registered in lib/state/init.dart
- Status: COMPLIANT - Will create TileEditStore or extend existing store

### ✅ III. Test Coverage (NON-NEGOTIABLE)
- MUST maintain 80% code coverage
- Unit tests for tile configuration model and service logic
- Widget tests for drag interactions and edit mode UI
- Status: COMPLIANT - Testing plan included in Phase 1

### ✅ IV. Feature-Based Organization
- Code MUST go in lib/features/system/ (tiles are system feature)
- Models in lib/core/models/ if shared
- Status: COMPLIANT - Existing TileService is in lib/features/system/

### ✅ V. Type Safety and Null Safety
- All code MUST use explicit types and null-safety operators
- Use final for immutability, const constructors where possible
- Status: COMPLIANT - Standard Dart/Flutter practices

### ✅ VI. Performance Monitoring
- MUST integrate with PerformanceMonitor for drag operations
- Profile drag performance to meet <100ms requirement
- Status: COMPLIANT - Will add performance tracking

### ✅ VII. Error Handling and Resilience
- Storage operations MUST have try-catch blocks
- Return safe defaults on errors (empty list or default order)
- Status: COMPLIANT - TileService already follows this pattern

### Platform Compatibility Check
- ✅ Cross-platform UI (mobile/desktop/web/WeChat)
- ✅ Adaptive navigation (already handled by app)
- ✅ PlatformUtils usage (MUST use for all platform checks)
- ✅ Graceful degradation (drag may have platform-specific implementations)

**GATE RESULT**: ✅ PASS - All constitution requirements met. No violations to justify.

## Project Structure

### Documentation (this feature)

```text
specs/001-editable-home-tiles/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   └── tile_service_api.md  # Extended TileService API contract
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── models/
│   │   └── tile_configuration.dart          # NEW: Tile config model
│   └── utils/
│       └── platform_utils.dart               # EXISTING: Platform detection
├── features/
│   └── system/
│       ├── tile_service.dart                 # EXISTING: Extend with config methods
│       └── tile_edit_controller.dart         # NEW: Edit mode state management
├── state/
│   ├── init.dart                             # EXISTING: Register new controller
│   └── prefs_keys.dart                       # EXISTING: Add new keys
└── ui/
    ├── pages/
    │   ├── home_page.dart                    # EXISTING: Minor updates
    │   └── homePages/
    │       └── tiles_widget.dart             # EXISTING: Major updates for drag/edit
    └── components/
        └── tiles/
            ├── editable_tile_wrapper.dart    # NEW: Wrapper for edit mode
            └── tile_edit_controls.dart       # NEW: Edit mode UI controls

test/
├── unit/
│   ├── tile_configuration_test.dart          # NEW: Model tests
│   └── tile_service_test.dart                # NEW: Service tests
└── widget/
    ├── tiles_widget_test.dart                # NEW: Widget tests
    └── tile_edit_controls_test.dart          # NEW: Edit controls tests
```

**Structure Decision**: Flutter mobile application structure. Feature code goes in `lib/features/system/` since tiles are a system-level feature. Models in `lib/core/models/` for reusability. UI components in `lib/ui/` following existing patterns. Tests mirror source structure in `test/` directory.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations. All constitution requirements are met by this feature design.

---

## Phase Completion Status

### ✅ Phase 0: Research (Completed)
- **Output**: `research.md`
- **Key Decisions**:
  - Use reorderable_grid_view package with WeChat fallback
  - Extend TileService with structured configuration
  - Implement platform-specific haptic feedback
  - Use GetX for state management

### ✅ Phase 1: Design & Contracts (Completed)
- **Outputs**:
  - `data-model.md` - TileConfiguration and TileConfigurationList entities
  - `contracts/tile_service_api.md` - Extended TileService API
  - `quickstart.md` - Developer implementation guide
  - `CLAUDE.md` - Updated with new technology stack
- **Key Artifacts**:
  - Data models with serialization
  - Service API contract with 6 new methods
  - Migration strategy from old format
  - Testing requirements and coverage targets

### ⏳ Phase 2: Task Generation (Next Step)
- **Command**: `/speckit.tasks`
- **Expected Output**: `tasks.md` with implementation tasks organized by user story
- **Prerequisites**: All Phase 0 and Phase 1 artifacts complete ✅

---

## Implementation Readiness

**Status**: ✅ READY FOR IMPLEMENTATION

All planning artifacts are complete:
- ✅ Feature specification validated
- ✅ Technical research completed
- ✅ Data models defined
- ✅ API contracts documented
- ✅ Constitution compliance verified
- ✅ Developer quickstart guide created
- ✅ Agent context updated

**Next Steps**:
1. Run `/speckit.tasks` to generate implementation tasks
2. Begin implementation following quickstart.md
3. Maintain 80% test coverage throughout
4. Test on all platforms, especially WeChat Mini Program fallback
