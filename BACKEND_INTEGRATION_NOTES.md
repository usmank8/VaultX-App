# Backend Integration Notes - .NET API

## Changes Made to Flutter App

### 1. Login API Update (`api_service.dart`)
**Changed:** Updated to handle new .NET backend response structure
- **Old response:** `{ "token": "..." }`
- **New response:** `{ "message": "Login successful.", "accessToken": "..." }`

**What was updated:**
- Now checks for `accessToken` field (your new .NET backend)
- Falls back to `token` field for backward compatibility
- Added comprehensive debug logging

### 2. Profile API Response Handling
**Your .NET backend returns:**
```json
{
  "firstname": "string",
  "lastname": "string",
  "phone": "string",
  "cnic": "string",
  "email": "string",
  "residence": {
    "addressLine1": "string",
    "block": "string",
    "residence": "string",
    "residenceType": "string"
  }
}
```

**The Flutter model (`CreateProfileModel`) already handles this structure correctly:**
- Maps `phone` → `phonenumber`
- Maps nested `residence.addressLine1` → `address`
- Maps nested residence fields correctly

### 3. Android Emulator Network Configuration
**Issue:** Android emulator cannot reach `localhost:5280`

**Solution:** Changed base URL for Android to use `10.0.2.2`
```dart
String get _baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:5280/api';  // Special IP for emulator
  } else {
    return 'https://vaultx-be-sq00.onrender.com';  // Production
  }
}
```

### 4. Enhanced Error Handling
Added better error handling in:
- `api_service.dart` - Shows actual backend error messages
- `loginscreen.dart` - Handles 500 errors specifically and shows meaningful messages

---

## ⚠️ 500 Error - What to Check on Your .NET Backend

The 500 error with "invalid column name" suggests a **backend/database issue**, not a Flutter issue. Here's what to check:

### 1. Database Schema Check
Make sure your database has the correct table structure:

**User/Profile Table should have:**
- `firstname` (not `firstName` or `FirstName`)
- `lastname` (not `lastName` or `LastName`)
- `phone` (not `phoneNumber` or `PhoneNumber`)
- `cnic`
- `email`

**Residence Table/Fields should have:**
- `addressLine1` (not `address` or `Address`)
- `block`
- `residence`
- `residenceType`

### 2. Check Your Entity Models
Verify that your .NET Entity models use the correct column names:

```csharp
// Example - Your entity should look like this:
public class UserProfile
{
    public string Firstname { get; set; }  // Maps to "firstname" in DB
    public string Lastname { get; set; }   // Maps to "lastname" in DB
    public string Phone { get; set; }      // Maps to "phone" in DB
    public string Cnic { get; set; }
    public string Email { get; set; }
    public Residence Residence { get; set; }
}

public class Residence
{
    public string AddressLine1 { get; set; }  // Maps to "addressLine1"
    public string Block { get; set; }
    public string Residence { get; set; }
    public string ResidenceType { get; set; }
}
```

### 3. Check Column Mapping in EF Core
If using Entity Framework Core, verify your `DbContext` configuration:

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<UserProfile>()
        .Property(u => u.Firstname)
        .HasColumnName("firstname");  // Ensure correct column name
    
    // ... similar for other properties
}
```

### 4. JWT Token Configuration
Verify your .NET API validates JWT tokens correctly:

```csharp
[Authorize]  // Ensure this attribute is present
[HttpGet("Profile/me")]
public async Task<IActionResult> GetProfile()
{
    // Get user ID from JWT token claims
    var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    
    if (string.IsNullOrEmpty(userId))
    {
        return Unauthorized();
    }
    
    // Fetch profile...
}
```

### 5. CORS Configuration
Ensure your .NET API allows requests from the Flutter app:

```csharp
// In Program.cs or Startup.cs
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});

// ...

app.UseCors("AllowAll");
```

---

## Testing Steps

### 1. Test Backend Directly with Swagger
1. Go to `http://localhost:5280/swagger`
2. Call `POST /api/Auth/login` with your test credentials
3. Copy the `accessToken` from the response
4. Click "Authorize" button in Swagger and enter: `Bearer {your-token}`
5. Call `GET /api/Profile/me` 
6. Check if it returns 200 OK or 500 error

**If Swagger also returns 500 error:** The issue is in your .NET backend code/database, not Flutter.

### 2. Check .NET Backend Logs
Look at your .NET console output for the actual error message. It will tell you exactly which column is missing.

### 3. Test Flutter App
1. Make sure .NET backend is running on `localhost:5280`
2. Hot restart (not hot reload) your Flutter app
3. Try to login with: `shehryar123@yopmail.com` / `123456`
4. Check the Flutter debug console for detailed logs

---

## API Endpoints Being Called

After login, Flutter calls these endpoints in sequence:

1. **POST** `/api/Auth/login` - Login and get access token ✅ Working
2. **GET** `/api/Profile/me` - Fetch user profile ❌ Currently returning 500

---

## Debug Logging Added

The following debug logs are now printed:

### Login Request:
```
Sending login request to: http://10.0.2.2:5280/api/Auth/login
Request body: {"email":"...","password":"..."}
Login response status: 200
Login response body: {"message":"...","accessToken":"..."}
Login successful, token saved
```

### Profile Request:
```
Fetching profile from: http://10.0.2.2:5280/api/Profile/me
Token being used: eyJhbGciOiJIUzI1NiI...
Get profile response status: 500
Get profile response body: {...error details...}
```

Check your Flutter console for these logs to diagnose the exact issue.

---

## Quick Fix Checklist

- [ ] .NET backend is running on `localhost:5280`
- [ ] Test login endpoint in Swagger - should return `accessToken`
- [ ] Test Profile/me endpoint in Swagger with Bearer token
- [ ] Check database has correct column names (lowercase)
- [ ] Check Entity models match database schema
- [ ] Check JWT token is being validated correctly
- [ ] Check CORS is configured to allow requests
- [ ] Verify user exists in database and has required fields

---

## Contact Points

**Flutter App:**
- Base URL: `http://10.0.2.2:5280/api` (Android emulator)
- Token stored in: SharedPreferences with key `jwt_token`
- Token format: `Bearer {accessToken}`

**Expected .NET Endpoints:**
- `POST /api/Auth/login` → Returns `{ "accessToken": "..." }`
- `GET /api/Profile/me` → Returns profile with nested residence object

---

## Next Steps

1. **Fix the 500 error on your .NET backend first** - Test in Swagger
2. Once Profile/me returns 200 OK in Swagger, test the Flutter app
3. Check Flutter debug console for any JSON parsing errors
4. If needed, share the actual 500 error message from .NET logs for further debugging

