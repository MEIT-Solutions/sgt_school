# SGT School — Timetable Feature Spec

## Overview

Displays the student's weekly class timetable organized by day of the week.

## User Stories

- As a **student**, I want to see my weekly class schedule so I know where to go each period.
- As a **parent**, I want to view my child's timetable.

## API Endpoint

```
GET /students/{student_id}/timetable
```

Returns a map of day names to lists of period slots.

## Domain Entity

**`TimetableSlot`** — immutable, per-period data:
- `period` (int) — e.g., 1, 2, 3
- `time` (String) — e.g., "9:00 - 9:45"
- `subject` (String)
- `teacher` (String)
- `room` (String)

## UI Flow

1. Screen opens → `TimetableProvider.loadTimetable(studentId)`
2. Displays `TabBar` with day abbreviations (Mon, Tue, ... Fri)
3. Auto-selects today's tab on first load
4. Each tab shows a `ListView` of `_PeriodCard` widgets

## Provider State

```dart
Map<String, List<TimetableSlot>> timetable  // day name → slots
List<String> days                            // ordered day names
bool isLoading
String? error
```

## Data Flow

```
TimetableScreen → TimetableProvider → TimetableRepository
                                          ↓
                                   TimetableRepositoryImpl
                                   ├── Dio GET /timetable (API)
                                   └── DemoDataService (fallback)
```
