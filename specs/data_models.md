# SGT School — Data Models Reference

> This document defines the JSON field contracts between the Flutter app and the backend API.  
> All field names use `snake_case` in JSON and are mapped to `camelCase` in Dart models.

---

## 1. User Profile

Used in: Login response, `/auth/me`, `/students/{id}/profile`

| Field | Type | Nullable | Role-Specific | Description |
|-------|------|----------|---------------|-------------|
| `id` | `String` | No | All | Unique user ID (e.g., `STU-001`, `PAR-001`, `TCH-001`) |
| `name` | `String` | No | All | Full name |
| `phone` | `String` | No | All | Phone number |
| `email` | `String` | Yes | All | Email address |
| `date_of_birth` | `String` | Yes | All | ISO date `YYYY-MM-DD` |
| `gender` | `String` | Yes | All | `male`, `female`, `other` |
| `address` | `String` | Yes | All | Full address |
| `photo_url` | `String` | Yes | All | Profile photo URL |
| `grade` | `String` | Yes | Student | e.g., `Grade 10` |
| `section` | `String` | Yes | Student | e.g., `A` |
| `roll_no` | `String` | Yes | Student | e.g., `12` |
| `admission_no` | `String` | Yes | Student | e.g., `ADM20240012` |
| `class_teacher` | `String` | Yes | Student | Class teacher's name |
| `academic_year` | `String` | Yes | Student | e.g., `2025 - 2026` |
| `parent_name` | `String` | Yes | Student | Parent/guardian name |
| `parent_phone` | `String` | Yes | Student | Parent phone |
| `parent_relation` | `String` | Yes | Student | `Mother`, `Father`, etc. |
| `emergency_contact` | `String` | Yes | Student | Emergency phone |
| `emergency_name` | `String` | Yes | Student | Emergency contact name |
| `subject` | `String` | Yes | Teacher | Teaching subject |
| `department` | `String` | Yes | Teacher | Department name |

---

## 2. Attendance Record

Used in: `/students/{id}/attendance`, `/attendance/check-in`, `/attendance/check-out`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | `String` | No | Unique record ID |
| `student_id` | `String` | No | Student reference |
| `date` | `String` | No | ISO date `YYYY-MM-DD` |
| `time_in` | `String` | Yes | ISO datetime with timezone |
| `time_out` | `String` | Yes | ISO datetime with timezone |
| `status` | `String` | No | Enum: `present`, `absent`, `late`, `excused` |

---

## 3. Attendance Summary

Used in: `/students/{id}/attendance/summary`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `total_days` | `int` | No | Total school days in period |
| `present` | `int` | No | Days present |
| `absent` | `int` | No | Days absent |
| `late` | `int` | No | Days late |
| `excused` | `int` | No | Days excused |
| `percentage` | `double` | No | Attendance percentage |

---

## 4. Timetable Slot

Used in: `/students/{id}/timetable`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `period` | `int` | No | Period number (1-6) |
| `time` | `String` | No | Time range (e.g., `08:00 AM - 08:45 AM`) |
| `subject` | `String` | No | Subject name |
| `room` | `String` | No | Room/location |
| `teacher` | `String` | No | Teacher name |

---

## 5. Subject

Used in: `/students/{id}/subjects`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | `String` | No | Unique subject ID |
| `name` | `String` | No | Subject name |
| `teacher` | `String` | No | Assigned teacher |
| `icon` | `String` | No | Material icon name hint |

---

## 6. Exam

Used in: `/students/{id}/exams`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | `String` | No | Unique exam ID |
| `name` | `String` | No | Exam name |
| `class_name` | `String` | No | Class (e.g., `Grade 10 - A`) |
| `date` | `String` | No | ISO date `YYYY-MM-DD` |
| `status` | `String` | No | Enum: `upcoming`, `completed` |
| `percentage` | `double` | Yes | Overall percentage (null if upcoming) |
| `grade` | `String` | Yes | Overall grade (null if upcoming) |
| `subjects` | `List<ExamSubjectScore>` | No | Per-subject scores (empty if upcoming) |

### 6.1 Exam Subject Score (nested)

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `name` | `String` | No | Subject name |
| `marks` | `int` | No | Marks obtained |
| `total` | `int` | No | Total marks |

---

## 7. Result

Used in: `/students/{id}/results`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `subject` | `String` | No | Subject name |
| `marks` | `int` | No | Marks obtained |
| `total` | `int` | No | Total marks |
| `grade` | `String` | No | Grade (e.g., `A+`, `B`) |

### Results Wrapper

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `exam_id` | `String` | No | Which exam |
| `exam_name` | `String` | No | Exam display name |
| `results` | `List<Result>` | No | Per-subject results |
| `total_marks` | `int` | No | Sum of marks |
| `total_possible` | `int` | No | Sum of totals |
| `percentage` | `double` | No | Overall percentage |
| `overall_grade` | `String` | No | Overall grade |

---

## 8. Fee

Used in: `/students/{id}/fees`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | `String` | No | Unique fee ID |
| `name` | `String` | No | Fee type name |
| `amount` | `double` | No | Fee amount |
| `status` | `String` | No | Enum: `paid`, `due`, `overdue`, `partial` |
| `due_date` | `String` | Yes | ISO date `YYYY-MM-DD` |

### Fee Summary (wrapper)

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `total_fees` | `double` | No | Sum of all fees |
| `total_paid` | `double` | No | Sum of paid fees |
| `total_due` | `double` | No | Remaining balance |

---

## 9. Payment

Used in: `/students/{id}/payments`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | `String` | No | Unique payment ID |
| `date` | `String` | No | ISO date `YYYY-MM-DD` |
| `amount` | `double` | No | Payment amount |
| `method` | `String` | No | Payment method (e.g., `KBZ Pay`, `Cash`) |
| `reference` | `String` | No | Transaction reference |
| `fee_name` | `String` | Yes | Which fee this payment covers |

---

## 10. Activity

Used in: `/activities`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | `String` | No | Unique activity ID |
| `title` | `String` | No | Event title |
| `date` | `String` | No | ISO date `YYYY-MM-DD` |
| `location` | `String` | No | Event location |
| `description` | `String` | Yes | Event details |
| `status` | `String` | No | Enum: `upcoming`, `completed` |

---

## 11. Notification

Used in: `/notifications`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | `String` | No | Unique notification ID |
| `title` | `String` | No | Notification title |
| `body` | `String` | No | Notification content |
| `category` | `String` | No | Enum: `exam`, `event`, `fee`, `notice`, `assignment` |
| `is_read` | `bool` | No | Read status |
| `created_at` | `String` | No | ISO datetime with timezone |

---

## 12. Class (Teacher)

Used in: `/teachers/{id}/classes`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | `String` | No | Unique class ID |
| `name` | `String` | No | Grade name (e.g., `Grade 10`) |
| `section` | `String` | No | Section (e.g., `A`) |
| `subject` | `String` | No | Subject taught |
| `student_count` | `int` | No | Number of students |

---

## 13. Class Student

Used in: `/classes/{id}/students`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | `String` | No | Student ID |
| `name` | `String` | No | Student name |
| `roll_no` | `String` | No | Roll number |
| `attendance_status` | `String` | Yes | Today's status |

---

## 14. Assignment (Teacher)

Used in: `/teachers/{id}/assignments`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | `String` | No | Unique assignment ID |
| `title` | `String` | No | Assignment title |
| `class_name` | `String` | No | Target class |
| `subject` | `String` | No | Subject |
| `due_date` | `String` | No | ISO date `YYYY-MM-DD` |
| `status` | `String` | No | Enum: `active`, `completed` |
| `description` | `String` | Yes | Full description |
| `submitted_count` | `int` | No | How many submitted |
| `total_count` | `int` | No | Total students |

---

## 15. Child (Parent)

Used in: `/parents/{id}/children`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `student_id` | `String` | No | Child's student ID |
| `name` | `String` | No | Child's name |
| `grade` | `String` | No | Grade |
| `section` | `String` | No | Section |
| `roll_no` | `String` | No | Roll number |
| `attendance_percentage` | `int` | No | Current attendance % |
| `photo_url` | `String` | Yes | Child's photo |

---

## Pagination Object

Used in all paginated list responses.

| Field | Type | Description |
|-------|------|-------------|
| `page` | `int` | Current page number |
| `per_page` | `int` | Items per page |
| `total` | `int` | Total number of items |
| `total_pages` | `int` | Total number of pages |
