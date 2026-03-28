# Holiday Calendar API Guide for Flutter

## Overview
The Holiday Calendar feature allows schools to manage holidays with support for recurring annual holidays, multi-day holidays, and holiday images.

## Base Endpoint
```
https://smarteduconnect.in:8080/api/holidays
```

## Features
- ✅ Single-day and multi-day holidays
- ✅ Recurring holidays (automatically repeat every year)
- ✅ Holiday types: national, religious, school, optional
- ✅ Image upload support (max 10MB)
- ✅ Year-based filtering
- ✅ Admin-only management

## API Endpoints

### 1. Get Holidays
**GET** `/holidays?year=2026`

**Query Parameters:**
- `year` (optional): Year in YYYY format (defaults to current year)

**Response:**
```json
[
  {
    "id": 1,
    "name": "Independence Day",
    "start_date": "2026-08-15",
    "end_date": null,
    "type": "national",
    "description": "National Holiday",
    "image_url": "https://smarteduconnect.in:8080/storage/holidays/independence.jpg",
    "is_recurring": true,
    "created_by": 1,
    "created_at": "2026-03-01T10:00:00.000000Z",
    "updated_at": "2026-03-01T10:00:00.000000Z"
  },
  {
    "id": 2,
    "name": "Summer Vacation",
    "start_date": "2026-05-01",
    "end_date": "2026-06-15",
    "type": "school",
    "description": "Annual summer break",
    "image_url": null,
    "is_recurring": false,
    "created_by": 1,
    "created_at": "2026-03-01T10:00:00.000000Z",
    "updated_at": "2026-03-01T10:00:00.000000Z"
  }
]
```

**Note:** Recurring holidays are automatically projected to the requested year.

---

### 2. Create Holiday (Admin Only)
**POST** `/holidays`

**Content-Type:** `multipart/form-data`

**Form Fields:**
- `name` (required, string, max:255): Holiday name
- `start_date` (required, string, YYYY-MM-DD): Start date
- `end_date` (optional, string, YYYY-MM-DD): End date (for multi-day holidays)
- `type` (required, string): Holiday type - `national`, `religious`, `school`, or `optional`
- `description` (optional, string): Holiday description
- `is_recurring` (optional, boolean): Set to `true` for annual recurring holidays
- `image` (optional, file): Holiday image (max 10MB, jpg/jpeg/png/gif)

**Example Request (Dart/Flutter):**
```dart
import 'package:dio/dio.dart';

Future<void> createHoliday() async {
  final dio = Dio();
  
  // Single-day recurring holiday
  final formData = FormData.fromMap({
    'name': 'Independence Day',
    'start_date': '2026-08-15',
    'type': 'national',
    'description': 'National Holiday celebrating independence',
    'is_recurring': 'true',
  });
  
  // Add image if available
  if (imageFile != null) {
    formData.files.add(MapEntry(
      'image',
      await MultipartFile.fromFile(imageFile.path),
    ));
  }
  
  final response = await dio.post(
    'https://smarteduconnect.in:8080/api/holidays',
    data: formData,
    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );
  
  print('Holiday created: ${response.data}');
}
```

**Response:** Created holiday object (201 Created)

---

### 3. Update Holiday (Admin Only)
**PUT** `/holidays/:id`

**Content-Type:** `multipart/form-data`

**URL Parameters:**
- `id` (required): Holiday ID

**Form Fields:** Same as Create Holiday (all fields required)

**Note:** 
- If new image is uploaded, old image is automatically deleted
- Some HTTP clients may require using POST with `_method=PUT` for multipart uploads

**Example Request (Dart/Flutter):**
```dart
Future<void> updateHoliday(int holidayId) async {
  final dio = Dio();
  
  final formData = FormData.fromMap({
    'name': 'Independence Day - Updated',
    'start_date': '2026-08-15',
    'type': 'national',
    'description': 'Updated description',
    'is_recurring': 'true',
  });
  
  // For PUT with multipart, some clients need this workaround
  final response = await dio.post(
    'https://smarteduconnect.in:8080/api/holidays/$holidayId',
    data: formData,
    queryParameters: {'_method': 'PUT'},
    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );
  
  print('Holiday updated: ${response.data}');
}
```

**Response:** Updated holiday object (200 OK)

---

### 4. Delete Holiday (Admin Only)
**DELETE** `/holidays/:id`

**URL Parameters:**
- `id` (required): Holiday ID

**Example Request (Dart/Flutter):**
```dart
Future<void> deleteHoliday(int holidayId) async {
  final dio = Dio();
  
  final response = await dio.delete(
    'https://smarteduconnect.in:8080/api/holidays/$holidayId',
    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );
  
  print('Holiday deleted: ${response.data['message']}');
}
```

**Response:**
```json
{
  "message": "Deleted"
}
```

**Note:** Associated image is automatically deleted from storage.

---

## Holiday Types

| Type | Description | Example |
|------|-------------|---------|
| `national` | National holidays | Independence Day, Republic Day |
| `religious` | Religious festivals | Diwali, Christmas, Eid |
| `school` | School-specific holidays | Founder's Day, Annual Day |
| `optional` | Optional holidays | Regional festivals |

---

## Recurring Holidays

Recurring holidays automatically repeat every year. When you fetch holidays for a specific year, recurring holidays are projected to that year.

**Example:**
```dart
// Create a recurring holiday once
POST /holidays
{
  "name": "Independence Day",
  "start_date": "2026-08-15",
  "type": "national",
  "is_recurring": true
}

// Fetch for 2027 - automatically shows Aug 15, 2027
GET /holidays?year=2027

// Fetch for 2028 - automatically shows Aug 15, 2028
GET /holidays?year=2028
```

---

## Multi-Day Holidays

For holidays spanning multiple days (like vacations), provide both `start_date` and `end_date`.

**Example:**
```dart
// Summer vacation from May 1 to June 15
POST /holidays
{
  "name": "Summer Vacation",
  "start_date": "2026-05-01",
  "end_date": "2026-06-15",
  "type": "school",
  "is_recurring": false
}
```

---

## Image Upload

Holiday images can be uploaded during create or update operations.

**Requirements:**
- Max size: 10MB
- Formats: jpg, jpeg, png, gif
- Uploaded to: `/storage/holidays/`

**Example with Image:**
```dart
Future<void> createHolidayWithImage(File imageFile) async {
  final dio = Dio();
  
  final formData = FormData.fromMap({
    'name': 'Sports Day',
    'start_date': '2026-04-15',
    'type': 'school',
    'description': 'Annual sports day celebration',
    'image': await MultipartFile.fromFile(
      imageFile.path,
      filename: 'sports-day.jpg',
    ),
  });
  
  final response = await dio.post(
    'https://smarteduconnect.in:8080/api/holidays',
    data: formData,
    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );
}
```

---

## Error Handling

### 403 Forbidden
Non-admin users attempting to create/update/delete holidays.

```json
{
  "message": "Forbidden"
}
```

### 404 Not Found
Holiday ID doesn't exist.

```json
{
  "message": "Not Found"
}
```

### 422 Validation Error
Invalid data or image upload failure.

```json
{
  "message": "Image upload failed. Check storage permissions.",
  "errors": {
    "start_date": ["The start date field is required."]
  }
}
```

---

## Flutter Implementation Example

### Complete Holiday Calendar Screen

```dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class HolidayCalendarScreen extends StatefulWidget {
  @override
  _HolidayCalendarScreenState createState() => _HolidayCalendarScreenState();
}

class _HolidayCalendarScreenState extends State<HolidayCalendarScreen> {
  final dio = Dio();
  List<Holiday> holidays = [];
  int selectedYear = DateTime.now().year;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    fetchHolidays();
  }
  
  Future<void> fetchHolidays() async {
    setState(() => isLoading = true);
    
    try {
      final response = await dio.get(
        'https://smarteduconnect.in:8080/api/holidays',
        queryParameters: {'year': selectedYear},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      setState(() {
        holidays = (response.data as List)
            .map((json) => Holiday.fromJson(json))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading holidays: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Holiday Calendar'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectYear(),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: holidays.length,
              itemBuilder: (context, index) {
                final holiday = holidays[index];
                return HolidayCard(holiday: holiday);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateHolidayDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class Holiday {
  final dynamic id;
  final String name;
  final String startDate;
  final String? endDate;
  final String type;
  final String? description;
  final String? imageUrl;
  final bool isRecurring;
  
  Holiday({
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    required this.type,
    this.description,
    this.imageUrl,
    required this.isRecurring,
  });
  
  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'],
      name: json['name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      type: json['type'],
      description: json['description'],
      imageUrl: json['image_url'],
      isRecurring: json['is_recurring'] ?? false,
    );
  }
}
```

---

## Testing with Postman

1. Import `SmartEduConnect_API_Flutter.postman_collection.json`
2. Login to get token (automatically saved)
3. Navigate to "14. Holidays" section
4. Test all endpoints:
   - Get Holidays
   - Create Holiday
   - Update Holiday
   - Delete Holiday

---

## Version
Last Updated: March 25, 2026
API Version: 1.0.0
