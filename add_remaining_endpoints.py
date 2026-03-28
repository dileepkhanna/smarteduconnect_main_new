#!/usr/bin/env python3
import json

with open('SmartEduConnect_API_Flutter.postman_collection.json', 'r', encoding='utf-8') as f:
    collection = json.load(f)

def count_endpoints(items):
    count = 0
    for item in items:
        if 'request' in item:
            count += 1
        if 'item' in item:
            count += count_endpoints(item['item'])
    return count

current_count = count_endpoints(collection['item'])
print(f"Current endpoints: {current_count}")

# Find sections by name and add missing endpoints
def find_section(name):
    for section in collection['item']:
        if section['name'].endswith(name):
            return section
    return None

# Add missing endpoints to existing sections
updates = {
    "Notifications": [
        ("GET", "/notifications/stream", "Notification Stream"),
    ],
    "Subjects": [
        ("POST", "/subjects", "Create Subject"),
        ("PUT", "/subjects/{id}", "Update Subject"),
        ("DELETE", "/subjects/{id}", "Delete Subject"),
    ],
    "Announcements": [
        ("DELETE", "/announcements/{id}", "Delete Announcement"),
    ],
    "Gallery": [
        ("POST", "/gallery/folders", "Create Folder"),
        ("PUT", "/gallery/folders/{id}", "Update Folder"),
        ("DELETE", "/gallery/folders/{id}", "Delete Folder"),
        ("POST", "/gallery/folders/{id}/images", "Upload Image"),
        ("PUT", "/gallery/images/{id}", "Update Image"),
        ("DELETE", "/gallery/images/{id}", "Delete Image"),
    ],
    "Complaints": [
        ("PUT", "/complaints/{id}", "Update Complaint"),
    ],
    "Exams": [
        ("POST", "/exams/bulk", "Create Exams Bulk"),
        ("DELETE", "/exams/{id}", "Delete Exam"),
        ("GET", "/exams/{id}/marks-data", "Get Exam Marks Data"),
        ("PUT", "/exams/{id}/marks", "Save Exam Marks"),
        ("GET", "/exams/results-data", "Get Exam Results Data"),
    ],
    "Weekly Exams": [
        ("GET", "/weekly-exams/{id}/marks-data", "Get Weekly Exam Marks Data"),
        ("PUT", "/weekly-exams/{id}/marks", "Save Weekly Exam Marks"),
        ("PUT", "/weekly-exams/{id}/status", "Update Weekly Exam Status"),
        ("PUT", "/weekly-exams/{id}/syllabus-links", "Save Syllabus Links"),
    ],
    "Leads Management": [
        ("POST", "/leads/import", "Import Leads"),
        ("GET", "/leads/module-status", "Get Module Status"),
        ("GET", "/leads/settings", "Get Leads Settings"),
        ("PUT", "/leads/settings/module", "Update Module"),
        ("PUT", "/leads/settings/mode", "Update Mode"),
        ("PUT", "/leads/settings/teacher/{teacherId}", "Update Teacher Permission"),
        ("PUT", "/leads/{id}", "Update Lead"),
    ],
}

for section_name, endpoints in updates.items():
    section = find_section(section_name)
    if section:
        for method, path, name in endpoints:
            endpoint = {
                "name": name,
                "request": {
                    "auth": {
                        "type": "bearer",
                        "bearer": [{"key": "token", "value": "{{token}}", "type": "string"}]
                    },
                    "method": method,
                    "header": [],
                    "url": {
                        "raw": f"{{{{base_url}}}}{path}",
                        "host": ["{{base_url}}"],
                        "path": path.strip('/').split('/')
                    },
                    "description": f"**Purpose:** {name}\n\n**Auth Required:** Yes (Bearer Token)"
                },
                "response": []
            }
            
            if method in ["POST", "PUT"]:
                endpoint["request"]["header"].append({
                    "key": "Content-Type",
                    "value": "application/json"
                })
                endpoint["request"]["body"] = {
                    "mode": "raw",
                    "raw": "{}"
                }
            
            section["item"].append(endpoint)

# Add new comprehensive sections
new_sections = {
    "28. Messaging Extended": [
        ("GET", "/messaging/classes", "Get Classes"),
        ("GET", "/messaging/teachers", "Get Teachers"),
        ("GET", "/messaging/admin-user", "Get Admin User"),
        ("GET", "/messaging/students/class/{classId}", "Get Students by Class"),
        ("GET", "/messaging/contacts", "Get Contacts"),
        ("PUT", "/messaging/messages/{id}/read", "Mark Message as Read"),
    ],
    "29. Teacher Portal Extended": [
        ("GET", "/teacher/dashboard", "Get Teacher Dashboard"),
        ("GET", "/teacher/attendance-data", "Get Attendance Data"),
        ("PUT", "/teacher/attendance", "Save Attendance"),
        ("GET", "/teacher/students-data", "Get Students Data"),
        ("POST", "/teacher/students", "Create Student"),
        ("PUT", "/teacher/students/{id}", "Update Student"),
        ("POST", "/teacher/leave-requests", "Create Leave Request"),
        ("POST", "/teacher/homework", "Create Homework"),
        ("DELETE", "/teacher/homework/{id}", "Delete Homework"),
        ("GET", "/teacher/weekly-exams-data", "Get Weekly Exams Data"),
        ("GET", "/teacher/reports-data", "Get Reports Data"),
        ("GET", "/teacher/class-students", "Get Class Students"),
        ("POST", "/teacher/reports", "Create Report"),
        ("PUT", "/teacher/complaints/{id}", "Update Complaint"),
        ("PUT", "/teacher/syllabus/{id}/complete", "Mark Syllabus Complete"),
        ("GET", "/teacher/exams-data", "Get Exams Data"),
    ],
    "30. Parent Portal Extended": [
        ("GET", "/parent/dashboard", "Get Parent Dashboard"),
        ("GET", "/parent/exams-data", "Get Exams Data"),
        ("GET", "/parent/certificate-requests", "Get Certificate Requests"),
        ("POST", "/parent/certificate-requests", "Create Certificate Request"),
        ("GET", "/parent/leave-requests", "Get Leave Requests"),
        ("POST", "/parent/leave-requests", "Create Leave Request"),
        ("GET", "/parent/attendance-data", "Get Attendance Data"),
        ("GET", "/parent/fees/payment-gateway-config", "Get Payment Gateway Config"),
        ("POST", "/parent/fees/{id}/create-order", "Create Fee Payment Order"),
        ("POST", "/parent/fees/{id}/verify-payment", "Verify Fee Payment"),
        ("POST", "/parent/fees/{id}/pay", "Pay Fee"),
        ("GET", "/parent/children-data", "Get Children Data"),
        ("POST", "/parent/complaints", "Create Complaint"),
        ("GET", "/parent/progress-data", "Get Progress Data"),
    ],
}

for section_name, endpoints in new_sections.items():
    new_section = {
        "name": section_name,
        "description": f"{section_name.split('. ')[1]} endpoints",
        "item": []
    }
    
    for method, path, name in endpoints:
        endpoint = {
            "name": name,
            "request": {
                "auth": {
                    "type": "bearer",
                    "bearer": [{"key": "token", "value": "{{token}}", "type": "string"}]
                },
                "method": method,
                "header": [],
                "url": {
                    "raw": f"{{{{base_url}}}}{path}",
                    "host": ["{{base_url}}"],
                    "path": path.strip('/').split('/')
                },
                "description": f"**Purpose:** {name}\n\n**Auth Required:** Yes (Bearer Token)"
            },
            "response": []
        }
        
        if method in ["POST", "PUT"]:
            endpoint["request"]["header"].append({
                "key": "Content-Type",
                "value": "application/json"
            })
            endpoint["request"]["body"] = {
                "mode": "raw",
                "raw": "{}"
            }
        
        new_section["item"].append(endpoint)
    
    collection["item"].append(new_section)

with open('SmartEduConnect_API_Flutter.postman_collection.json', 'w', encoding='utf-8') as f:
    json.dump(collection, f, indent=2, ensure_ascii=False)

new_count = count_endpoints(collection['item'])
print(f"✅ Collection updated!")
print(f"Total sections: {len(collection['item'])}")
print(f"Total endpoints: {new_count}")
print(f"Added: {new_count - current_count} endpoints")
