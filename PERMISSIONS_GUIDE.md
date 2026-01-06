# Permission Handling Guide

This guide explains how the app handles permissions for camera, location, contacts, and other sensitive features.

## Overview

The app uses **`permission_handler`** package with a custom `PermissionService` to provide:
- User-friendly permission dialogs
- Automatic permission requests before accessing features
- Graceful handling of denied permissions
- Deep links to app settings for permanently denied permissions

## Architecture

### PermissionService

Located at [lib/core/permission_service.dart](lib/core/permission_service.dart)

Provides methods for:
- ✅ Requesting individual permissions
- ✅ Checking permission status
- ✅ Showing user-friendly dialogs
- ✅ Opening app settings
- ✅ Batch permission requests

## Supported Permissions

| Permission | Used By | Description |
|------------|---------|-------------|
| **Camera** | Image Picker, QR Scanner | Take photos and scan QR codes |
| **Photos** | Image Picker | Access photo gallery |
| **Location** | Maps | Show current location on map |
| **Contacts** | Future features | Access contact list |
| **Microphone** | Future features | Record audio |
| **Storage** | File uploads | Read/write files (Android) |
| **Notifications** | Future features | Send push notifications |

## How It Works

### 1. Automatic Permission Requests

When a user tries to use a feature requiring permissions, the app automatically:

1. **Checks** if permission is already granted
2. **Requests** permission if needed
3. **Shows explanation** dialog before requesting
4. **Handles denial** gracefully
5. **Opens settings** if permanently denied

### Example Flow (Camera)

```
User taps "Take Photo"
  ↓
Check camera permission
  ↓
Permission not granted → Show explanation dialog
  ↓
User taps "Allow" → Request system permission
  ↓
System shows permission dialog
  ↓
User grants permission → Open camera
```

### 2. User-Friendly Dialogs

Before requesting permissions, users see a dialog explaining why:

```dart
await PermissionService.requestPermissionWithDialog(
  context: context,
  permission: Permission.camera,
  title: 'Camera Permission',
  message: 'This app needs camera access to take photos.',
);
```

**Dialog includes:**
- Clear title
- Explanation of why permission is needed
- "Cancel" and "Allow" buttons

### 3. Permanently Denied Handling

If user permanently denies permission:
- Shows dialog explaining the situation
- Provides "Open Settings" button
- Takes user directly to app settings

## Widget-Specific Implementation

### Image Picker Widget

**Permissions Required:** Camera (for photos), Photos (for gallery)

**Implementation:**
- Checks permission before opening camera/gallery
- Shows appropriate dialog based on source (camera vs gallery)
- Handles denial gracefully with snackbar message

```dart
// Automatically handles permissions
{
  "type": "image_picker",
  "mode": "both"
}
```

### QR Scanner Widget

**Permissions Required:** Camera

**Implementation:**
- Requests camera permission when "Start Scanning" is tapped
- Shows clear explanation about QR code scanning
- Displays error message if permission denied

```dart
// Automatically handles permissions
{
  "type": "qr_scanner",
  "mode": "scan"
}
```

### Map Widget

**Permissions Required:** Location (optional, only if `show_current_location: true`)

**Implementation:**
- Only requests location if needed
- Works without location permission (just shows map at specified coordinates)
- Silently handles denial (doesn't block map display)

```dart
// Requests location only if needed
{
  "type": "map",
  "show_current_location": true
}
```

### Video Player Widget

**Permissions Required:** None

Videos stream from URLs without requiring permissions.

### PDF Viewer Widget

**Permissions Required:** None

PDFs load from URLs without requiring permissions.

### WebView Widget

**Permissions Required:** None (unless embedded content requests them)

Web content loads normally. If embedded website requests camera/mic, system handles it.

## Platform-Specific Configuration

### Android

**File:** `android/app/src/main/AndroidManifest.xml`

Required permissions are already declared:

```xml
<!-- Camera -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Photos -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Location -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Contacts (if needed) -->
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.WRITE_CONTACTS" />

<!-- Internet (for API calls) -->
<uses-permission android:name="android.permission.INTERNET" />
```

**Android 13+ (API 33+) Changes:**
- `READ_MEDIA_IMAGES` replaces `READ_EXTERNAL_STORAGE` for photos
- `READ_MEDIA_VIDEO` for videos
- More granular permissions

### iOS

**File:** `ios/Runner/Info.plist`

Required usage descriptions:

```xml
<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos and scan QR codes.</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to select images.</string>

<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to show it on the map.</string>

<!-- Location Always (if needed for background) -->
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs your location even when not in use.</string>

<!-- Contacts (if needed) -->
<key>NSContactsUsageDescription</key>
<string>This app needs access to your contacts.</string>

<!-- Microphone (if needed) -->
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record audio.</string>
```

**Important:** iOS requires these descriptions in Info.plist or app will crash when requesting permission.

## Programmatic Usage

### Basic Permission Request

```dart
// Simple request
final granted = await PermissionService.requestCamera();
if (granted) {
  // Use camera
}
```

### Request with Dialog

```dart
// User-friendly request with explanation
final granted = await PermissionService.requestPermissionWithDialog(
  context: context,
  permission: Permission.camera,
  title: 'Camera Access',
  message: 'We need camera access to take your profile photo.',
);
```

### Check Permission Status

```dart
// Check without requesting
final hasCamera = await PermissionService.hasCameraPermission();
final hasLocation = await PermissionService.hasLocationPermission();
```

### Request Multiple Permissions

```dart
// Request multiple at once
final results = await PermissionService.requestMultiple([
  Permission.camera,
  Permission.photos,
]);

// Check all are granted
final allGranted = await PermissionService.checkMultiple([
  Permission.camera,
  Permission.photos,
]);
```

## Custom Permissions (Future Features)

### Adding New Permission Types

1. **Add to PermissionService:**

```dart
static Future<bool> requestSMS() async {
  final status = await Permission.sms.request();
  return status.isGranted;
}
```

2. **Add platform declarations:**
   - Android: Add to AndroidManifest.xml
   - iOS: Add usage description to Info.plist

3. **Use in widgets:**

```dart
final granted = await PermissionService.requestPermissionWithDialog(
  context: context,
  permission: Permission.sms,
  title: 'SMS Permission',
  message: 'Send verification codes via SMS.',
);
```

## Best Practices

### ✅ DO

1. **Request permissions just-in-time** (when feature is used)
2. **Explain why** permission is needed
3. **Handle denial gracefully** (show helpful message)
4. **Provide alternative** if permission denied
5. **Test on real devices** (emulators may not accurately simulate permissions)

### ❌ DON'T

1. **Request all permissions at startup** (overwhelming for users)
2. **Request without explanation** (users will likely deny)
3. **Block app functionality** completely if permission denied
4. **Request repeatedly** if user denies (respect their choice)
5. **Crash if permission denied** (always handle errors)

## Testing Permissions

### During Development

1. **Grant permission:**
   - Use feature normally
   - Verify it works

2. **Deny permission:**
   - Test that app handles denial gracefully
   - Verify error messages are clear

3. **Permanently deny:**
   - Deny twice on Android or select "Don't Allow" on iOS
   - Verify "Open Settings" dialog appears
   - Test deep link to settings works

4. **Revoke permission:**
   - Go to device Settings → Apps → Your App → Permissions
   - Revoke permission
   - Test that app re-requests when feature is used

### Commands

```bash
# Android - Revoke permission via ADB
adb shell pm revoke com.example.dynamic_app android.permission.CAMERA
adb shell pm revoke com.example.dynamic_app android.permission.ACCESS_FINE_LOCATION

# Android - Grant permission via ADB
adb shell pm grant com.example.dynamic_app android.permission.CAMERA
adb shell pm grant com.example.dynamic_app android.permission.ACCESS_FINE_LOCATION

# Android - Reset all permissions
adb shell pm reset-permissions
```

## Troubleshooting

### Permission Always Denied

**Problem:** Permission request always returns denied

**Solutions:**
1. Check platform-specific configuration (AndroidManifest.xml / Info.plist)
2. Verify usage description strings are present (iOS)
3. Test on real device (not emulator)
4. Check if permission was permanently denied (reset app data)

### iOS App Crashes on Permission Request

**Problem:** App crashes when requesting permission on iOS

**Solution:** Add usage description to Info.plist. iOS requires explanation for all permissions.

### Android 13+ Photo Picker Not Working

**Problem:** Can't select photos on Android 13+

**Solution:** Add `READ_MEDIA_IMAGES` permission to AndroidManifest.xml

### Location Always Returns Null

**Problem:** Location is null even after permission granted

**Solutions:**
1. Check location services are enabled on device
2. Verify both `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION` in manifest
3. Test outdoors (GPS works better outside)
4. Check for Geolocator errors in console

### Permission Dialog Not Showing

**Problem:** System permission dialog doesn't appear

**Solutions:**
1. Permission may already be granted/denied (check settings)
2. On Android, permission may not be declared in manifest
3. On iOS, usage description may be missing from Info.plist

## Permission Best Practices by Feature

### 📸 Image Upload Features
- Request camera permission only when user taps "Take Photo"
- Request photos permission only when user taps "Choose from Gallery"
- Show preview before uploading
- Allow deleting/retaking if user not satisfied

### 📍 Location Features
- Only request if feature explicitly needs it
- Explain what location will be used for
- Work without location if denied (show map at default coordinates)
- Use "When In Use" not "Always" unless absolutely necessary

### 📱 QR Scanner
- Request camera permission when scanner opens
- Explain it's for scanning, not taking photos
- Show clear viewfinder so user knows what's being scanned
- Provide flashlight toggle for dark environments

### 📞 Contacts (Future)
- Request only when user explicitly wants to import contacts
- Explain data won't be uploaded without consent
- Allow manual entry as alternative
- Show privacy policy link

## Privacy Considerations

1. **Minimal Permissions:** Only request what you actually need
2. **Clear Purpose:** Explain exactly why each permission is needed
3. **Data Storage:** Don't store sensitive data unnecessarily
4. **Transparency:** Provide privacy policy
5. **User Control:** Allow users to disable features requiring permissions

## Summary

The app's permission system provides:

✅ **Automatic permission handling** - Widgets handle it themselves  
✅ **User-friendly dialogs** - Clear explanations before requesting  
✅ **Graceful degradation** - Works even if permissions denied  
✅ **Settings deep links** - Easy path to grant permanently denied permissions  
✅ **Platform-compliant** - Follows Android and iOS best practices  

Users can use the app confidently knowing:
- Permissions are only requested when needed
- Clear explanations are provided
- App works even if they deny permissions
- They can change their mind later in settings
