# SGT School — Authentication Specification

## Overview

Users authenticate with **phone number + password**. The server returns a JWT
token, the user's role, and their profile data. All sensitive data is persisted
in `flutter_secure_storage`.

## User Roles

| Role    | Enum Value | Description                        |
|---------|------------|------------------------------------|
| Student | `student`  | Views own attendance records       |
| Parent  | `parent`   | Monitors child's school activities |
| Teacher | `teacher`  | Manages class attendance           |

## Login Flow

```
┌─────────────┐    POST /auth/login     ┌──────────┐
│ Login Screen │ ──────────────────────► │  Server  │
│ phone + pwd  │                         │          │
└─────────────┘    { token, role,        └──────────┘
       │            profile }                 │
       │◄─────────────────────────────────────┘
       │
       ▼
┌──────────────────┐
│ SecureStorage     │
│ save: token,      │
│       role,       │
│       profile     │
└──────────────────┘
       │
       ▼
┌──────────────────┐
│ Navigate to Home │
└──────────────────┘
```

## Session Restoration Flow

```
App Launch
    │
    ▼
Read token from SecureStorage
    │
    ├── token exists → restore AppUser from stored profile → Home
    │
    └── token missing → Login Screen
```

## Logout Flow

```
Logout tapped
    │
    ▼
Clear all SecureStorage keys (token, role, profile)
    │
    ▼
Navigate to Login Screen
```

## Domain Entity: AppUser

```dart
class AppUser extends Equatable {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String? grade;
  final String? photoUrl;
}
```

## Data Model: UserModel

```dart
class UserModel {
  // ... same fields as AppUser
  factory UserModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  AppUser toEntity();
}
```

## API Contract

### Login

**Endpoint**: `POST /auth/login`

**Request Body**:
```json
{
  "phone": "09xxxxxxxxx",
  "password": "password123"
}
```

**Success Response** (`200 OK`):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
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

**Error Response** (`401 Unauthorized`):
```json
{
  "error": "Invalid phone number or password"
}
```

## Validation Rules

| Field    | Rule                                         |
|----------|----------------------------------------------|
| Phone    | 9–16 digits, may start with `+` or `0`      |
| Password | Minimum 6 characters, required               |

## Secure Storage Keys

| Key            | Value                        |
|----------------|------------------------------|
| `auth_token`   | Raw JWT string               |
| `user_role`    | `"student"`, `"parent"`, or `"teacher"` |
| `user_profile` | JSON string of the profile object |
