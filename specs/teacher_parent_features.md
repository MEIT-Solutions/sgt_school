# SGT School — Teacher Features Spec

## Overview

Teacher-specific features: class management, student rosters, assignments, and attendance marking.

---

## Classes Feature

### User Stories
- As a **teacher**, I want to see my assigned classes and view student lists.

### API Endpoints
```
GET /teachers/{teacher_id}/classes
GET /classes/{class_id}/students
```

### Domain Entities
- **`ClassEntity`**: `id`, `name`, `section`, `subject`, `studentCount`
  - `displayName` → `"$name - $section"`
- **`ClassStudentEntity`**: `id`, `name`, `rollNo`, `attendanceStatus`

### UI Flow
1. `ClassesScreen` → `ClassProvider.loadClasses(teacherId)`
2. List with class icon, display name, subject + student count
3. Tap → `ClassDetailScreen` with student roster
4. FAB → `MarkAttendanceScreen` for daily attendance

### MarkAttendanceScreen
- Shows date header + student list with `SegmentedButton` (Present/Late/Absent)
- Save button → shows success toast

---

## Assignments Feature

### User Stories
- As a **teacher**, I want to manage and track assignment submissions.

### API Endpoint
```
GET /teachers/{teacher_id}/assignments?status=active|completed
```

### Domain Entity
**`AssignmentEntity`**: `id`, `title`, `className`, `subject`, `dueDate`, `status`, `submittedCount`, `totalCount`

### UI Flow
1. `AssignmentsScreen` → `AssignmentProvider.loadAssignments(teacherId)`
2. `TabBar`: Active | Completed
3. Each card shows title, class/subject, due date, submission count

---

# SGT School — Parent Features Spec

## Overview

Parent-specific features: viewing children's academic data.

## Children Feature

### User Stories
- As a **parent**, I want to see all my children and their attendance/academic summaries.

### API Endpoint
```
GET /parents/{parent_id}/children
```

### Domain Entity
**`ChildEntity`**: `id`, `studentId`, `name`, `classDisplay`, `rollNo`, `attendancePercentage`

### UI Flow
1. `ChildrenScreen` → `ChildProvider.loadChildren(parentId)`
2. List with avatar, name, class/roll, attendance percentage
3. Tap → `ChildDetailScreen` with attendance/exams/fees summary (loaded via repos)
