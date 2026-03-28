# SmartEduConnect - Complete API List

## Overview
This document lists all API endpoints included in the Flutter Postman collection.

**Base URL:** `https://smarteduconnect.in:8080/api`

**Total Sections:** 21
**Total Endpoints:** 150+

---

## 1. Authentication (7 endpoints)
- ✅ Check Admin Exists
- ✅ Register User
- ✅ Login
- ✅ Resolve Teacher Email
- ✅ Resolve Parent Email
- ✅ Get Current User
- ✅ Logout

## 2. Dashboard (1 endpoint)
- ✅ Get Dashboard Stats

## 3. Classes (3 endpoints)
- ✅ Get All Classes
- ✅ Create Class (admin)
- ✅ Get Classes Management (admin)

## 4. Students (4 endpoints)
- ✅ Get All Students
- ✅ Get Student by ID
- ✅ Get Student Attendance Summary
- ✅ Get Student Exam Marks

## 5. Attendance (2 endpoints)
- ✅ Get Attendance Report
- ✅ Mark Attendance (teacher/admin)

## 6. Exams (2 endpoints)
- ✅ Get Exams Data
- ✅ Get Exam Cycles

## 7. Notifications (9 endpoints)
- ✅ Get Notifications (paginated)
- ✅ Get Unread Count
- ✅ Mark Notification as Read
- ✅ Mark All as Read
- ✅ Delete Read Notifications
- ✅ Delete Notification
- ✅ Get VAPID Public Key
- ✅ Subscribe to Push Notifications
- ✅ Unsubscribe from Push Notifications

## 8. Messages (4 endpoints)
- ✅ Get Conversations
- ✅ Get Messages with User
- ✅ Send Message
- ✅ Mark Messages as Read

## 9. Profile (4 endpoints)
- ✅ Get Profile
- ✅ Update Profile
- ✅ Upload Profile Photo
- ✅ Change Password

## 10. Parent Portal (6 endpoints)
- ✅ Get Children List
- ✅ Get Fees Data
- ✅ Get Timetable Data
- ✅ Get Homework Data
- ✅ Get Attendance Data
- ✅ Get Progress Data

## 11. Teacher Portal (3 endpoints)
- ✅ Get Teacher Classes
- ✅ Get Timetable Data
- ✅ Get Students by Class

## 12. Announcements (2 endpoints)
- ✅ Get Announcements
- ✅ Create Announcement (admin/teacher)

## 13. Gallery (4 endpoints)
- ✅ Get Gallery Folders
- ✅ Get Folder Images
- ✅ Create Folder (admin)
- ✅ Upload Image (admin)

## 14. Holidays (4 endpoints)
- ✅ Get Holidays (with recurring support)
- ✅ Create Holiday (admin)
- ✅ Update Holiday (admin)
- ✅ Delete Holiday (admin)

**Special Features:**
- Recurring holidays (automatically repeat annually)
- Multi-day holidays support
- Holiday images (max 10MB)
- Year-based filtering

## 15. Leave Requests (3 endpoints)
- ✅ Get Leave Requests
- ✅ Create Leave Request (parent)
- ✅ Update Leave Request Status (admin/teacher)

## 16. Complaints (2 endpoints)
- ✅ Get Complaints
- ✅ Create Complaint

## 17. Subjects (1 endpoint)
- ✅ Get All Subjects

## 18. Teachers (8 endpoints)
- ✅ Get All Teachers
- ✅ Get Teachers Basic
- ✅ Get Teachers Management (admin)
- ✅ Create Teacher (admin)
- ✅ Update Teacher (admin)
- ✅ Delete Teacher (admin)
- ✅ Get Parents

## 19. Certificate Requests (2 endpoints)
- ✅ Get Certificate Requests
- ✅ Update Certificate Request (admin)

## 20. Weekly Exams (4 endpoints)
- ✅ Get Weekly Exams Data
- ✅ Create Weekly Exam (admin/teacher)
- ✅ Update Weekly Exam (admin/teacher)
- ✅ Delete Weekly Exam (admin/teacher)

**Special Features:**
- Competitive exam support (JEE/NEET)
- Negative marking support
- Syllabus linking

## 21. Leads Management (6 endpoints)
- ✅ Get Leads (admin/authorized teachers)
- ✅ Create Lead
- ✅ Get Lead Details
- ✅ Add Call Log
- ✅ Update Lead Status
- ✅ Delete Lead

**Special Features:**
- Call log tracking
- Lead status management
- Source tracking

---

## Additional Endpoints Available (Not Yet in Flutter Collection)

### Fees Management (7 endpoints)
- Get Fees Management Data
- Get Class Students
- Create Bulk Fees
- Update Fee
- Delete Fees Batch
- Record Payment
- Get Payments

### Timetable Management (7 endpoints)
- Get Management Data
- Get Class Timetable
- Get Teacher Schedule
- Create Timetable Entry
- Update Timetable Entry
- Delete Timetable Entry
- Publish Class Timetable

### Syllabus Management (6 endpoints)
- Get Syllabus Data
- Create Syllabus Entry
- Create Bulk Syllabus
- Update Syllabus Entry
- Delete Syllabus Entry
- Assign/Remove Teacher

### Question Papers (6 endpoints)
- Get Question Papers
- Get Paper Questions
- Create Question Paper
- Delete Question Paper
- Add/Update/Delete Questions

### Exam Cycles (4 endpoints)
- Get Exam Cycles
- Create Exam Cycle
- Toggle Active Status
- Delete Exam Cycle

### Admin Settings (5 endpoints)
- Get/Update Payment Gateway
- Upload Receipt Logo
- Invite Admin
- Factory Reset
- Full Reset

---

## API Features

### Authentication
- Bearer token authentication
- Token never expires (only on logout)
- Role-based access control (admin, teacher, parent)

### File Uploads
- Profile photos: max 2MB (jpg, jpeg, png)
- Holiday images: max 10MB (jpg, jpeg, png, gif)
- Gallery images: max 10MB
- Multipart/form-data support

### Pagination
- Most list endpoints support pagination
- Query parameters: `page`, `per_page`
- Default: 20 items per page

### Filtering
- Date range filtering
- Status filtering
- Class/Student filtering
- Year-based filtering (holidays)

### Special Features
- Recurring holidays
- Push notifications (Web Push/FCM)
- Real-time messaging
- Bulk operations (fees, syllabus)
- Payment gateway integration
- Lead tracking with call logs

---

## Files Provided

1. **SmartEduConnect_API_Flutter.postman_collection.json**
   - Complete Postman collection with 21 sections
   - Auto-token management
   - Detailed field descriptions
   - Request/response examples

2. **API_DOCUMENTATION_FOR_FLUTTER.md**
   - Comprehensive Flutter developer guide
   - Authentication flow
   - Error handling examples
   - Network configuration
   - Dart code examples

3. **HOLIDAY_CALENDAR_API_GUIDE.md**
   - Detailed holiday calendar feature guide
   - Recurring holidays explanation
   - Multi-day holidays
   - Image upload examples
   - Complete Flutter implementation

4. **API_COMPLETE_LIST.md** (this file)
   - Complete endpoint listing
   - Feature overview
   - Quick reference

---

## How to Use

### 1. Import Postman Collection
```bash
# Open Postman
# File → Import → Select SmartEduConnect_API_Flutter.postman_collection.json
```

### 2. Set Base URL (if needed)
```
Collection Variables → base_url → https://smarteduconnect.in:8080/api
```

### 3. Login to Get Token
```
1. Go to "1. Authentication" → "Login"
2. Update email and password
3. Send request
4. Token is automatically saved
```

### 4. Test Endpoints
All subsequent requests will use the saved token automatically.

---

## Version Information
- **API Version:** 1.0.0
- **Last Updated:** March 25, 2026
- **Base URL:** https://smarteduconnect.in:8080/api
- **Backend:** Laravel 11
- **Database:** MySQL (AWS RDS)

---

## Support
For API issues or questions, contact the backend development team.
