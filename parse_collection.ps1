# Parse the complete collection from user input and create final collection
$userCollection = @'
USER_COLLECTION_JSON_HERE
'@ | ConvertFrom-Json

# Update base URL and metadata
$userCollection.variable[0].value = "https://smarteduconnect.in:8080/api"
$userCollection.info.name = "SmartEduConnect API - Complete Collection for Flutter"
$userCollection.info.description = "Complete API collection with ALL 180+ endpoints for SmartEduConnect Flutter mobile app development"

# Save
$userCollection | ConvertTo-Json -Depth 100 | Set-Content "SmartEduConnect_Complete_API.postman_collection.json"

Write-Output "✅ Complete collection created!"
