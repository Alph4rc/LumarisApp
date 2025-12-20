# iOS Club App - Agent Guidelines

## Commands

### Build & Test
- `flutter test` - Run all tests
- `flutter test test/unit/course_model_test.dart` - Run single test file
- `flutter test --coverage` - Generate coverage report
- `scripts/check_coverage.sh` - Check coverage threshold (80%)
- `flutter analyze` - Run static analysis
- `dart format .` - Format code

## Code Style

### Imports & Formatting
- Use flutter_lints package for static analysis
- Format code with `dart format .`
- Organize imports: dart -> flutter -> third-party -> local
- Use relative imports for local files

### Naming & Types
- PascalCase for classes (CourseModel, UserService)
- camelCase for variables and methods (courseName, getUserData)
- Use strong typing - declare variable types explicitly
- Prefer final for immutable variables

### Error Handling
- Use try-catch blocks for async operations
- Handle null values with null-aware operators (?., ??)
- Log errors with appropriate context
- Return empty defaults rather than null when possible

### Testing
- Write unit tests for models and business logic in test/unit/
- Write widget tests for UI components in test/widget/
- Use descriptive test names following "should_ when_" pattern
- Aim for 80%+ test coverage