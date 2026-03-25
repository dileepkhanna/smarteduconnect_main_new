# SmartEduConnect Flutter App — Complete Implementation Plan

## Overview

Full **Flutter mobile app** with **100% feature parity** with the web app at `e:\SChool_main\Final\src\pages\`.
Backend: Laravel at `https://smarteduconnect.in`. **57 screens · 3 portals · Clean Architecture**

---

## Project Location

`e:\SChool_main\Final\flutter_app\`

```
lib/
├── core/
│   ├── api/      # Dio client, interceptors, ApiConstants
│   ├── di/       # GetIt service locator
│   ├── router/   # GoRouter (role-based guards)
│   ├── storage/  # SharedPreferences wrapper
│   ├── theme/    # Colors, typography, dark mode
│   └── widgets/  # AppBar, BottomNav, StatCard, EmptyState, Loader
└── features/
    ├── auth/
    ├── admin/
    ├── teacher/
    └── parent/
```

Each feature: `data/` → `domain/` → `presentation/`

---

## Key Dependencies

| Package | Purpose |
|---|---|
| `dio` | HTTP + auth interceptor |
| `flutter_bloc` | State management |
| `get_it` | DI container |
| `go_router` | Role-based navigation |
| `shared_preferences` | Token persistence |
| `cached_network_image` | Photo caching |
| `fl_chart` | Bar + Pie charts |
| `google_fonts` | Inter font |
| `shimmer` | Loading skeletons |
| `image_picker` | Photo upload |
| `pdf` + `printing` | PDF receipts/reports |
| `excel` | Excel import/export (leads) |
| `table_calendar` | Attendance calendar |
| `razorpay_flutter` | Online fee payment |

---

## Auth (2 screens)

### SplashPage `/`
- Check token → `GET /auth/me` → redirect to role dashboard or login

### LoginPage `/login` (ref: `Auth.tsx`)
- **3 tabs:** Admin (email/password), Teacher (Teacher ID → resolve → password), Parent (Admission No → resolve → password)
- `POST /auth/login`, `POST /auth/resolve-teacher-email`, `POST /auth/resolve-parent-email`
- Store Bearer token + role in SharedPreferences

---

## Admin Portal — 22 screens

### 1. AdminDashboardPage `/admin` (ref: `AdminDashboard.tsx`)
- Stat cards: Students, Teachers, Classes, Pending Leave, Pending Certs, Open Complaints
- Latest 4 announcements + quick-action tiles
- `GET /dashboard/stats`

### 2. TeachersManagementPage `/admin/teachers` (ref: `TeachersManagement.tsx`)
- Teacher list (photo, name, teacher ID, email) with search
- Add/Edit dialog: name, email, password, teacher ID, phone, subject
- Delete confirmation
- `GET /teachers/management`, `POST/PUT/DELETE /teachers/{id}`

### 3. StudentsManagementPage `/admin/students` (ref: `StudentsManagement.tsx`)
- Student list with photo, name, admission no., class, status badge
- Filter by class, search; student detail profile sheet
- `GET /students`

### 4. ClassesManagementPage `/admin/classes` (ref: `ClassesManagement.tsx`)
- Class cards: section, student count, class teacher
- Add/Edit dialog: name, section, academic year, class teacher (dropdown)
- Delete confirmation
- `GET /classes/management`, `POST/PUT/DELETE /classes/{id}`

### 5. SubjectsManagementPage `/admin/subjects` (ref: `SubjectsManagement.tsx`)
- Subjects list: name, code, description
- Add/Edit/Delete dialogs
- `GET /subjects`, `POST/PUT/DELETE /subjects/{id}`

### 6. TimetableManagementPage `/admin/timetable` (ref: `TimetableManagement.tsx`)
- Class selector + timetable grid (day × period)
- Period editor dialog: subject, teacher, start/end time; add/delete period
- Publish/unpublish class timetable toggle
- Teacher schedule viewer
- `GET /admin/timetable/management-data`, `POST/PUT/DELETE /admin/timetable/{id}`, `PUT /admin/timetable/publish-class`

### 7. AttendanceManagementPage `/admin/attendance` (ref: `AttendanceManagement.tsx`)
- Date picker + class filter; student attendance summary table
- PDF report download
- `GET /attendance/report`

### 8. ExamsManagementPage `/admin/exams` (ref: `ExamsManagement.tsx`)
- Exam list; bulk create dialog (name, class, subject, date, max marks); delete
- Enter/edit marks per student per exam
- `GET /exams/data`, `POST /exams/bulk`, `DELETE /exams/{id}`, `GET|PUT /exams/{id}/marks`

### 9. WeeklyExamsManagementPage `/admin/weekly-exams` (ref: `WeeklyExamsManagement.tsx`)
- Tabs: Regular / Competitive; exam list with status
- Create/edit dialog; update status (draft/published/completed)
- Assign syllabus links; enter student results (marks, rank, percentage)
- `GET /weekly-exams/data`, `POST/PUT /weekly-exams/{id}`, `PUT /weekly-exams/{id}/status|syllabus-links|marks`

### 10. SyllabusManagementPage `/admin/syllabus` (ref: `SyllabusManagement.tsx`)
- Filter by class/subject/type; chapter → topic list with completion status
- Add/bulk-add/edit/delete dialogs; assign/remove teachers (primary/assistant role)
- `GET /admin/syllabus/data`, `POST/PUT/DELETE /admin/syllabus/{id}`, `POST/DELETE /admin/syllabus/{id}/teachers`

### 11. AnnouncementsPage `/admin/announcements` (ref: `AnnouncementsManagement.tsx`)
- Announcement list; create dialog (title, message, audience); delete
- `GET /announcements`, `POST /announcements`, `DELETE /announcements/{id}`

### 12. LeaveManagementPage `/admin/leave` (ref: `LeaveManagement.tsx`)
- Leave request list with status filter; Approve/Reject actions
- `GET /leave/requests`, `PUT /leave/requests/{id}`

### 13. ComplaintsManagementPage `/admin/complaints` (ref: `ComplaintsManagement.tsx`)
- Complaint list with status filter; mark resolved/reopen; full detail sheet
- `GET /complaints/management`, `PUT /complaints/{id}`

### 14. FeesManagementPage `/admin/fees` (ref: `FeesManagement.tsx`)
- **Tabs:** All Records | Class Summary
- Stat cards: Total Due ₹, Total Collected ₹, Overdue count
- Filter: Class → Student dropdown + Status + Search
- Fee records: Student, Class, Type, Amount, Discount, Net, Paid, Balance, Due Date, Status
- **Actions:** Edit, Delete, Record Payment, Download Receipt (PDF)
- Create Fee dialog: class → bulk-select students, type, amount, discount, due date
- Record Payment dialog: amount + payment method
- Receipt Settings dialog: school name, logo, footer text
- Export Report button: PDF with stats + full table
- Class Summary tab: per-class totals
- Student Fee Detail sheet
- `GET /fees/management-data`, `POST /fees/bulk-create`, `PUT /fees/{id}`, `POST /fees/{id}/record-payment`, `POST /fees/delete-batch`, `GET|PUT /settings/receipt-template`

### 15. CertificatesManagementPage `/admin/certificates` (ref: `CertificatesManagement.tsx`)
- Request list with status filter; Approve/Reject actions
- `GET /certificates/requests`, `PUT /certificates/requests/{id}`

### 16. GalleryManagementPage `/admin/gallery` (ref: `GalleryManagement.tsx`)
- Folder list; create/edit/delete folder; image grid inside folder
- Upload image(s), edit caption, delete image
- `GET/POST/PUT/DELETE /gallery/folders/{id}`, `GET/POST/PUT/DELETE /gallery/images/{id}`

### 17. LeadsManagementPage `/admin/leads` (ref: `LeadsManagement.tsx`)
- **Tab 1 — All Leads:** search + filter (status, class, teacher, date range)
- Lead list (cards on mobile, table on desktop)
- Actions: View detail, Edit, Add call log, Update status, Delete
- Lead entry form (full fields: name, gender, DOB, class, parents, mobile, email, area, school, board, follow-up date)
- Import Excel / Export Excel
- Lead Detail sheet: info + call history + status history
- Call log dialog: outcome, notes, follow-up date
- Status update dialog: new status + remarks
- **Tab 2 — Dashboard:** 5 stat cards + Pie chart (by status) + Bar chart (class-wise)
- Module disabled banner when leads off
- `GET/POST/DELETE /leads`, `PUT /leads/{id}/status`, `GET /leads/{id}/details`, `POST /leads/{id}/call-logs`, `GET /leads/teachers`, `POST /leads/import`

### 18. AdminMessagesPage `/admin/messages` (ref: `AdminMessages.tsx`)
- Contact list (teachers + parents); thread view; chat bubbles; send text; 5s polling
- `GET /messaging/contacts|messages`, `POST /messaging/messages`, `PUT /messaging/messages/{id}/read`

### 19. AdminNotificationsPage `/admin/notifications` (ref: `AdminNotifications.tsx`)
- Notification list with read/unread; mark single/all read; delete
- `GET /notifications`, `POST /notifications/mark-read|mark-all-read|delete-read`, `DELETE /notifications/{id}`

### 20. SettingsPage `/admin/settings` (ref: `SettingsPage.tsx`)
- **School Info:** name, email, phone, address
- **Notifications:** email/SMS/parent/push toggles
- **Account:** Change Password dialog, Invite Admin dialog (name, email, password), Sign Out
- **Razorpay:** Key ID + Key Secret (masked + eye toggle), Save button
- **Leads Module:** enable/disable toggle, mode (all/specific teachers), per-teacher permission toggles
- **Danger Zone:** Factory Reset ("RESET ALL DATA") + Full Reset ("DELETE EVERYTHING")
- `GET|PUT /settings/payment-gateway`, `POST /settings/invite-admin|factory-reset|full-reset`, `PUT /profile/password`, `GET|PUT /leads/settings`

### 21. ExamCyclesPage `/admin/exam-cycles` (ref: `ExamCyclesManagement.tsx`)
- Cycle list; create (name, dates); toggle active/inactive; delete
- `GET /admin/exam-cycles`, `POST /admin/exam-cycles`, `PUT /admin/exam-cycles/{id}/toggle-active`, `DELETE /admin/exam-cycles/{id}`

### 22. QuestionPaperBuilderPage `/admin/question-papers` (ref: `QuestionPaperBuilder.tsx`)
- Paper list; create paper (title, class, subject, total marks); delete paper
- Per paper: question list (MCQ/Short/Long type badges)
- Add/edit/delete question dialog: text, type, marks, options (MCQ), correct answer
- `GET /admin/question-papers/data`, `POST/DELETE /admin/question-papers/{id}`, `POST/PUT/DELETE /admin/questions/{id}`

---

## Teacher Portal — 17 screens

### 1. TeacherDashboardPage `/teacher` (ref: `TeacherDashboard.tsx`)
- Stats: My Classes, Students, Pending Homework; today's schedule; upcoming exams (5); competitive (1)
- `GET /teacher/dashboard`

### 2. TeacherClassesPage `/teacher/classes` (ref: `TeacherClasses.tsx`)
- Class cards (name, section, student count); tap → students
- `GET /teacher/classes`

### 3. TeacherStudentsPage `/teacher/students` (ref: `TeacherStudents.tsx`)
- Class selector; student list with search
- Add/Edit student dialog (name, class, DOB, address, blood group, parent, phone, emergency contact, email, password, photo)
- Student detail sheet + change password
- `GET /teacher/students-data`, `POST/PUT /teacher/students/{id}`

### 4. TeacherAttendancePage `/teacher/attendance` (ref: `TeacherAttendance.tsx`)
- Class + date selectors; Present/Absent/Late toggle per student; bulk mark all present; save
- `GET /teacher/attendance-data`, `PUT /teacher/attendance`

### 5. TeacherTimetablePage `/teacher/timetable` (ref: `TeacherTimetable.tsx`)
- My Schedule tab (week grid) + Class Timetable tab (class selector + grid)
- `GET /teacher/timetable-data`

### 6. TeacherHomeworkPage `/teacher/homework` (ref: `TeacherHomework.tsx`)
- Homework list with class filter; create dialog (title, desc, class, subject, due date, attachment); delete
- `GET /teacher/homework-data`, `POST /teacher/homework`, `DELETE /teacher/homework/{id}`

### 7. TeacherExamsPage `/teacher/exams` (ref: `TeacherExams.tsx`)
- Upcoming exams list; enter marks → student marks list (marks, grade, remarks); save
- `GET /teacher/exams-data`, `GET|PUT /exams/{id}/marks`

### 8. TeacherWeeklyExamsPage `/teacher/weekly-exams` (ref: `TeacherWeeklyExams.tsx`)
- Tabs: School / Competitive; enter results (marks, total, percentage, rank); save
- `GET /teacher/weekly-exams-data`, `PUT /weekly-exams/{id}/marks`

### 9. TeacherSyllabusPage `/teacher/syllabus` (ref: `TeacherSyllabus.tsx`)
- My assigned topics (class, subject, role, completion status); filter by class/subject
- Mark completed (confirm dialog); completion badge with name + date
- `GET /teacher/syllabus-data`, `PUT /teacher/syllabus/{id}/complete`

### 10. TeacherReportsPage `/teacher/reports` (ref: `TeacherReports.tsx`)
- Class + student selectors; report list; create report dialog (category, desc, severity, parent-visible toggle)
- `GET /teacher/reports-data`, `POST /teacher/reports`

### 11. TeacherLeadsPage `/teacher/leads` (ref: `TeacherLeads.tsx`)
- Same leads UI (teacher-scoped); module disabled banner
- `GET /leads`, `POST /leads`, `GET /leads/module-status`, `POST /leads/{id}/call-logs`, `PUT /leads/{id}/status`

### 12. TeacherLeavePage `/teacher/leave` (ref: `TeacherLeave.tsx`)
- Leave request list; apply dialog (reason, dates)
- `GET /teacher/leave-requests`, `POST /teacher/leave-requests`

### 13. TeacherAnnouncementsPage `/teacher/announcements`
- Read-only announcements; `GET /announcements`

### 14. TeacherGalleryPage `/teacher/gallery`
- Folder grid → image grid → full-screen viewer; `GET /gallery/folders`, `GET /gallery/folders/{id}/images`

### 15. TeacherMessagesPage `/teacher/messages`
- Shared messaging UI; contacts: admin + class parents

### 16. TeacherNotificationsPage `/teacher/notifications`
- Same notifications UI as admin

### 17. TeacherSettingsPage `/teacher/settings` (ref: `TeacherSettings.tsx`)
- Edit profile, upload photo, change password, push notifications toggle, sign out
- `GET|PUT /profile`, `POST /profile/photo`, `PUT /profile/password`

---

## Parent Portal — 17 screens

### 1. ParentDashboardPage `/parent` (ref: `ParentDashboard.tsx`)
- Child card; stats: pending fees, homework, upcoming exams; announcements (4)
- `GET /parent/dashboard`

### 2. ParentChildPage `/parent/child` (ref: `ParentChild.tsx`)
- Child profile: photo, name, admission, class, DOB, blood group, address, parent/emergency contact
- `GET /parent/children-data`

### 3. ParentAttendancePage `/parent/attendance` (ref: `ParentAttendance.tsx`)
- Colour-coded calendar (table_calendar); summary stats; date range filter
- `GET /parent/attendance-data`

### 4. ParentTimetablePage `/parent/timetable` (ref: `ParentTimetable.tsx`)
- Day tabs (Mon–Sat); period list: time, subject, teacher
- `GET /parent/timetable-data`

### 5. ParentHomeworkPage `/parent/homework` (ref: `ParentHomework.tsx`)
- Homework list: subject, title, desc, due date, overdue badge, attachment link
- `GET /parent/homework-data`

### 6. ParentSyllabusPage `/parent/syllabus` (ref: `ParentSyllabus.tsx`)
- School/competitive type filter; grouped by subject; topics with completion tick + teacher
- `GET /parent/syllabus-data`

### 7. ParentExamsPage `/parent/exams` (ref: `ParentExams.tsx`)
- Tabs: School | Competitive; marks card (subject, date, marks, grade, remarks); competitive rank
- `GET /parent/exams-data`

### 8. ParentProgressPage `/parent/progress` (ref: `ParentProgress.tsx`)
- Progress reports (severity badge); exam bar chart (subject vs. marks %); attendance summary
- `GET /parent/progress-data`

### 9. ParentFeesPage `/parent/fees` (ref: `ParentFees.tsx`)
- Fee cards per child: type, amount, discount, net, paid, balance, due date, status
- Payment history list (amount, method, receipt no., date)
- **Pay Online:** Razorpay checkout → verify payment
- `GET /parent/fees-data`, `POST /parent/fees/{id}/create-order`, `POST /parent/fees/{id}/verify-payment`

### 10. ParentCertificatesPage `/parent/certificates` (ref: `ParentCertificates.tsx`)
- Request list with status; request dialog (type, reason)
- `GET /parent/certificate-requests`, `POST /parent/certificate-requests`

### 11. ParentLeavePage `/parent/leave` (ref: `ParentLeave.tsx`)
- Leave list with status; apply dialog (reason, dates)
- `GET /parent/leave-requests`, `POST /parent/leave-requests`

### 12. ParentComplaintsPage `/parent/complaints` (ref: `ParentComplaints.tsx`)
- Complaint list with admin response; file complaint dialog (subject, desc)
- `GET /parent/complaints`, `POST /parent/complaints`

### 13. ParentAnnouncementsPage `/parent/announcements`
- Read-only; `GET /announcements`

### 14. ParentGalleryPage `/parent/gallery`
- Folder grid → image grid → full-screen viewer (pinch-to-zoom)

### 15. ParentMessagesPage `/parent/messages`
- Messaging with teachers and admin

### 16. ParentNotificationsPage `/parent/notifications`
- Same notifications UI

### 17. ParentSettingsPage `/parent/settings` (ref: `ParentSettings.tsx`)
- Edit profile, upload photo, change password, push notifications, sign out
- `GET|PUT /profile`, `POST /profile/photo`, `PUT /profile/password`

---

## Shared Infrastructure

- **API Client:** `DioClient` — base URL + Bearer token interceptor + 401 → logout
- **Router:** GoRouter shell routes for bottom nav; role-based redirect guards
- **Theme:** Admin (indigo), Teacher (green), Parent (orange); dark mode; Inter font
- **Messaging widget:** shared across all 3 portals (5s polling)

---

## Verification Plan

| Role | E2E Flow |
|---|---|
| Admin | Login → Dashboard → Create teacher → Add student → Mark fee → Approve leave → Settings |
| Teacher | Login (Teacher ID) → Mark attendance → Homework → Enter exam marks → Syllabus |
| Parent | Login (admission no.) → View child → Pay fee (Razorpay) → Apply leave → Complaint |

```bash
flutter analyze   # 0 errors
flutter test      # all pass
```

> [!IMPORTANT]
> Need working credentials for admin, teacher, and parent roles at `https://smarteduconnect.in` to run end-to-end tests.
