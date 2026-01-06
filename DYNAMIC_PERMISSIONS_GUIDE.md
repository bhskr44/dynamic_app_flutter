# Dynamic Permission Configuration Guide

## Understanding Android Permissions

**Important:** Android requires permissions to be declared in `AndroidManifest.xml` at **build time**. You cannot add them dynamically at runtime.

**However:** Permission **requests** are already dynamic - they only trigger when users actually use features that need them.

## Best Practice: Modular Permission Declaration

Only include permissions for features you actually use in your app. Remove unused permissions.

## Permission Requirements by Widget

### 📸 Image Picker Widget

**Required Permissions:**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<!-- For Android 12 and below -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
```

**When to include:** If your API returns `image_picker` widget
**Can remove if:** Not using image upload features

---

### 🎥 Video Player Widget

**Required Permissions:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

**When to include:** If streaming videos from URLs
**Can remove if:** Not using video features
**Note:** Already needed for API calls anyway

---

### 📍 Map Widget

**Required Permissions:**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**When to include:** If your API returns `map` widget with `show_current_location: true`
**Can remove if:** Not using location features or only showing static maps

---

### 📷 QR Scanner Widget

**Required Permissions:**
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

**When to include:** If your API returns `qr_scanner` widget
**Can remove if:** Only generating QR codes (not scanning)

---

### 🌐 WebView Widget

**Required Permissions:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

**When to include:** Always (already needed for API calls)
**Note:** If embedded websites need camera/mic, those permissions are handled by the website

---

### 📄 PDF Viewer Widget

**Required Permissions:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

**When to include:** Always (already needed for API calls)

---

### 📊 Charts, Forms, Cart (All Other Widgets)

**Required Permissions:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

**When to include:** Always (needed for API calls)

---

## Minimal Configuration

If you're building a simple app without camera/location features:

**android/app/src/main/AndroidManifest.xml:**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Minimum required -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application>
        <!-- ... -->
    </application>
</manifest>
```

This gives you:
- ✅ API calls
- ✅ Forms and authentication
- ✅ E-commerce features
- ✅ Charts and data visualization
- ✅ Video player (streaming)
- ✅ PDF viewer
- ✅ WebView
- ✅ QR code generation
- ❌ Camera features (image picker, QR scanner)
- ❌ Location features (maps with current location)

---

## Standard Configuration (Recommended)

For most use cases including camera and location:

**android/app/src/main/AndroidManifest.xml:**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Core -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <!-- Camera features (Image Picker, QR Scanner) -->
    <uses-permission android:name="android.permission.CAMERA" />
    
    <!-- Photo Gallery (Image Picker) -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
    
    <!-- Location features (Maps) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <application>
        <!-- ... -->
    </application>
</manifest>
```

This enables **all widget features**.

---

## Full Configuration (Future-Proof)

If planning to add more features later:

**android/app/src/main/AndroidManifest.xml:**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Core -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <!-- Camera -->
    <uses-permission android:name="android.permission.CAMERA" />
    
    <!-- Photos -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
    
    <!-- Location -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Contacts (if adding contact picker) -->
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.WRITE_CONTACTS" />
    
    <!-- Storage (for file downloads) -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    
    <!-- Microphone (for future video recording) -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    
    <application>
        <!-- ... -->
    </application>
</manifest>
```

---

## How to Choose Your Configuration

### Step 1: Check Your API Responses

Look at the widgets your server API returns:

```bash
# Check what widget types you use
grep -r '"type"' sampleapi.json
```

### Step 2: Match Widgets to Permissions

| Widget Type | Needs Camera | Needs Location | Needs Photos |
|-------------|-------------|----------------|--------------|
| image_picker | ✅ | ❌ | ✅ |
| qr_scanner | ✅ | ❌ | ❌ |
| map (with location) | ❌ | ✅ | ❌ |
| video_player | ❌ | ❌ | ❌ |
| All others | ❌ | ❌ | ❌ |

### Step 3: Update AndroidManifest.xml

Remove permissions for features you don't use.

---

## iOS Configuration

Same principle applies for **ios/Runner/Info.plist**:

### Minimal (No Camera/Location)

```xml
<!-- No additional permissions needed -->
```

### Standard (With Camera/Location)

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos and scan QR codes.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to select images.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to show it on the map.</string>
```

### Full (All Features)

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos and scan QR codes.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to show it on the map.</string>

<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for video recording.</string>

<key>NSContactsUsageDescription</key>
<string>This app needs access to your contacts.</string>
```

---

## Build Variants (Advanced)

For different app versions with different features, use Gradle build flavors:

**android/app/build.gradle:**
```gradle
android {
    flavorDimensions "features"
    
    productFlavors {
        minimal {
            dimension "features"
            applicationIdSuffix ".minimal"
        }
        full {
            dimension "features"
            applicationIdSuffix ".full"
        }
    }
}
```

**android/app/src/minimal/AndroidManifest.xml:**
```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
    <!-- Only internet, no camera/location -->
</manifest>
```

**android/app/src/full/AndroidManifest.xml:**
```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <!-- All permissions -->
</manifest>
```

Then build specific flavor:
```bash
flutter build apk --flavor minimal
flutter build apk --flavor full
```

---

## Runtime Behavior (Already Dynamic!)

The good news: **Permission requests are already dynamic**:

1. User opens your app → No permissions requested yet ✅
2. User navigates to form screen → No permissions yet ✅
3. User taps "Take Photo" button → **NOW camera permission is requested** ✅
4. User taps "Show My Location" → **NOW location permission is requested** ✅

This is already implemented in:
- [image_picker_widget.dart](lib/widgets/image_picker_widget.dart)
- [qr_scanner_widget.dart](lib/widgets/qr_scanner_widget.dart)
- [map_widget.dart](lib/widgets/map_widget.dart)

**You don't need to change anything** - permissions are already requested only when needed!

---

## Decision Tree

```
Do you use image_picker or qr_scanner widgets?
├─ YES → Include CAMERA permission
└─ NO  → Remove CAMERA permission

Do you use image_picker widget?
├─ YES → Include READ_MEDIA_IMAGES permission
└─ NO  → Remove READ_MEDIA_IMAGES permission

Do you use map widget with show_current_location: true?
├─ YES → Include LOCATION permissions
└─ NO  → Remove LOCATION permissions

Do you need internet for API calls? (Always yes)
└─ YES → Keep INTERNET permission
```

---

## Quick Setup Commands

### Option 1: Minimal Setup (No Camera/Location)

```bash
# Edit AndroidManifest.xml - keep only INTERNET permission
code android/app/src/main/AndroidManifest.xml

# Remove these lines:
# - CAMERA
# - READ_MEDIA_IMAGES
# - READ_EXTERNAL_STORAGE
# - ACCESS_FINE_LOCATION
# - ACCESS_COARSE_LOCATION
```

### Option 2: Standard Setup (Current Configuration)

Your current setup already has all permissions. You're good to go!

### Option 3: Custom Setup

Comment out unused permissions with `<!--` and `-->`:

```xml
<!-- <uses-permission android:name="android.permission.CAMERA" /> -->
<!-- <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" /> -->
```

Then rebuild:
```bash
flutter clean
flutter pub get
flutter run
```

---

## Testing Your Configuration

### Test that unused features show proper errors:

1. **Remove CAMERA permission**
2. Try to use image picker or QR scanner
3. Should show: "Permission denied" message
4. App should not crash ✅

### Test that API still works:

1. **Keep only INTERNET permission**
2. Open app and navigate screens
3. Forms, carts, charts should all work ✅
4. Only camera/location features should be disabled

---

## Summary

**What You Asked:** Can permissions be added dynamically based on widgets used?

**Answer:** 
- ❌ **Manifest declarations** - Must be at build time (Android requirement)
- ✅ **Permission requests** - Already dynamic! Only triggered when widgets are used
- ✅ **Your control** - Remove unused permissions from manifest anytime

**Recommendation:**
1. Review your API responses to see which widgets you use
2. Remove permissions for features you don't need
3. Keep INTERNET permission (always needed)
4. Add back permissions only if you get "Permission denied" errors

**Current Status:**
Your app currently has **all permissions** declared. This works but you can remove unused ones for better privacy/trust.

---

## Quick Reference Table

| Feature | Required Permission | Can Remove? |
|---------|-------------------|-------------|
| API calls, forms, auth | INTERNET | Never |
| Image upload | CAMERA, READ_MEDIA_IMAGES | If not using image_picker |
| QR scanning | CAMERA | If not using qr_scanner |
| Maps with location | ACCESS_FINE_LOCATION | If not using location |
| Video streaming | INTERNET | Never (needed anyway) |
| PDF viewing | INTERNET | Never (needed anyway) |
| Charts, forms, cart | INTERNET | Never (needed anyway) |

**Bottom line:** Keep INTERNET always. Add CAMERA only if using image_picker/qr_scanner. Add LOCATION only if using maps with user location.
