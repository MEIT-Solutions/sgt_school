# SGT School — Attendance Feature Spec

## Overview

Student attendance with daily check-in/out via API, monthly swipeable calendar view,
per-date detail loading, and statistics. All operations are API-first with demo fallback
for the current demo version.

## User Stories

- As a **student**, I want to check in each school day with a confirmation dialog.
- As a **student**, I want to check out with a confirmation showing the current time.
- As a **student**, I want to see my monthly attendance with a swipeable color-coded calendar.
- As a **student**, I want to tap any date to see check-in time, check-out time, and status.
- As a **student**, I want the app to remember my check-in status even after closing and reopening.
- As a **teacher**, I want to mark attendance for my class students.

---

## Edge Cases & State Diagram

### App Open → State Restoration
```
App Open → GET /students/{student_id}/attendance?date=today
    ├── API returns record with timeIn only → Show "Check Out" button
    ├── API returns record with timeIn + timeOut → Show "Completed" badge
    ├── API returns null/empty → Show "Check In" button
    └── API fails (network error)
        └── Demo fallback: return null → Show "Check In" button
            (User proceeds with check-in; API will reject with 409 if
             already done when backend is ready)
```

### Edge Cases Handled
| Scenario | Behavior |
|----------|----------|
| App cleared & reopened | `getTodayRecord()` calls API to restore state |
| No internet during check-in | Error toast, button stays enabled for retry |
| No internet during check-out | Error toast, button stays enabled for retry |
| API returns 409 (already checked in) | Error mapped to failure, UI refreshes today record |
| API returns 400 (not checked in yet) | Error mapped to failure, UI stays on check-in |
| User opens calendar for past month | `getMonthlyRecords(month: "YYYY-MM")` loads that month |
| User taps date with no record | "No attendance record for this date" message |
| Rapid check-in taps | Button disabled during API call (isCheckingIn state) |
| Backend not ready | Demo fallback returns simulated success |

---

## Check-In Flow

```
┌──────────────┐
│ User taps    │
│ "Check In"   │
└──────┬───────┘
       │
       ▼
┌──────────────────────┐
│ Show Confirmation    │
│ Dialog:              │
│ "Check in at 8:45 AM?"│
│ [Cancel] [Confirm]   │
└──────┬───────────────┘
       │
       ├── Cancel → Nothing happens (dialog closes)
       │
       ▼ Confirm
┌──────────────────────┐
│ isCheckingIn = true  │
│ Button shows spinner │
│ POST /attendance/    │
│      check-in        │
└──────┬───────────────┘
       │
       ├── 201 Success
       │   ├── todayRecord = response
       │   ├── Success toast: "Checked in successfully!"
       │   └── UI shows "Check Out" button
       │
       ├── 409 Conflict (already checked in)
       │   ├── Error toast
       │   └── Refresh todayRecord from API
       │
       ├── DioException (API not ready)
       │   ├── Demo fallback: simulate success
       │   ├── todayRecord = demo record
       │   └── Success toast
       │
       └── Network Error / Server Error
           ├── Error toast: "Check-in failed. Please try again."
           ├── isCheckingIn = false
           └── Button re-enabled for retry
```

---

## Check-Out Flow

```
┌──────────────┐
│ User taps    │
│ "Check Out"  │
└──────┬───────┘
       │
       ▼
┌──────────────────────┐
│ Show Confirmation    │
│ Dialog:              │
│ "Check out at 3:30 PM?"│
│ [Cancel] [Confirm]    │
└──────┬───────────────┘
       │
       ├── Cancel → Nothing happens
       │
       ▼ Confirm
┌──────────────────────┐
│ isCheckingOut = true │
│ Button shows spinner │
│ POST /attendance/    │
│      check-out       │
└──────┬───────────────┘
       │
       ├── 200 Success
       │   ├── todayRecord = response (with timeOut)
       │   ├── Success toast: "Checked out successfully!"
       │   └── UI shows "Completed for today" badge
       │
       ├── 400 (not checked in)
       │   ├── Error toast
       │   └── Refresh todayRecord from API
       │
       ├── DioException (API not ready)
       │   ├── Demo fallback: simulate success
       │   └── UI shows "Completed" badge
       │
       └── Network Error / Server Error
           ├── Error toast: "Check-out failed. Please try again."
           ├── isCheckingOut = false
           └── Button re-enabled for retry
```

---

## Calendar Date Tap Flow

```
┌─────────────────┐
│ User taps date  │
│ on calendar     │
└──────┬──────────┘
       │
       ▼
┌─────────────────────┐
│ Highlight date      │
│ isLoadingDate = true│
│ GET /attendance?    │
│   date=YYYY-MM-DD   │
└──────┬──────────────┘
       │
       ├── Success (record found)
       │   └── Show detail card:
       │       - Status badge (Present/Absent/Late)
       │       - Time In: 7:50 AM
       │       - Time Out: 3:30 PM
       │
       ├── Success (no record)
       │   └── Show: "No attendance record for this date"
       │
       └── API Error
           └── Use cached data from monthlyRecords
               ├── Found → show detail card
               └── Not found → "No record" message
```

---

## Calendar Month Navigation (Swipe)

```
┌─────────────────┐
│ User swipes     │
│ left/right      │
│ on calendar     │
└──────┬──────────┘
       │
       ▼
┌─────────────────────┐
│ PageView animates   │
│ to prev/next month  │
│ Clear selected date │
│ isLoadingMonthly=true│
│ GET /attendance?    │
│   month=YYYY-MM     │
└──────┬──────────────┘
       │
       ├── Success → Update calendar dots
       └── Error → Keep showing previous data
```

---

## API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `POST` | `/attendance/check-in` | Student daily check-in |
| `POST` | `/attendance/check-out` | Student daily check-out |
| `GET` | `/students/{id}/attendance?date=YYYY-MM-DD` | Single date record (today or tapped date) |
| `GET` | `/students/{id}/attendance?month=YYYY-MM` | Monthly records for calendar |
| `GET` | `/students/{id}/attendance/summary?month=YYYY-MM` | Monthly stats |

---

## Domain Entity

**`AttendanceRecord`** (immutable):
- `id` (String)
- `studentId` (String)
- `date` (String — `YYYY-MM-DD`)
- `status` (AttendanceStatus enum: present/absent/late/excused)
- `timeIn` (DateTime?)
- `timeOut` (DateTime?)
- `hasCheckedIn` → `timeIn != null`
- `hasCheckedOut` → `timeOut != null`
- `isComplete` → `hasCheckedIn && hasCheckedOut`

**`AttendanceSummary`**:
- `totalDays`, `present`, `absent`, `late`, `excused`
- `percentage` (double)

---

## Provider: `AttendanceCheckProvider`

### State Fields
| Field | Type | Purpose |
|-------|------|---------|
| `todayRecord` | `AttendanceRecord?` | Today's check-in/out status |
| `monthlyRecords` | `List<AttendanceRecord>` | Calendar data |
| `selectedDateRecord` | `AttendanceRecord?` | Tapped date detail |
| `isLoadingToday` | `bool` | Loading today's record on init |
| `isCheckingIn` | `bool` | Check-in API in progress (button spinner) |
| `isCheckingOut` | `bool` | Check-out API in progress (button spinner) |
| `isLoadingMonthly` | `bool` | Loading monthly records |
| `isLoadingDate` | `bool` | Loading tapped date record |

### Methods
| Method | Returns | Triggers |
|--------|---------|----------|
| `loadTodayRecord(studentId)` | `void` | App open, state restoration |
| `checkIn(studentId)` | `bool` (success/fail) | Confirmation dialog → Confirm |
| `checkOut(studentId)` | `bool` (success/fail) | Confirmation dialog → Confirm |
| `loadMonthlyRecords(studentId, {month})` | `void` | Screen init, month swipe |
| `loadRecordByDate(studentId, date)` | `void` | Calendar date tap |
| `clearSelectedDate()` | `void` | Month change |

---

## Data Flow

```
AttendanceScreen → AttendanceCheckProvider → AttendanceRepository
                                                  ↓
                                           AttendanceRepositoryImpl
                                           ├── Dio (API calls)
                                           └── DemoDataService (fallback when API unavailable)
```
