# SGT School

A Flutter mobile application serving as a **School Management System** for
Shan Golden Triangle School. The app targets Students, Parents, and Teachers,
providing role-based access to school features.

## Current Status

### ✅ Milestone 1 — Phone-Based Login + Session Persistence

- **Login** with phone number and password
- **Session persistence** using `flutter_secure_storage`
  (Keychain on iOS, Keystore on Android)
- **Auto session restore** on app launch — no re-login required
- **Logout** with secure storage cleanup
- **Role-based user model** (student, parent, teacher)

### 🔜 Planned

- Student attendance records (Time In / Time Out)
- Student dashboard with profile display
- Parent and Teacher features

## Architecture

Feature-first Clean Architecture with three layers per feature:

```
lib/src/features/{feature_name}/
├── data/           # Models, datasources, repository implementations
├── domain/         # Entities, abstract repository interfaces
└── presentation/   # Providers, screens, widgets
```

**Key principles:**
- Dependencies point inward: `Presentation → Domain ← Data`
- `fpdart Either<Failure, T>` for all error-prone operations
- Provider + ChangeNotifier for state management
- GoRouter for navigation

## Project Structure

```
lib/
├── main.dart                    # Default entry point (no flavor)
├── main_dev.dart                # Development flavor entry point
├── main_prod.dart               # Production flavor entry point
└── src/
    ├── app.dart                 # MaterialApp.router setup
    ├── config/                  # Dio + environment config
    ├── extensions/              # Dart extensions (context, string, etc.)
    ├── features/
    │   ├── auth/                # Authentication feature
    │   │   ├── data/
    │   │   │   ├── datasources/ # AuthLocalDatasource (secure storage)
    │   │   │   ├── models/      # UserModel (DTO with serialization)
    │   │   │   └── repositories/# AuthRepositoryImpl
    │   │   ├── domain/
    │   │   │   ├── entities/    # AppUser, UserRole
    │   │   │   └── repositories/# AuthRepository (abstract)
    │   │   └── presentation/
    │   │       ├── providers/   # AuthProvider, SessionProvider
    │   │       └── screens/     # LoginScreen
    │   └── home/                # Home feature (post-login)
    ├── imports/                 # Barrel files
    ├── routing/                 # GoRouter + AppRoutes
    ├── services/                # Platform services (auth, storage, etc.)
    ├── shared/                  # Cross-feature widgets, enums, helpers
    ├── theme/                   # Material 3 theme system
    └── utils/                   # Failures, logger, typedefs
```

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.5.0
- Dart SDK ≥ 3.5.0

### Setup

```bash
# Clone the repository
git clone <repo-url>
cd sgt_school

# Install dependencies
flutter pub get

# Create .env file (already exists in project)
# API_BASE_URL=https://your-api-url.com
# APP_ENV=development

# Run the app in development flavor
flutter run -t lib/main_dev.dart
```

## Running & Building

This project uses **flavors** to separate environments. Always use the
corresponding entry point (`-t` flag) when running or building.

### Entry Points

| Flavor | Entry Point | Base URL |
|---|---|---|
| `dev` | `lib/main_dev.dart` | `http://150.95.85.135:8070/api/v1` |
| `prod` | `lib/main_prod.dart` | `http://150.95.30.124:8070/api/v1` |

### Running on a Device / Emulator

```bash
# Development
flutter run -t lib/main_dev.dart

# Production (for testing prod config locally)
flutter run --release -t lib/main_prod.dart
```

### Building APK (Android)

```bash
# Production — single fat APK
flutter build apk --release -t lib/main_prod.dart

# Production — split APKs by ABI (recommended, smaller size)
flutter build apk --release -t lib/main_prod.dart --split-per-abi

# Development
flutter build apk --debug -t lib/main_dev.dart
```

> Output: `build/app/outputs/flutter-apk/app-release.apk`
>
> With `--split-per-abi`, three APKs are produced:
> `app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`, `app-x86_64-release.apk`

### Building App Bundle (Android — Play Store)

```bash
flutter build appbundle --release -t lib/main_prod.dart
```

> Output: `build/app/outputs/bundle/release/app-release.aab`

### Building for iOS

```bash
# Production — IPA for distribution
flutter build ipa --release -t lib/main_prod.dart

# Development — run on iOS device
flutter run -t lib/main_dev.dart
```

### Running Tests

```bash
flutter test                    # Run all tests
flutter test --reporter expanded # Verbose output
```

### Static Analysis

```bash
flutter analyze                 # Check for errors and warnings
```

## Technology Stack

| Category          | Technology                          |
|-------------------|-------------------------------------|
| Framework         | Flutter (SDK ≥3.5.0)               |
| State Management  | Provider + fpdart                   |
| HTTP Client       | Dio                                 |
| Routing           | GoRouter                            |
| Secure Storage    | flutter_secure_storage              |
| Localization      | easy_localization (EN + MY)         |
| Functional Utils  | fpdart (Either, Option)             |
| UI Extras         | flutter_animate, skeletonizer       |
| Testing           | flutter_test, mockito               |

## Localization

The app supports:
- **English** (`en`) — default
- **Myanmar** (`my`)

Translation files are in `assets/translations/`.

## Environment Variables

| Key            | Description          | Default                          |
|----------------|----------------------|----------------------------------|
| `API_BASE_URL` | Backend API base URL | `https://your-api-url.com`       |
| `APP_ENV`      | Environment name     | `development`                    |
