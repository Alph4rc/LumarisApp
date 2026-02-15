# Tasks: 可编辑和可拖动的首页磁贴

**Input**: Design documents from `/specs/001-editable-home-tiles/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), data-model.md, contracts/, research.md, quickstart.md

**Tests**: Tests are included as this feature requires 80% coverage per constitution requirements.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter project**: `lib/`, `test/` at repository root
- Paths shown below use absolute paths from project root

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and dependency setup

- [x] T001 Add reorderable_grid_view dependency (^5.0.0) to pubspec.yaml
- [x] T002 Run flutter pub get to install dependencies
- [x] T003 Add TILE_CONFIGURATIONS key to lib/state/prefs_keys.dart

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data models and service infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 [P] Create TileConfiguration model with toJson/fromJson in lib/core/models/tile_configuration.dart
- [x] T005 [P] Create TileConfigurationList model with operations in lib/core/models/tile_configuration.dart
- [x] T006 [P] Write unit tests for TileConfiguration serialization in test/unit/tile_configuration_test.dart
- [x] T007 [P] Write unit tests for TileConfigurationList operations in test/unit/tile_configuration_test.dart
- [x] T008 Extend TileService with getTileConfigurations() method in lib/features/system/tile_service.dart
- [x] T009 Extend TileService with saveTileConfigurations() method in lib/features/system/tile_service.dart
- [x] T010 Extend TileService with reorderTile() method in lib/features/system/tile_service.dart
- [x] T011 Extend TileService with toggleTileVisibility() method in lib/features/system/tile_service.dart
- [x] T012 Extend TileService with resetToDefault() method in lib/features/system/tile_service.dart
- [x] T013 Extend TileService with getAvailableTiles() method in lib/features/system/tile_service.dart
- [x] T014 Add migration logic from old format to new format in lib/features/system/tile_service.dart
- [x] T015 [P] Write unit tests for TileService methods in test/unit/tile_service_test.dart
- [x] T016 [P] Write unit tests for migration logic in test/unit/tile_service_test.dart
- [x] T017 Create TileEditController with GetX reactive state in lib/features/system/tile_edit_controller.dart
- [x] T018 Implement toggleEditMode() in TileEditController in lib/features/system/tile_edit_controller.dart
- [x] T019 Implement reorderTile() in TileEditController in lib/features/system/tile_edit_controller.dart
- [x] T020 Implement toggleVisibility() in TileEditController in lib/features/system/tile_edit_controller.dart
- [x] T021 Add auto-save on edit mode exit in TileEditController in lib/features/system/tile_edit_controller.dart
- [x] T022 Register TileEditController in GetX initialization in lib/state/init.dart
- [x] T023 [P] Write unit tests for TileEditController in test/unit/tile_edit_controller_test.dart

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 3 - 编辑模式入口和退出 (Priority: P1) 🎯 MVP Foundation

**Goal**: Provide clear entry/exit points for edit mode so users can switch between normal and edit states

**Independent Test**: User can click edit button to enter edit mode, see visual indicators, and click done button to exit with changes saved

### Implementation for User Story 3

- [x] T024 [P] [US3] Create TileEditControls component with edit/done button in lib/ui/components/tiles/tile_edit_controls.dart
- [x] T025 [P] [US3] Add edit mode visual indicators (button states, animations) in lib/ui/components/tiles/tile_edit_controls.dart
- [x] T026 [US3] Connect TileEditControls to TileEditController in lib/ui/components/tiles/tile_edit_controls.dart
- [x] T027 [US3] Add haptic feedback on mode toggle using PlatformUtils in lib/ui/components/tiles/tile_edit_controls.dart
- [x] T028 [US3] Implement auto-exit on navigation away in lib/ui/pages/homePages/tiles_widget.dart
- [x] T029 [US3] Implement auto-exit after 30 seconds of inactivity in lib/features/system/tile_edit_controller.dart
- [x] T030 [P] [US3] Write widget tests for TileEditControls in test/widget/tile_edit_controls_test.dart
- [x] T031 [P] [US3] Write widget tests for edit mode transitions in test/widget/tile_edit_controls_test.dart

**Checkpoint**: Edit mode entry/exit is functional and testable independently

---

## Phase 4: User Story 1 - 拖动磁贴重新排序 (Priority: P1) 🎯 MVP Core

**Goal**: Enable users to drag tiles to reorder them with visual feedback and persistent storage

**Independent Test**: User can long-press any tile, drag to new position, release, and see order change immediately and persist after app restart

### Implementation for User Story 1

- [x] T032 [P] [US1] Create EditableTileWrapper component in lib/ui/components/tiles/editable_tile_wrapper.dart
- [x] T033 [US1] Integrate ReorderableGridView in TilesWidget for full Flutter platforms in lib/ui/pages/homePages/tiles_widget.dart
- [x] T034 [US1] Implement tap-based reordering fallback for WeChat Mini Program in lib/ui/pages/homePages/tiles_widget.dart
- [x] T035 [US1] Add platform detection using PlatformUtils for drag vs tap mode in lib/ui/pages/homePages/tiles_widget.dart
- [x] T036 [US1] Add drag visual feedback (scale, shadow, elevation) in lib/ui/components/tiles/editable_tile_wrapper.dart
- [x] T037 [US1] Add haptic feedback on drag start/end for mobile platforms in lib/ui/components/tiles/editable_tile_wrapper.dart
- [x] T038 [US1] Connect drag events to TileEditController.reorderTile() in lib/ui/pages/homePages/tiles_widget.dart
- [x] T039 [US1] Add performance monitoring for drag operations in lib/ui/pages/homePages/tiles_widget.dart
- [x] T040 [US1] Handle edge cases (screen rotation, app backgrounding) in lib/ui/pages/homePages/tiles_widget.dart
- [x] T041 [P] [US1] Write widget tests for drag interactions in test/widget/tiles_widget_test.dart
- [x] T042 [P] [US1] Write widget tests for platform-specific behavior in test/widget/tiles_widget_test.dart
- [x] T043 [P] [US1] Write widget tests for visual feedback in test/widget/editable_tile_wrapper_test.dart

**Checkpoint**: Drag-to-reorder is fully functional and testable independently

---

## Phase 5: User Story 2 - 显示/隐藏磁贴 (Priority: P2)

**Goal**: Allow users to hide unwanted tiles and show them again through edit mode

**Independent Test**: User can enter edit mode, hide a tile (it disappears), and show it again (it reappears at the end)

### Implementation for User Story 2

- [x] T044 [P] [US2] Add hide/show toggle buttons to tiles in edit mode in lib/ui/components/tiles/editable_tile_wrapper.dart
- [x] T045 [P] [US2] Create available tiles list view for edit mode in lib/ui/components/tiles/tile_edit_controls.dart
- [x] T046 [US2] Connect hide/show buttons to TileEditController.toggleVisibility() in lib/ui/components/tiles/editable_tile_wrapper.dart
- [x] T047 [US2] Filter visible tiles in TilesWidget based on configuration in lib/ui/pages/homePages/tiles_widget.dart
- [x] T048 [US2] Add empty state message when all tiles hidden in lib/ui/pages/homePages/tiles_widget.dart
- [x] T049 [US2] Implement warning dialog when attempting to hide all tiles in lib/ui/components/tiles/editable_tile_wrapper.dart
- [x] T050 [US2] Add haptic feedback on visibility toggle in lib/features/system/tile_edit_controller.dart
- [ ] T051 [P] [US2] Write widget tests for hide/show functionality in test/widget/tiles_widget_test.dart
- [ ] T052 [P] [US2] Write widget tests for empty state in test/widget/tiles_widget_test.dart
- [ ] T053 [P] [US2] Write widget tests for all-hidden warning in test/widget/tiles_widget_test.dart

**Checkpoint**: Show/hide functionality is complete and testable independently

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final quality assurance

- [ ] T054 [P] Add smooth animations for edit mode transitions in lib/ui/pages/homePages/tiles_widget.dart
- [ ] T055 [P] Add wiggle animation for tiles in edit mode (optional) in lib/ui/components/tiles/editable_tile_wrapper.dart
- [ ] T056 [P] Optimize performance for low-end devices in lib/ui/pages/homePages/tiles_widget.dart
- [ ] T057 [P] Add error handling for storage failures in lib/features/system/tile_service.dart
- [ ] T058 [P] Add logging for debugging in lib/features/system/tile_service.dart
- [ ] T059 Test on iOS simulator and verify haptic feedback
- [ ] T060 Test on Android emulator and verify haptic feedback
- [ ] T061 Test on macOS desktop and verify mouse drag
- [ ] T062 Test on Windows desktop and verify mouse drag
- [ ] T063 Test on web browser and verify drag interactions
- [ ] T064 Test on WeChat Mini Program and verify tap-based fallback
- [ ] T065 Run flutter test --coverage and verify 80% threshold
- [ ] T066 Run scripts/check_coverage.sh to validate coverage
- [ ] T067 Run flutter analyze and fix any issues
- [ ] T068 Run dart format . to format all code
- [ ] T069 Profile drag performance and verify <100ms response time
- [ ] T070 Test edge cases (single tile, all hidden, rapid drags, rotation)
- [ ] T071 Update CHANGELOG.md with feature description
- [ ] T072 Update README.md if needed for user-facing changes

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - User Story 3 (Edit Mode) should be implemented first as it's the foundation for US1 and US2
  - User Story 1 (Drag) can start after US3 is complete
  - User Story 2 (Hide/Show) can start after US3 is complete
  - US1 and US2 can proceed in parallel after US3
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 3 (P1 - Edit Mode)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 1 (P1 - Drag)**: Depends on US3 (needs edit mode to enable drag) - Can run in parallel with US2
- **User Story 2 (P2 - Hide/Show)**: Depends on US3 (needs edit mode to show/hide) - Can run in parallel with US1

### Within Each User Story

- Tests and implementation tasks marked [P] can run in parallel within the same story
- Models before services (already done in Foundational phase)
- Services before UI components (already done in Foundational phase)
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks can run sequentially (only 3 tasks)
- Within Foundational phase:
  - T004-T007 (models and tests) can run in parallel
  - T015-T016 (service tests) can run in parallel
  - T023 (controller tests) runs after T017-T021
- Within User Story 3:
  - T024-T025 (UI components) can run in parallel
  - T030-T031 (tests) can run in parallel
- Within User Story 1:
  - T032 (wrapper) and T033-T035 (grid integration) can run in parallel
  - T041-T043 (tests) can run in parallel
- Within User Story 2:
  - T044-T045 (UI components) can run in parallel
  - T051-T053 (tests) can run in parallel
- Within Polish phase:
  - T054-T058 (code improvements) can run in parallel
  - T059-T064 (platform testing) can run in parallel
  - T065-T068 (quality checks) run sequentially

---

## Parallel Example: User Story 1

```bash
# Launch UI components in parallel:
Task: "Create EditableTileWrapper component in lib/ui/components/tiles/editable_tile_wrapper.dart"
Task: "Integrate ReorderableGridView in TilesWidget for full Flutter platforms in lib/ui/pages/homePages/tiles_widget.dart"

# Launch tests in parallel after implementation:
Task: "Write widget tests for drag interactions in test/widget/tiles_widget_test.dart"
Task: "Write widget tests for platform-specific behavior in test/widget/tiles_widget_test.dart"
Task: "Write widget tests for visual feedback in test/widget/editable_tile_wrapper_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 3 + User Story 1)

1. Complete Phase 1: Setup (3 tasks)
2. Complete Phase 2: Foundational (20 tasks - CRITICAL)
3. Complete Phase 3: User Story 3 - Edit Mode (8 tasks)
4. Complete Phase 4: User Story 1 - Drag to Reorder (12 tasks)
5. **STOP and VALIDATE**: Test US3 + US1 independently
6. Deploy/demo if ready (MVP with edit mode and drag-to-reorder)

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready (23 tasks)
2. Add User Story 3 → Test independently → Deploy/Demo (Edit mode works!)
3. Add User Story 1 → Test independently → Deploy/Demo (Drag works!)
4. Add User Story 2 → Test independently → Deploy/Demo (Hide/show works!)
5. Polish → Final testing → Production release

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together (23 tasks)
2. Once Foundational is done:
   - Developer A: User Story 3 (Edit Mode) - MUST complete first
3. After US3 is complete:
   - Developer A: User Story 1 (Drag)
   - Developer B: User Story 2 (Hide/Show)
4. Stories complete and integrate independently
5. Team works on Polish together

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests pass before moving to next story
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- 80% test coverage is NON-NEGOTIABLE per constitution
- Use PlatformUtils for all platform detection (CRITICAL for WeChat Mini Program)
- Test on at least 3 platforms before considering story complete
- Performance monitoring required for drag operations
- Haptic feedback only on iOS/Android (gracefully ignored on other platforms)

---

## Task Count Summary

- **Phase 1 (Setup)**: 3 tasks
- **Phase 2 (Foundational)**: 20 tasks
- **Phase 3 (US3 - Edit Mode)**: 8 tasks
- **Phase 4 (US1 - Drag)**: 12 tasks
- **Phase 5 (US2 - Hide/Show)**: 10 tasks
- **Phase 6 (Polish)**: 19 tasks

**Total**: 72 tasks

**MVP Scope** (US3 + US1): 43 tasks (Setup + Foundational + US3 + US1)
**Full Feature**: 72 tasks
