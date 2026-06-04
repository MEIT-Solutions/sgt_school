# SGT School — Development Tasks

## Milestone 1: Phone-Based Login + Session Persistence

> **Goal**: User sees a login screen, enters phone + password, and is navigated
> to the home screen. Killing and reopening the app restores the session.

- [ ] **1.1 Domain Layer — User Entity & Auth Contract**
  - [ ] Rewrite `AppUser` entity with `phone`, `role` (enum), `grade` fields
  - [ ] Define `UserRole` enum (student, parent, teacher)
  - [ ] Update `AuthRepository` interface: `login(phone, password)`, `restoreSession()`, `logout()`
  - [ ] Write unit tests for `AppUser` entity

- [ ] **1.2 Data Layer — Models & Datasources**
  - [ ] Rewrite `UserModel` with `fromJson()`, `toJson()`, `toEntity()`
  - [ ] Create `AuthLocalDatasource` for secure storage (save/get/clear session)
  - [ ] Write unit tests for `UserModel` serialization
  - [ ] Write unit tests for `AuthLocalDatasource`

- [ ] **1.3 Data Layer — Repository Implementation**
  - [ ] Rewrite `AuthRepositoryImpl` using mock API + `AuthLocalDatasource`
  - [ ] Implement `login()`: call API → save session → return entity
  - [ ] Implement `restoreSession()`: read from storage → return entity or null
  - [ ] Implement `logout()`: clear storage
  - [ ] Write unit tests for `AuthRepositoryImpl`

- [ ] **1.4 Service Layer — Mock Auth API**
  - [ ] Rewrite `AuthService` to simulate phone + password login
  - [ ] Return mock response matching API contract: `{ token, role, profile }`
  - [ ] Simulate error for specific phone numbers (e.g., contains "error")

- [ ] **1.5 Presentation Layer — Login Screen**
  - [ ] Replace email field with phone number field
  - [ ] Use phone number validation (`AppUtils.isPhoneNumber`)
  - [ ] Remove social login buttons (Google, Facebook, Apple)
  - [ ] Remove "Sign Up" and "Forgot Password" links
  - [ ] Update button label to localized string
  - [ ] Write unit tests for `AuthProvider`

- [ ] **1.6 Presentation Layer — Session Management**
  - [ ] Update `SessionProvider` to use `restoreSession()`
  - [ ] Ensure auto-redirect on app launch based on stored session

- [ ] **1.7 Routing & Cleanup**
  - [ ] Remove `signup` and `forgotPassword` routes from `AppRoutes`
  - [ ] Remove corresponding `GoRoute` entries from `AppRouter`
  - [ ] Delete `signup_screen.dart` and `forgot_password_screen.dart`
  - [ ] Clean up `core_imports.dart` barrel file

- [ ] **1.8 Localization**
  - [ ] Update `en.json` with phone-based auth strings
  - [ ] Create `my.json` (Myanmar) to replace `es.json`
  - [ ] Update `LocalizationWrapper` supported locales

- [ ] **1.9 Validation**
  - [ ] `flutter analyze` — zero errors and warnings
  - [ ] `flutter test` — all tests pass
  - [ ] App launches and shows login screen
  - [ ] Login with mock credentials → navigates to home
  - [ ] App restart restores session automatically
  - [ ] Logout returns to login and clears storage

- [ ] **1.10 Documentation**
  - [ ] Update `README.md` with current functionality

---

## Milestone 2: Student Home Dashboard *(planned)*

> **Goal**: After login, students see a dashboard with their profile info and
> a navigation entry point for attendance.

- [ ] Display student name, grade, role on home screen
- [ ] Add bottom navigation or drawer for feature access
- [ ] Create attendance navigation entry point
- [ ] Tests and README update

---

## Milestone 3: Student Attendance — View Records *(planned)*

> **Goal**: Students can view their attendance history with Time In / Time Out.

- [ ] Create `attendance` feature module (data/domain/presentation)
- [ ] Implement `AttendanceRecord` entity and model
- [ ] Create mock attendance API
- [ ] Build attendance list screen with status badges
- [ ] Tests and README update

---

## Milestone 4: Attendance Calendar View *(planned)*

> **Goal**: Students can view attendance on a monthly calendar.

- [ ] Calendar widget with color-coded attendance days
- [ ] Tap a day to see detailed time-in/time-out
- [ ] Monthly summary statistics
- [ ] Tests and README update
