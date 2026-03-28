# SmartEduConnect API Documentation for Flutter Developer

## Overview
This document provides comprehensive API documentation for developing the SmartEduConnect Flutter mobile application.

## Base URL
```
https://smarteduconnect.in:8080/api
```

## Authentication
All authenticated endpoints require a Bearer token in the Authorization header.

### Getting Started
1. Import the Postman collection: `SmartEduConnect_API_Flutter.postman_collection.json`
2. The collection automatically saves the token after login
3. All subsequent requests use the saved token

### Authentication Flow
```dart
// 1. Login
POST /auth/login
Body: {
  "email": "user@example.com",
  "password": "password123"
}

// Response includes token
{
  "token": "a1b2c3d4...",
  "user": { ... }
}

// 2. Store token locally (SharedPreferences/Secure Storage)
// 3. Add token to all API requests
headers: {
  "Authorization": "Bearer YOUR_TOKEN_HERE"
}

// 4. Get current user details
GET /auth/me

// 5. Logout (invalidates token)
POST /auth/logout
```

## API Sections

### 1. Authentication
- Check if admin exists
- Login/Register
- Get current user
- Logout
- Resolve teacher/parent email (for password reset)

### 2. Dashboard
- Get dashboard statistics (role-specific)

### 3. Classes
- Get all classes
- Create class (admin only)

### 4. Students
- Get all students
- Get student by ID
- Get student attendance summary
- Get student exam marks

### 5. Attendance
- Get attendance report
- Mark attendance (teacher/admin)

### 6. Exams
- Get exams data
- Get exam cycles

### 7. Notifications
- Get notifications (paginated)
- Get unread count
- Mark as read
- Push notification subscription

### 8. Messages
- Get conversations
- Get messages with user
- Send message
- Mark messages as read

### 9. Profile
- Get profile
- Update profile
- Upload profile photo
- Change password

### 10. Parent Portal
- Get children list
- Get fees data
- Get timetable
- Get homework
- Get attendance data

### 11. Teacher Portal
- Get assigned classes
- Get timetable
- Get students by class

### 12. Announcements
- Get announcements
- Create announcement (admin/teacher)

### 13. Gallery
- Get gallery folders
- Get folder images

### 14. Holidays (Holiday Calendar)
- Get holidays (with recurring support)
- Create holiday (admin)
- Update holiday (admin)
- Delete holiday (admin)

### 15. Leave Requests
- Get leave requests
- Create leave request (parent)
- Update status (admin/teacher)

### 16. Complaints
- Get complaints
- Create complaint

### 17. Subjects
- Get all subjects

### 18. Teachers
- Get all teachers

## User Roles
The API supports three user roles:
- `admin`: Full system access
- `teacher`: Class and student management
- `parent`: View children's data

## Common Response Patterns

### Success Response
```json
{
  "data": [...],
  "message": "Success"
}
```

### Error Response
```json
{
  "message": "Error description",
  "errors": {
    "field": ["Validation error message"]
  }
}
```

### Paginated Response
```json
{
  "data": [...],
  "current_page": 1,
  "total": 100,
  "per_page": 20,
  "last_page": 5
}
```

## Important Notes for Flutter Development

### 1. Token Management
- Store token securely using `flutter_secure_storage`
- Token never expires automatically (only on logout)
- Include token in all authenticated requests

### 7. Image Uploads
- Use `multipart/form-data` for file uploads
- Profile photos: max 2MB, formats: jpg, jpeg, png
- Holiday images: max 10MB, formats: jpg, jpeg, png, gif
- Use `http.MultipartRequest` or `dio` package
- For PUT requests with files, some clients may need to use POST with `_method=PUT` parameter

### 3. Date Formats
- All dates use ISO 8601 format: `YYYY-MM-DD`
- Timestamps: `YYYY-MM-DDTHH:MM:SS.000000Z`

### 4. Pagination
- Most list endpoints support pagination
- Query parameters: `page` (default: 1), `per_page` (default: 20)

### 5. Push Notifications
- Current implementation uses Web Push (VAPID)
- For Flutter, recommend implementing FCM (Firebase Cloud Messaging)
- May need backend endpoint modification for FCM token registration

### 6. Holiday Calendar Features
- Supports both single-day and multi-day holidays
- Recurring holidays: Set `is_recurring: true` to automatically repeat annually
- Holiday types: national, religious, school, optional
- Image support: Upload holiday images (max 10MB)
- Year-based filtering: Get holidays for specific year
- Automatic projection: Recurring holidays are automatically projected to requested year

**Example: Creating a recurring holiday**
```dart
// Independence Day - recurs every year
final formData = FormData.fromMap({
  'name': 'Independence Day',
  'start_date': '2026-08-15',
  'type': 'national',
  'is_recurring': 'true',
  'description': 'National Holiday',
});

// Multi-day holiday (vacation)
final formData2 = FormData.fromMap({
  'name': 'Summer Vacation',
  'start_date': '2026-05-01',
  'end_date': '2026-06-15',
  'type': 'school',
  'is_recurring': 'false',
});
```

### 6. Error Handling
```dart
try {
  final response = await http.get(url, headers: headers);
  
  if (response.statusCode == 200) {
    // Success
    return jsonDecode(response.body);
  } else if (response.statusCode == 401) {
    // Unauthorized - clear token and redirect to login
    await clearToken();
    navigateToLogin();
  } else if (response.statusCode == 422) {
    // Validation error
    final errors = jsonDecode(response.body)['errors'];
    showValidationErrors(errors);
  } else {
    // Other errors
    showError(jsonDecode(response.body)['message']);
  }
} catch (e) {
  // Network error
  showError('Network error. Please check your connection.');
}
```

### 7. Network Configuration
```dart
// Recommended HTTP client setup
final dio = Dio(BaseOptions(
  baseUrl: 'https://smarteduconnect.in:8080/api',
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
));

// Add interceptor for token
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await getStoredToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
  onError: (error, handler) async {
    if (error.response?.statusCode == 401) {
      // Handle unauthorized
      await clearToken();
      navigateToLogin();
    }
    return handler.next(error);
  },
));
```

## Testing the API

### Using Postman
1. Import the collection file
2. Set the `base_url` variable if needed
3. Login using the "Login" request
4. Token is automatically saved
5. Test other endpoints

### Test Credentials
Contact the backend administrator for test credentials.

## Support
For API issues or questions, contact the backend development team.

## Version
API Version: 1.0.0
Last Updated: March 25, 2026
