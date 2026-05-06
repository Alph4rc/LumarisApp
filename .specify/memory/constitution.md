<!--
Sync Impact Report:
- Version: 0.0.0 → 1.0.0 (Initial constitution ratification)
- Modified principles: N/A (initial creation)
- Added sections: All core principles, Platform Compatibility, Development Workflow, Governance
- Removed sections: N/A
- Templates requiring updates:
  ✅ plan-template.md - Constitution Check section aligns with principles
  ✅ spec-template.md - User scenarios and requirements align with testing requirements
  ✅ tasks-template.md - Task organization supports platform-specific and testing requirements
- Follow-up TODOs: None
-->

# iOS Club App Constitution

## Core Principles

### I. Platform-First Architecture

Every feature MUST support all target platforms (iOS, Android, macOS, Windows, Linux, Web) unless explicitly scoped otherwise. Platform-specific code MUST be isolated in `lib/platform/` with clear abstraction boundaries. All platform detection MUST use `PlatformUtils` from `lib/core/utils/platform_utils.dart`.

**Rationale**: Centralized platform utilities ensure consistent behavior across platforms and prevent runtime crashes when `dart:io` is unavailable (e.g., web).

### II. State Management via GetX

All application state MUST be managed through GetX stores registered in `lib/state/init.dart`. Stores MUST be accessed via `StoreClass.to` or `Get.find<StoreClass>()`. Direct state mutation outside stores is FORBIDDEN. Each store MUST have a single, well-defined responsibility (user data, courses, settings, etc.).

**Rationale**: GetX provides reactive state management with minimal boilerplate. Centralized registration ensures predictable initialization order and prevents dependency issues. Single responsibility keeps stores maintainable and testable.

### III. Test Coverage (NON-NEGOTIABLE)

All new features MUST maintain minimum 80% code coverage enforced by `scripts/check_coverage.sh`. Tests MUST be organized as:
- Unit tests in `test/unit/` for models and business logic
- Widget tests in `test/widget/` for UI components
- Test names MUST follow "should_X_when_Y" pattern

**Rationale**: High test coverage prevents regressions in a multi-platform codebase where manual testing across all platforms is impractical. The 80% threshold is enforced in CI/CD pipeline.

### IV. Feature-Based Organization

Code MUST be organized by feature domain in `lib/features/` (club, education, system) rather than by technical layer. Each feature module contains its own models, services, and UI components. Core cross-cutting concerns live in `lib/core/`. Platform-specific implementations live in `lib/platform/`.

**Rationale**: Feature-based organization improves discoverability, reduces merge conflicts, and makes it easier to understand feature boundaries. It aligns with domain-driven design principles and scales better than layer-based organization.

### V. Type Safety and Null Safety

All code MUST use explicit type declarations. Variables MUST be declared with `final` for immutability where possible. Null-safety operators (`?.`, `??`, `!`) MUST be used appropriately with preference for safe operators. Use `const` constructors wherever possible for performance.

**Rationale**: Dart's sound null safety prevents null reference errors at compile time. Explicit types improve code readability and enable better IDE support. Immutability reduces bugs and improves reasoning about code behavior.

### VI. Performance Monitoring

All features MUST integrate with `PerformanceMonitor` for tracking widget build times, route transitions, and HTTP request timing. Performance-critical paths MUST be profiled before optimization. Android MUST enable high refresh rate mode on supported devices.

**Rationale**: Multi-platform apps have varying performance characteristics. Built-in monitoring helps identify platform-specific performance issues early. High refresh rate improves user experience on capable Android devices.

### VII. Error Handling and Resilience

All async operations MUST have try-catch blocks with appropriate error handling. Services MUST return safe defaults rather than null on errors. Network requests MUST use `RequestCache` for automatic caching and retry logic. User-facing errors MUST be logged with `debugPrint` for debugging.

**Rationale**: Mobile apps face unreliable network conditions and varied device capabilities. Defensive error handling prevents crashes and improves user experience. Caching reduces network load and improves offline capability.

## Platform Compatibility

### Cross-Platform Requirements

- All UI code MUST work on mobile (iOS/Android), desktop (Windows/macOS/Linux), and web
- Navigation MUST adapt: bottom bar for mobile, sidebar for desktop, native macOS sidebar for macOS
- Fonts MUST use `PlatformUtils.getDesktopFontFamily()` for consistent rendering on desktop platforms
- Platform-specific features (widgets, background services) MUST gracefully degrade on unsupported platforms

### Platform Detection Rules

- ALWAYS use `PlatformUtils.isWindows`, `PlatformUtils.isMacOS`, `PlatformUtils.isAndroid`, etc.
- NEVER use `Platform.isX` directly or `!kIsWeb && Platform.isX` patterns
- NEVER assume `dart:io` availability - wrap in try-catch if absolutely necessary
- Test platform-specific code paths on actual target platforms, not just simulators

## Development Workflow

### Code Standards

**Import Organization**:
1. Dart SDK imports (`dart:*`)
2. Flutter SDK imports (`package:flutter/*`)
3. Third-party packages
4. Local imports (`package:ios_club_app/*`)

**Naming Conventions**:
- Classes: `PascalCase` (CourseModel, UserService)
- Variables/methods: `camelCase` (courseName, getUserData)
- Constants: `lowerCamelCase`
- Private members: prefix with `_` (_initializeData)

### Service Layer Pattern

Services MUST follow consistent patterns:
- Core services in `lib/core/services/` for low-level functionality (networking, time, storage)
- Feature services in `lib/features/*/services/` for business logic
- Services MUST be stateless and inject dependencies
- State MUST be managed in GetX stores, not services

### Testing Requirements

- Write tests BEFORE implementation (TDD encouraged but not enforced)
- Unit tests for all models and business logic
- Widget tests for complex UI components
- Integration tests for critical user flows
- Run `flutter test --coverage` before committing
- Verify `scripts/check_coverage.sh` passes (80% threshold)

### Git Workflow

- Feature branches follow `###-feature-name` pattern
- Commit messages MUST be descriptive and reference issue numbers
- All commits MUST pass `flutter analyze` with no errors
- Format code with `dart format .` before committing
- Primary repository: https://gitee.com/luckyfishisdashen/iOSClub.AppMobile.git

## Governance

This constitution supersedes all other development practices. All code reviews MUST verify compliance with these principles. Violations MUST be justified in writing with explanation of why simpler alternatives are insufficient.

**Amendment Process**:
- Amendments require documentation of rationale and impact analysis
- Version MUST be incremented according to semantic versioning:
  - MAJOR: Backward incompatible principle removals or redefinitions
  - MINOR: New principles or materially expanded guidance
  - PATCH: Clarifications, wording fixes, non-semantic refinements
- All dependent templates MUST be updated to reflect amendments
- Migration plan MUST be provided for breaking changes

**Compliance Review**:
- All PRs MUST include constitution compliance checklist
- Automated checks enforce test coverage and code formatting
- Platform compatibility MUST be verified on at least 3 platforms before merge
- Performance regressions MUST be justified with profiling data

**Runtime Guidance**:
- Use `CLAUDE.md` for AI assistant development guidance
- Use `README.md` for project overview and setup instructions
- Use `.specify/memory/constitution.md` (this file) for architectural principles

**Version**: 1.0.0 | **Ratified**: 2026-02-15 | **Last Amended**: 2026-02-15
