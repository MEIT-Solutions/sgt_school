# SGT School — Subjects Feature Spec

## Overview

Lists all subjects assigned to a student with teacher names and visual icons.

## User Stories

- As a **student**, I want to see all my subjects and who teaches them.

## API Endpoint

```
GET /students/{student_id}/subjects
```

## Domain Entity

**`SubjectEntity`**:
- `id`, `name`, `teacher`, `icon` (String — maps to Material icon key)

## UI Flow

1. `SubjectProvider.loadSubjects(studentId)` on screen init
2. `ListView` with colored icon cards, subject name, and teacher name

---

# SGT School — Exams Feature Spec

## Overview

Lists upcoming and completed exams with tabbed view.

## User Stories

- As a **student**, I want to see upcoming exam dates and completed exam results.

## API Endpoint

```
GET /students/{student_id}/exams?status=upcoming|completed
```

## Domain Entity

**`ExamEntity`**:
- `id`, `name`, `date`, `status` (upcoming/completed)
- `grade`, `percentage`, `totalMarks`, `obtainedMarks` — nullable for upcoming

## UI Flow

1. `ExamProvider.loadExams(studentId)` on screen init
2. `TabBar`: Upcoming | Completed
3. Completed exams are tappable → navigate to results

---

# SGT School — Results Feature Spec

## Overview

Shows exam results with grades per subject.

## API Endpoint

```
GET /students/{student_id}/results?exam_id={exam_id}
```

## Domain Entities

**`ResultEntity`**: `id`, `subject`, `marks`, `total`, `grade`, `percentage`
**`ResultSummary`**: `results` list, `totalMarks`, `totalObtained`, `overallPercentage`, `overallGrade`

## UI Flow

1. `ResultProvider.loadResults(studentId)` on screen init
2. `ListView` with grade badge, subject name, marks fraction, percentage chip
