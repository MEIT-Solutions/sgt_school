# SGT School — Fees & Payments Feature Spec

## Overview

Shows fee summary, line-item breakdown, and payment history with tabbed view.

## User Stories

- As a **student/parent**, I want to see total fees, due amounts, and payment records.

## API Endpoints

```
GET /students/{student_id}/fees
GET /students/{student_id}/fees/summary
GET /students/{student_id}/fees/payments
```

## Domain Entities

**`FeeEntity`**: `id`, `name`, `amount`, `status` (paid/due), `dueDate`
**`FeeSummary`**: `totalFees`, `totalPaid`, `totalDue`
**`PaymentEntity`**: `id`, `amount`, `date`, `method`, `reference`

## UI Flow

1. `FeeProvider.loadFees(studentId)` — loads all 3 API calls in parallel
2. Summary card at top (total fees | due amount)
3. `TabBar`: Fee Details | Payment History
4. Fee details show paid/due badges
5. Payments show receipt icon with method and reference

---

# SGT School — Activities Feature Spec

## Overview

Lists school events and activities with All/Upcoming/Completed tabs.

## API Endpoint

```
GET /activities?status=upcoming|completed
```

## Domain Entity

**`ActivityEntity`**: `id`, `title`, `date`, `location`, `status`, `description`

## UI Flow

1. `ActivityProvider.loadActivities()` on screen init
2. `TabBar`: All | Upcoming | Completed
3. Each activity shows event icon, title, date + location

---

# SGT School — Notifications Feature Spec

## Overview

Bell-icon notifications list showing exam, event, fee, and assignment alerts.

## API Endpoints

```
GET /notifications?role={role}
PUT /notifications/{id}/read
```

## Domain Entity

**`NotificationEntity`**: `id`, `title`, `body`, `category` (exam/event/fee/notice/assignment), `isRead`, `createdAt`

## UI Flow

1. `NotificationProvider.loadNotifications(role)` on screen init
2. `ListView` with category-colored icon, title, body preview, timestamp
3. `unreadCount` getter drives badge on bell icon
