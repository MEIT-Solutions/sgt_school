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
├── main.dart                    # Entry point
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

# Run the app
flutter run
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
