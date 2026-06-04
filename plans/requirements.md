# SGT School — Project Requirements

## Overview

SGT School is a **Flutter mobile application** serving as a School Management System
for **Shan Golden Triangle School**. The app targets three user roles:

| Role      | Description                                      |
|-----------|--------------------------------------------------|
| Student   | View attendance records, check time-in/time-out  |
| Parent    | Monitor child's attendance and school activities  |
| Teacher   | Manage attendance, view class rosters             |

## Authentication

- **Login method**: Phone number + password
- **API response**: The server returns `role`, `token`, and `profile` data
- **Session persistence**: Credentials are stored using `flutter_secure_storage`
  (Keychain on iOS, Keystore on Android)
- **Session restoration**: On app launch, the stored token is checked to
  automatically restore the session without re-login

### Login API Contract

**Request** — `POST /auth/login`
```json
{
  "phone": "09xxxxxxxxx",
  "password": "••••••"
}
```

**Response** — `200 OK`
```json
{
  "token": "jwt-token-here",
  "role": "student",
  "profile": {
    "id": "123",
    "name": "Aung Hein Htet",
    "phone": "09xxxxxxxxx",
    "grade": "Grade 10",
    "photo_url": null
  }
}
```

## Initial Feature Scope (Student First)

### Phase 1 — Authentication
- Phone + password login
- Secure token storage
- Auto session restore on app launch
- Logout with storage cleanup

### Phase 2 — Student Attendance
- View attendance records (Time In / Time Out)
- Daily attendance status display
- Attendance history list

## Architecture

- **Pattern**: Feature-first Clean Architecture
- **State Management**: Provider + fpdart (Either types for error handling)
- **Networking**: Dio with interceptors
- **Navigation**: GoRouter
- **Localization**: easy_localization (English + Myanmar)

## Technology Stack

| Category          | Technology                          |
|-------------------|-------------------------------------|
| Framework         | Flutter (SDK ≥3.5.0)               |
| State Management  | Provider + fpdart                   |
| HTTP Client       | Dio                                 |
| Routing           | GoRouter                            |
| Secure Storage    | flutter_secure_storage              |
| Localization      | easy_localization                   |
| Functional Utils  | fpdart (Either, Option)             |
| UI Extras         | flutter_animate, skeletonizer       |
