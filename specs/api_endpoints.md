# SGT School — REST API Specification

> **Base URL**: `https://sgt.meisolutions.com/v1`  
> **Auth**: All endpoints (except login) require `Authorization: Bearer <token>` header.  
> **Content-Type**: `application/json`  
> **Pagination**: List endpoints support `?page=1&per_page=20` query parameters.

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Students](#2-students)
3. [Attendance](#3-attendance)
4. [Timetable](#4-timetable)
5. [Subjects](#5-subjects)
6. [Exams](#6-exams)
7. [Results](#7-results)
8. [Fees & Payments](#8-fees--payments)
9. [Activities](#9-activities)
10. [Notifications](#10-notifications)
11. [Teachers](#11-teachers)
12. [Parents](#12-parents)

---

## Common Response Envelope

All successful list responses follow this paginated format:

```json
{
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

All successful single-object responses:

```json
{
  "data": { ... }
}
```

All error responses:

```json
{
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid phone number or password"
  }
}
```

---

## 1. Authentication

### 1.1 Login

**`POST /auth/login`** — *No auth required*

**Request Body:**
```json
{
  "phone": "092201931",
  "password": "student123"
}
```

**Success Response (200):**
```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "role": "student",
    "profile": {
      "id": "STU-001",
      "name": "Aung Min Htet",
      "phone": "092201931",
      "email": "aungminhtet@sgtschool.edu",
      "date_of_birth": "2010-03-14",
      "gender": "male",
      "address": "No. 45, Bogyoke Road, Taunggyi",
      "photo_url": null,
      "grade": "Grade 10",
      "section": "A",
      "roll_no": "12",
      "admission_no": "ADM20240012",
      "class_teacher": "U Thein Aung",
      "academic_year": "2025 - 2026",
      "parent_name": "Daw Khin May",
      "parent_phone": "092201932",
      "parent_relation": "Mother",
      "emergency_contact": "09200000002",
      "emergency_name": "U Kyaw Soe",
      "subject": null,
      "department": null
    }
  }
}
```

> **Note**: `grade`, `section`, `roll_no`, `admission_no`, `class_teacher`, `academic_year`, `parent_*`, `emergency_*` are only present for `role: "student"`.  
> `subject`, `department` are only present for `role: "teacher"`.

**Error Response (401):**
```json
{
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid phone number or password"
  }
}
```

### 1.2 Logout

**`POST /auth/logout`** — *Auth required*

**Request Body:** *empty*

**Success Response (200):**
```json
{
  "data": {
    "message": "Logged out successfully"
  }
}
```

### 1.3 Get Current User Profile

**`GET /auth/me`** — *Auth required*

**Success Response (200):**
Same profile shape as login response's `profile` field.

---

## 2. Students

### 2.1 Get Student Profile

**`GET /students/{student_id}/profile`** — *Auth required*

**Success Response (200):**
```json
{
  "data": {
    "id": "STU-001",
    "name": "Aung Min Htet",
    "phone": "092201931",
    "email": "aungminhtet@sgtschool.edu",
    "date_of_birth": "2010-03-14",
    "gender": "male",
    "address": "No. 45, Bogyoke Road, Taunggyi",
    "photo_url": null,
    "grade": "Grade 10",
    "section": "A",
    "roll_no": "12",
    "admission_no": "ADM20240012",
    "class_teacher": "U Thein Aung",
    "academic_year": "2025 - 2026",
    "parent_name": "Daw Khin May",
    "parent_phone": "092201932",
    "parent_relation": "Mother",
    "emergency_contact": "09200000002",
    "emergency_name": "U Kyaw Soe"
  }
}
```

---

## 3. Attendance

### 3.1 Get Attendance Records

**`GET /students/{student_id}/attendance`** — *Auth required*

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `month` | `String` | No | `YYYY-MM` format. Defaults to current month |
| `page` | `int` | No | Page number. Default: 1 |
| `per_page` | `int` | No | Records per page. Default: 20 |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": "ATT-001",
      "student_id": "STU-001",
      "date": "2026-04-23",
      "time_in": "2026-04-23T07:50:00+06:30",
      "time_out": "2026-04-23T15:30:00+06:30",
      "status": "present"
    },
    {
      "id": "ATT-002",
      "student_id": "STU-001",
      "date": "2026-04-22",
      "time_in": "2026-04-22T08:45:00+06:30",
      "time_out": "2026-04-22T15:30:00+06:30",
      "status": "late"
    },
    {
      "id": "ATT-003",
      "student_id": "STU-001",
      "date": "2026-04-21",
      "time_in": null,
      "time_out": null,
      "status": "absent"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 22,
    "total_pages": 2
  }
}
```

**Status enum values**: `present`, `absent`, `late`, `excused`

### 3.2 Get Attendance Summary

**`GET /students/{student_id}/attendance/summary`** — *Auth required*

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `month` | `String` | No | `YYYY-MM` format. Defaults to current month |

**Success Response (200):**
```json
{
  "data": {
    "total_days": 22,
    "present": 18,
    "absent": 2,
    "late": 2,
    "excused": 0,
    "percentage": 90.9
  }
}
```

### 3.3 Student Check-In

**`POST /attendance/check-in`** — *Auth required*

**Request Body:**
```json
{
  "student_id": "STU-001"
}
```

**Success Response (201):**
```json
{
  "data": {
    "id": "ATT-100",
    "student_id": "STU-001",
    "date": "2026-04-26",
    "time_in": "2026-04-26T07:48:00+06:30",
    "time_out": null,
    "status": "present"
  }
}
```

**Error Response (409 Conflict):**
```json
{
  "error": {
    "code": "ALREADY_CHECKED_IN",
    "message": "Student has already checked in today"
  }
}
```

### 3.4 Student Check-Out

**`POST /attendance/check-out`** — *Auth required*

**Request Body:**
```json
{
  "student_id": "STU-001"
}
```

**Success Response (200):**
```json
{
  "data": {
    "id": "ATT-100",
    "student_id": "STU-001",
    "date": "2026-04-26",
    "time_in": "2026-04-26T07:48:00+06:30",
    "time_out": "2026-04-26T15:30:00+06:30",
    "status": "present"
  }
}
```

**Error Response (400):**
```json
{
  "error": {
    "code": "NOT_CHECKED_IN",
    "message": "Student has not checked in today"
  }
}
```

---

## 4. Timetable

### 4.1 Get Student Timetable

**`GET /students/{student_id}/timetable`** — *Auth required*

**Success Response (200):**
```json
{
  "data": {
    "Monday": [
      {
        "period": 1,
        "time": "08:00 AM - 08:45 AM",
        "subject": "Mathematics",
        "room": "Room 101",
        "teacher": "U Thein Aung"
      },
      {
        "period": 2,
        "time": "08:45 AM - 09:30 AM",
        "subject": "Science",
        "room": "Room 102",
        "teacher": "Daw Aye Aye"
      }
    ],
    "Tuesday": [ ... ],
    "Wednesday": [ ... ],
    "Thursday": [ ... ],
    "Friday": [ ... ]
  }
}
```

> **Note**: No pagination needed — weekly timetable is a fixed small dataset.

---

## 5. Subjects

### 5.1 Get Student Subjects

**`GET /students/{student_id}/subjects`** — *Auth required*

**Success Response (200):**
```json
{
  "data": [
    {
      "id": "SUB-01",
      "name": "Mathematics",
      "teacher": "U Thein Aung",
      "icon": "calculate"
    },
    {
      "id": "SUB-02",
      "name": "Science",
      "teacher": "Daw Aye Aye",
      "icon": "science"
    }
  ]
}
```

> **Note**: No pagination needed — small fixed list per student.

---

## 6. Exams

### 6.1 Get Student Exams

**`GET /students/{student_id}/exams`** — *Auth required*

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `status` | `String` | No | Filter: `upcoming`, `completed`, or omit for all |
| `page` | `int` | No | Default: 1 |
| `per_page` | `int` | No | Default: 20 |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": "EXM-01",
      "name": "Mid Term Exam",
      "class_name": "Grade 10 - A",
      "date": "2026-03-10",
      "status": "completed",
      "percentage": 85.0,
      "grade": "A",
      "subjects": [
        { "name": "Mathematics", "marks": 88, "total": 100 },
        { "name": "Science", "marks": 82, "total": 100 },
        { "name": "English", "marks": 78, "total": 100 }
      ]
    },
    {
      "id": "EXM-04",
      "name": "Final Exam",
      "class_name": "Grade 10 - A",
      "date": "2026-05-15",
      "status": "upcoming",
      "percentage": null,
      "grade": null,
      "subjects": []
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 5,
    "total_pages": 1
  }
}
```

---

## 7. Results

### 7.1 Get Student Results (Latest Exam)

**`GET /students/{student_id}/results`** — *Auth required*

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `exam_id` | `String` | No | Specific exam. Defaults to latest completed exam |

**Success Response (200):**
```json
{
  "data": {
    "exam_id": "EXM-01",
    "exam_name": "Mid Term Exam",
    "results": [
      { "subject": "Mathematics", "marks": 92, "total": 100, "grade": "A+" },
      { "subject": "English", "marks": 85, "total": 100, "grade": "A" },
      { "subject": "Science", "marks": 78, "total": 100, "grade": "B+" },
      { "subject": "Myanmar", "marks": 88, "total": 100, "grade": "A" },
      { "subject": "History", "marks": 72, "total": 100, "grade": "B" },
      { "subject": "Geography", "marks": 65, "total": 100, "grade": "C+" }
    ],
    "total_marks": 480,
    "total_possible": 600,
    "percentage": 80.0,
    "overall_grade": "A-"
  }
}
```

---

## 8. Fees & Payments

### 8.1 Get Student Fees

**`GET /students/{student_id}/fees`** — *Auth required*

**Success Response (200):**
```json
{
  "data": [
    {
      "id": "FEE-01",
      "name": "Tuition Fee",
      "amount": 600.00,
      "status": "paid",
      "due_date": "2026-01-31"
    },
    {
      "id": "FEE-02",
      "name": "Library Fee",
      "amount": 100.00,
      "status": "due",
      "due_date": "2026-05-31"
    }
  ],
  "summary": {
    "total_fees": 1200.00,
    "total_paid": 900.00,
    "total_due": 300.00
  }
}
```

**Status enum values**: `paid`, `due`, `overdue`, `partial`

### 8.2 Get Payment History

**`GET /students/{student_id}/payments`** — *Auth required*

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `page` | `int` | No | Default: 1 |
| `per_page` | `int` | No | Default: 20 |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": "PAY-001",
      "date": "2026-01-15",
      "amount": 600.00,
      "method": "KBZ Pay",
      "reference": "PAY-2026-001",
      "fee_name": "Tuition Fee"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 3,
    "total_pages": 1
  }
}
```

---

## 9. Activities

### 9.1 Get School Activities

**`GET /activities`** — *Auth required*

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `status` | `String` | No | `upcoming`, `completed`, or omit for all |
| `page` | `int` | No | Default: 1 |
| `per_page` | `int` | No | Default: 20 |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": "ACT-01",
      "title": "Science Exhibition",
      "date": "2026-05-18",
      "location": "School Auditorium",
      "description": "Annual science exhibition showcasing student projects.",
      "status": "upcoming"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 5,
    "total_pages": 1
  }
}
```

---

## 10. Notifications

### 10.1 Get Notifications

**`GET /notifications`** — *Auth required*

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `page` | `int` | No | Default: 1 |
| `per_page` | `int` | No | Default: 20 |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": "NOT-01",
      "title": "Mid Term Exam Schedule",
      "body": "The mid term exam will start from 10 March, 2026.",
      "category": "exam",
      "is_read": false,
      "created_at": "2026-04-24T10:00:00+06:30"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 7,
    "total_pages": 1
  }
}
```

**Category enum values**: `exam`, `event`, `fee`, `notice`, `assignment`

### 10.2 Mark Notification as Read

**`PATCH /notifications/{notification_id}/read`** — *Auth required*

**Request Body:** *empty*

**Success Response (200):**
```json
{
  "data": {
    "id": "NOT-01",
    "is_read": true
  }
}
```

---

## 11. Teachers

### 11.1 Get Teacher Classes

**`GET /teachers/{teacher_id}/classes`** — *Auth required*

**Success Response (200):**
```json
{
  "data": [
    {
      "id": "CLS-01",
      "name": "Grade 10",
      "section": "A",
      "subject": "Mathematics",
      "student_count": 35
    },
    {
      "id": "CLS-02",
      "name": "Grade 10",
      "section": "B",
      "subject": "Mathematics",
      "student_count": 32
    }
  ]
}
```

### 11.2 Get Students in a Class

**`GET /classes/{class_id}/students`** — *Auth required*

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `page` | `int` | No | Default: 1 |
| `per_page` | `int` | No | Default: 50 |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": "STU-001",
      "name": "Aung Min Htet",
      "roll_no": "12",
      "attendance_status": "present"
    },
    {
      "id": "STU-004",
      "name": "Ko Ko Aung",
      "roll_no": "15",
      "attendance_status": "absent"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 50,
    "total": 35,
    "total_pages": 1
  }
}
```

### 11.3 Mark Attendance for a Class (Batch)

**`POST /classes/{class_id}/attendance`** — *Auth required*

**Request Body:**
```json
{
  "date": "2026-04-26",
  "records": [
    { "student_id": "STU-001", "status": "present" },
    { "student_id": "STU-004", "status": "absent" },
    { "student_id": "STU-006", "status": "late" }
  ]
}
```

**Success Response (201):**
```json
{
  "data": {
    "class_id": "CLS-01",
    "date": "2026-04-26",
    "total_marked": 35,
    "present": 30,
    "absent": 3,
    "late": 2
  }
}
```

### 11.4 Get Teacher Assignments

**`GET /teachers/{teacher_id}/assignments`** — *Auth required*

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `status` | `String` | No | `active`, `completed`, or omit for all |
| `page` | `int` | No | Default: 1 |
| `per_page` | `int` | No | Default: 20 |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": "ASG-01",
      "title": "Algebra Practice Set",
      "class_name": "Grade 10 - A",
      "subject": "Mathematics",
      "due_date": "2026-05-20",
      "status": "active",
      "description": "Complete exercises 1-20 from Chapter 5. Show all working.",
      "submitted_count": 28,
      "total_count": 35
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 4,
    "total_pages": 1
  }
}
```

### 11.5 Create Assignment

**`POST /teachers/{teacher_id}/assignments`** — *Auth required*

**Request Body:**
```json
{
  "title": "Calculus Homework",
  "class_id": "CLS-01",
  "subject": "Mathematics",
  "due_date": "2026-06-01",
  "description": "Complete problems 1-15 from Chapter 8."
}
```

**Success Response (201):**
```json
{
  "data": {
    "id": "ASG-05",
    "title": "Calculus Homework",
    "class_name": "Grade 10 - A",
    "subject": "Mathematics",
    "due_date": "2026-06-01",
    "status": "active",
    "description": "Complete problems 1-15 from Chapter 8.",
    "submitted_count": 0,
    "total_count": 35
  }
}
```

---

## 12. Parents

### 12.1 Get Parent's Children

**`GET /parents/{parent_id}/children`** — *Auth required*

**Success Response (200):**
```json
{
  "data": [
    {
      "student_id": "STU-001",
      "name": "Aung Min Htet",
      "grade": "Grade 10",
      "section": "A",
      "roll_no": "12",
      "attendance_percentage": 92,
      "photo_url": null
    },
    {
      "student_id": "STU-002",
      "name": "Aye Myat Mon",
      "grade": "Grade 10",
      "section": "A",
      "roll_no": "5",
      "attendance_percentage": 96,
      "photo_url": null
    }
  ]
}
```

> **Note**: Parent can then use `GET /students/{student_id}/attendance`, `GET /students/{student_id}/exams`, etc. to view their child's data.

---

## Error Code Reference

| HTTP Status | Code | Description |
|-------------|------|-------------|
| 400 | `BAD_REQUEST` | Missing or invalid request body |
| 401 | `UNAUTHORIZED` | Missing or invalid auth token |
| 401 | `INVALID_CREDENTIALS` | Wrong phone/password |
| 403 | `FORBIDDEN` | User doesn't have permission |
| 404 | `NOT_FOUND` | Resource not found |
| 409 | `ALREADY_CHECKED_IN` | Duplicate check-in attempt |
| 409 | `ALREADY_CHECKED_OUT` | Duplicate check-out attempt |
| 400 | `NOT_CHECKED_IN` | Check-out without check-in |
| 422 | `VALIDATION_ERROR` | Request body validation failed |
| 500 | `INTERNAL_ERROR` | Unexpected server error |
