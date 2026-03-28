#!/usr/bin/env python3
"""
Script to add all missing endpoints to the Postman collection
"""
import json

# Load current collection
with open('SmartEduConnect_API_Flutter.postman_collection.json', 'r', encoding='utf-8') as f:
    collection = json.load(f)

print(f"Current collection has {len(collection['item'])} sections")

# Count current endpoints
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

# All missing endpoints to add
missing_sections = {
    "22. Fees Management": [
        ("GET", "/fees/management-data", "Get Fees Management Data"),
        ("POST", "/fees/class-students", "Get Class Students"),
        ("POST", "/fees/bulk-create", "Create Bulk Fees"),
        ("PUT", "/fees/{id}", "Update Fee"),
        ("POST", "/fees/delete-batch", "Delete Fees Batch"),
        ("POST", "/fees/{id}/record-payment", "Record Payment"),
        ("POST", "/fees/payments", "Get Payments"),
        ("GET", "/settings/receipt-template", "Get Receipt Template"),
        ("PUT", "/settings/receipt-template", "Save Receipt Template"),
        ("POST", "/settings/receipt-template/logo", "Upload Receipt Logo"),
    ],
    "23. Timetable Management": [
        ("GET", "/admin/timetable/management-data", "Get Management Data"),
        ("GET", "/admin/timetable/class/{classId}", "Get Class Timetable"),
        ("GET", "/admin/timetable/teacher/{teacherId}", "Get Teacher Schedule"),
        ("POST", "/admin/timetable", "Create Timetable Entry"),
        ("PUT", "/admin/timetable/{id}", "Update Timetable Entry"),
        ("DELETE", "/admin/timetable/{id}", "Delete Timetable Entry"),
        ("PUT", "/admin/timetable/publish-class", "Publish Class Timetable"),
        ("PUT", "/admin/timetable/{id}/publish", "Toggle Publish"),
    ],
    "24. Syllabus Management": [
        ("GET", "/admin/syllabus/data", "Get Syllabus Data"),
        ("POST", "/admin/syllabus", "Create Syllabus Entry"),
        ("POST", "/admin/syllabus/bulk", "Create Bulk Syllabus"),
        ("PUT", "/admin/syllabus/{id}", "Update Syllabus Entry"),
        ("DELETE", "/admin/syllabus/{id}", "Delete Syllabus Entry"),
        ("POST", "/admin/syllabus/{id}/teachers", "Assign Teacher"),
        ("DELETE", "/admin/syllabus/teachers/{id}", "Remove Teacher"),
    ],
    "25. Question Papers": [
        ("GET", "/admin/question-papers/data", "Get Question Papers"),
        ("GET", "/admin/question-papers/{id}/questions", "Get Paper Questions"),
        ("POST", "/admin/question-papers", "Create Question Paper"),
        ("DELETE", "/admin/question-papers/{id}", "Delete Question Paper"),
        ("POST", "/admin/question-papers/{id}/questions", "Add Question"),
        ("PUT", "/admin/questions/{id}", "Update Question"),
        ("DELETE", "/admin/questions/{id}", "Delete Question"),
    ],
    "26. Exam Cycles": [
        ("GET", "/admin/exam-cycles", "Get Exam Cycles"),
        ("POST", "/admin/exam-cycles", "Create Exam Cycle"),
        ("PUT", "/admin/exam-cycles/{id}/toggle-active", "Toggle Active Status"),
        ("DELETE", "/admin/exam-cycles/{id}", "Delete Exam Cycle"),
    ],
    "27. Admin Settings": [
        ("GET", "/settings/payment-gateway", "Get Payment Gateway"),
        ("PUT", "/settings/payment-gateway", "Update Payment Gateway"),
        ("POST", "/settings/invite-admin", "Invite Admin"),
        ("POST", "/settings/factory-reset", "Factory Reset"),
        ("POST", "/settings/full-reset", "Full Reset"),
    ],
}

# Create new sections
for section_name, endpoints in missing_sections.items():
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
        
        # Add body for POST/PUT
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

# Save updated collection
with open('SmartEduConnect_API_Flutter.postman_collection.json', 'w', encoding='utf-8') as f:
    json.dump(collection, f, indent=2, ensure_ascii=False)

new_count = count_endpoints(collection['item'])
print(f"\n✅ Collection updated!")
print(f"New sections: {len(collection['item'])}")
print(f"New endpoints: {new_count}")
print(f"Added: {new_count - current_count} endpoints")
