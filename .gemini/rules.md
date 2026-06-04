# SGT School — AI Agent Rules

## Project Context

- **App**: SGT School — a School Management System (Flutter)
- **Architecture**: Feature-first Clean Architecture
- **State Management**: Provider + fpdart Either types
- **Target Users**: Students, Parents, Teachers
- **Languages**: English + Myanmar

---

## AI Agent Directives (CRITICAL)

### 1. Spec-Driven Development
- **ALWAYS** check `specs/` (e.g., `specs/architecture.md`) and `plans/` (e.g., `plans/requirements.md`) before proposing or implementing new features.
- Follow the defined architecture, state management, and feature requirements exactly.

### 2. Check Existing Files Before Creating New Ones
- **ALWAYS** check the codebase, especially `lib/src/shared/`, `lib/src/theme/`, and `lib/src/utils/`, before writing or updating UI and screens.
- **Do not invent new components** if a common component already exists.

### 3. Use Common Files
- **Buttons**: Use `AppButton` (`lib/src/shared/widgets/app_button.dart`).
- **Text Fields**: Use `AppTextField` (`lib/src/shared/widgets/app_text_field.dart`).
- **Error Handling**: Use `Failure` (`lib/src/utils/failure.dart`) and `AppErrorWidget` (`lib/src/shared/widgets/app_error_widget.dart`).
- **Toasts & Dialogs**: Use helpers in `lib/src/shared/helpers/` (e.g., `showToast`).
- **Logging**: Use `AppLogger` (`lib/src/utils/logger.dart`).
- **Navigation**: Use centralized `AppRoutes` constants with `GoRouter`.

### 4. No Hardcoding
- **Colors**: Never hardcode colors in widgets. Use the centralized `color_schemes.dart` or `theme.dart` in `lib/src/theme/`. If a required color does not exist, **create or update** the common theme files.
- **Fonts & TextStyles**: Never hardcode fonts. Use `text_theme.dart` and `theme.dart`.
- **Strings**: Never hardcode user-facing strings in Dart code. All strings must be localized using `easy_localization` keys (e.g., `'key.path'.tr()`) defined in the translation files (`en.json`, `my.json`).

### 5. Backend API Readiness
- The project is currently front-end focused but will connect to a backend API later.
- Ensure all business logic flows through abstract repositories in the domain layer.
- Repository methods must always return `Either<Failure, T>` (using `FutureEither<T>`).
- Data sources should be properly abstracted so that swapping from local/mock data to the remote API is seamless.

---

## Coding Principles

### DRY (Don't Repeat Yourself)
- Extract duplicated logic into shared utilities, services, or base classes.
- Use barrel files (`exports`) to keep imports clean and centralized.

### Separation of Concerns
- Each module handles one distinct responsibility.
- Domain layer has zero knowledge of Data or Presentation layers.

### Single Responsibility Principle (SRP)
- Every class, file, and function should have exactly one reason to change.
- Providers handle UI state only; business logic belongs in repositories.

### Clear Abstractions & Contracts
- Define abstract repository interfaces in the Domain layer.
- Expose intent through small, stable interfaces; hide implementation details.
- Use `FutureEither<T>` for all async repository methods.

### Low Coupling, High Cohesion
- Features are self-contained modules with their own data/domain/presentation layers.
- Minimize cross-feature dependencies; share through the `shared/` directory.

### Scalability & Statelessness
- Services are singletons with no mutable shared state beyond their specific concern.
- Prefer stateless widgets when no local state is needed.

### Observability & Testability
- Use `AppLogger` for all logging (info, warning, error, success).
- Every repository method returns `Either<Failure, T>` for predictable error handling.
- Design all classes to accept dependencies via constructor injection for testability.

### KISS (Keep It Simple, Sir)
- Prefer simple, readable solutions over clever abstractions.
- Don't introduce patterns (BLoC, Riverpod, etc.) unless the current approach fails.

### YAGNI (You're Not Gonna Need It)
- Only build features that are in the current milestone's scope.
- Don't create abstract base classes until you have 2+ concrete implementations.

### TDD (Test-Driven Development)
- Write tests first; implementation code isn't done until the tests pass.
- Test structure mirrors `lib/` structure: `test/features/auth/...` matches `lib/src/features/auth/...`.
- Every new feature must include unit tests for entities, models, repositories, and providers.

---

## Project Conventions

### File & Folder Naming
- Use `snake_case` for all file and folder names.
- Feature folders: `lib/src/features/{feature_name}/`
- Test files mirror source: `test/features/{feature_name}/...`

### Import Structure
- Use barrel files: `core_imports.dart` for Flutter SDK + project core, `packages_imports.dart` for third-party.
- Never import directly from `package:flutter/material.dart` in feature files — use `core_imports.dart`.

### Clean Architecture Layers
```
Feature/
├── data/           # Models, datasources, repository implementations
├── domain/         # Entities, abstract repository interfaces
└── presentation/   # Providers, screens, widgets
```

### State Management
- `ChangeNotifier` providers for UI state.
- `fpdart Either<Failure, T>` for all error-prone operations.
- `runTask()` wrapper for network-aware async operations.

### Error Handling
- All errors flow through `Failure` hierarchy: `ServerFailure`, `CacheFailure`, `NetworkFailure`, `UnknownFailure`.
- Never throw raw exceptions from repositories — always return `Left(Failure)`.
- Use `showToast()` for user-facing error messages; `AppLogger` for developer logs.

### Secure Storage
- Sensitive data (tokens, credentials) → `SecureStorageService`
- Non-sensitive preferences → `StorageService` (SharedPreferences)
- Define storage keys as constants in the relevant datasource.

### Localization
- All user-facing strings must be in translation files (`en.json`, `my.json`).
- Use `'key.path'.tr()` from easy_localization.
- Never hardcode user-facing strings in Dart code.

### Testing
- Unit tests for: entities, models (serialization), repositories, providers.
- Use `mockito` or manual mocks for dependency injection.
- Test file naming: `{source_file_name}_test.dart`.
