# SGT School

A Flutter mobile application serving as a **School Management System** for
Shan Golden Triangle School. The app targets Students, Parents, and Teachers,
providing role-based access to school features.

## Current Status

### ✅ Implemented Features

**Authentication**
- Login with phone number and password
- Session persistence using `flutter_secure_storage`
  (Keychain on iOS, Keystore on Android)
- Auto session restore on app launch — no re-login required
- Logout with secure storage cleanup
- Role-based user model (student, parent, teacher)

**Student Features**
- Home dashboard with greeting, quick-access grid (6 items), and upcoming activities
- Exams — upcoming/completed exams with detail view
- Timetable — weekly class schedule
- Fees — summary banner, fee details with payment status
- Results — exam results with scores and grades
- Subjects — enrolled subjects list
- Activities — school activities with attachments/downloads
- Profile — personal, class, and parent/emergency info
- Notifications — categorized school notices

**Parent Features**
- Parent home dashboard with children overview (loaded from API)
- Children list with attendance percentage
- Child detail screen with exam results and fee summary
- Dedicated bottom nav: Home / Children / Profile

**Teacher Features**
- Teacher home dashboard with quick-access grid (6 items)
- Subjects, Classes, Activities, Exams management
- Student list with attendance status display
- Mark attendance for classes
- Exam results overview

**Settings**
- Theme mode (System / Light / Dark)
- Language switching (English / Myanmar)
- Cloud settings (Dev / Prod / Custom base URL)

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
    │   ├── home/                # Home dashboards (student, parent, teacher)
    │   ├── exams/               # Exams and exam results
    │   ├── timetable/           # Weekly timetable
    │   ├── fees/                # Fee management
    │   ├── results/             # Exam results
    │   ├── subjects/            # Subjects list
    │   ├── activities/          # School activities
    │   ├── children/            # Parent's children management
    │   ├── classes/             # Teacher's class management
    │   ├── assignments/         # Assignments
    │   ├── notices/             # Notifications
    │   ├── profile/             # User profile
    │   └── settings/            # App settings
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

# Run the app in development flavor
flutter run -t lib/main_dev.dart
```

## Running & Building

This project uses **flavors** to separate environments. Always use the
corresponding entry point (`-t` flag) when running or building.

### Entry Points

| Flavor | Entry Point | Base URL |
|---|---|---|
| `dev` | `lib/main_dev.dart` | `https://uat.sgt-odoo.com/api/v1` |
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
