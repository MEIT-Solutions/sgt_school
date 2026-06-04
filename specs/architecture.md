# SGT School — Architecture Specification

## Pattern: Feature-First Clean Architecture

Each feature is a self-contained module with three layers:

```
lib/src/features/{feature_name}/
├── data/
│   ├── datasources/    # Remote (API) and Local (cache/storage)
│   ├── models/         # DTOs with fromJson/toJson + toEntity()
│   └── repositories/   # Concrete repository implementations
├── domain/
│   ├── entities/       # Pure business objects (immutable, Equatable)
│   └── repositories/   # Abstract repository interfaces (contracts)
└── presentation/
    ├── providers/      # ChangeNotifiers for state management
    ├── screens/        # Full-page widgets
    └── widgets/        # Feature-specific reusable UI components
```

## Dependency Rule

Dependencies point **inward**:

```
Presentation → Domain ← Data
```

- **Domain** knows nothing about Data or Presentation
- **Data** depends on Domain (implements repository interfaces)
- **Presentation** depends on Domain (uses entities and repository contracts)

## Data Flow Pattern: API-First with Demo Fallback

All repository implementations follow the same pattern:

```dart
class FeatureRepositoryImpl implements FeatureRepository {
  final Dio _dio;                 // For HTTP API calls
  final DemoDataService _demo;    // For offline demo data

  @override
  FutureEither<T> getData() async {
    try {
      // 1. Try API first
      final response = await _dio.get('/endpoint');
      return Right(Model.fromJson(response.data).toEntity());
    } on DioException {
      // 2. Fall back to demo data
      return Right(_demo.getDemoData());
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
```

When the backend is ready, the demo fallback is simply removed — no UI changes required.

## Feature Registry

| Feature | Entity | Model | Repo (abstract) | Repo (impl) | Provider | Screens |
|---------|--------|-------|-----------------|-------------|----------|---------|
| `auth` | `UserEntity` | `UserModel` | `AuthRepository` | `AuthRepositoryImpl` | `AuthProvider`, `SessionProvider` | Login, Splash |
| `attendance` | `AttendanceRecord` | `AttendanceModel` | `AttendanceRepository` | `AttendanceRepositoryImpl` | `AttendanceCheckProvider` | Attendance |
| `timetable` | `TimetableSlot` | `TimetableSlotModel` | `TimetableRepository` | `TimetableRepositoryImpl` | `TimetableProvider` | Timetable |
| `subjects` | `SubjectEntity` | `SubjectModel` | `SubjectRepository` | `SubjectRepositoryImpl` | `SubjectProvider` | Subjects |
| `exams` | `ExamEntity` | `ExamModel` | `ExamRepository` | `ExamRepositoryImpl` | `ExamProvider` | Exams |
| `results` | `ResultEntity`, `ResultSummary` | `ResultModel` | `ResultRepository` | `ResultRepositoryImpl` | `ResultProvider` | Results |
| `fees` | `FeeEntity`, `FeeSummary`, `PaymentEntity` | `FeeModel`, `PaymentModel` | `FeeRepository` | `FeeRepositoryImpl` | `FeeProvider` | Fees |
| `activities` | `ActivityEntity` | `ActivityModel` | `ActivityRepository` | `ActivityRepositoryImpl` | `ActivityProvider` | Activities |
| `notices` | `NotificationEntity` | `NotificationModel` | `NotificationRepository` | `NotificationRepositoryImpl` | `NotificationProvider` | Notices |
| `assignments` | `AssignmentEntity` | `AssignmentModel` | `AssignmentRepository` | `AssignmentRepositoryImpl` | `AssignmentProvider` | Assignments |
| `classes` | `ClassEntity`, `ClassStudentEntity` | `ClassModel`, `ClassStudentModel` | `ClassRepository` | `ClassRepositoryImpl` | `ClassProvider` | Classes, ClassDetail, MarkAttendance |
| `children` | `ChildEntity` | `ChildModel` | `ChildRepository` | `ChildRepositoryImpl` | `ChildProvider` | Children, ChildDetail |

## Shared Infrastructure

```
lib/src/
├── config/         # AppConfig (Dio setup, environment, base URL)
├── extensions/     # Dart extension methods
├── imports/        # Barrel files for clean imports
├── routing/        # GoRouter setup and route constants
├── services/       # Platform services (storage, network, location, demo data)
├── shared/         # Cross-feature widgets, enums, helpers, wrappers
├── theme/          # Material 3 theme, color schemes, typography
└── utils/          # Failures, logger, typedefs, task runner
```

## State Management

- **Provider** with `ChangeNotifier` for UI state
- **fpdart `Either<Failure, T>`** for error handling at repository boundaries
- **`FutureEither<T>`** typedef wraps all async operations
- **`runTask()`** utility handles network checks and error mapping
- All providers registered in `StateWrapper` via `MultiProvider`

## Error Handling Flow

```
Service → throws Exception
    ↓
runTask() → catches → returns Either<Failure, T>
    ↓
Repository → maps/transforms → returns Either<Failure, Entity>
    ↓
Provider → fold(onFailure, onSuccess) → updates UI state
```

## Navigation

- **GoRouter** with centralized `AppRoutes` constants
- **SessionListenerWrapper** listens to `SessionProvider` and redirects:
  - `authenticated` → home
  - `unauthenticated` → login

## Secure Storage Keys

| Key              | Content                  | Type   |
|------------------|--------------------------|--------|
| `auth_token`     | JWT bearer token         | String |
| `user_role`      | student / parent / teacher | String |
| `user_profile`   | JSON-encoded profile     | String |

## API Configuration

- **Base URL**: Defined in `.env` as `API_BASE_URL`
- **Auth**: Bearer token via `Authorization` header
- **Pagination**: Standard `page`/`per_page` query params
- **Error format**: `{ "error": { "code": "...", "message": "..." } }`
