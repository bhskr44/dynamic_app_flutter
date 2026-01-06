# All-Purpose App Features Guide

This guide covers all the advanced features that make this app capable of handling virtually any use case - from social media to e-commerce, from document management to data visualization.

## Table of Contents

1. [Image Picker](#image-picker)
2. [Video Player](#video-player)
3. [WebView](#webview)
4. [Date & Time Picker](#date--time-picker)
5. [QR Scanner & Generator](#qr-scanner--generator)
6. [Charts & Data Visualization](#charts--data-visualization)
7. [Maps & Location](#maps--location)
8. [PDF Viewer](#pdf-viewer)
9. [Social Sharing](#social-sharing)

---

## Image Picker

Pick images from camera or gallery with quality and size controls.

### JSON Configuration

```json
{
  "type": "image_picker",
  "mode": "both",
  "max_width": 1920,
  "max_height": 1080,
  "quality": 85,
  "allow_multiple": false
}
```

### Parameters

- **mode**: `"camera"`, `"gallery"`, or `"both"` (default: `"both"`)
- **max_width**: Maximum image width in pixels (optional)
- **max_height**: Maximum image height in pixels (optional)
- **quality**: Image compression quality 0-100 (default: `85`)
- **allow_multiple**: Allow selecting multiple images (default: `false`)

### Use Cases

- Profile photo upload
- Document scanning
- Product photos for marketplace
- User-generated content
- ID verification

---

## Video Player

Stream and play videos with full controls.

### JSON Configuration

```json
{
  "type": "video_player",
  "url": "https://example.com/video.mp4",
  "autoplay": false,
  "loop": false,
  "show_controls": true,
  "aspect_ratio": 1.78
}
```

### Parameters

- **url**: Video URL (required)
- **autoplay**: Auto-play on load (default: `false`)
- **loop**: Loop video playback (default: `false`)
- **show_controls**: Show play/pause and seek controls (default: `true`)
- **aspect_ratio**: Video aspect ratio (default: `1.78` for 16:9)

### Use Cases

- Video tutorials
- Product demonstrations
- Entertainment content
- Educational courses
- Live stream playback

---

## WebView

Embed web content and external websites.

### JSON Configuration

```json
{
  "type": "webview",
  "url": "https://example.com",
  "javascript_enabled": true,
  "height": 400
}
```

Or load HTML directly:

```json
{
  "type": "webview",
  "html": "<h1>Hello World</h1><p>Custom HTML content</p>",
  "javascript_enabled": true,
  "height": 300
}
```

### Parameters

- **url**: Website URL (required if no html)
- **html**: HTML content string (required if no url)
- **javascript_enabled**: Enable JavaScript (default: `true`)
- **height**: WebView height in pixels (default: `400`)

### Use Cases

- Terms of service pages
- Privacy policy
- Blog content
- External forms
- Payment gateways
- Third-party widgets

---

## Date & Time Picker

Date and time selection with flexible formatting.

### JSON Configuration

**Date Only:**
```json
{
  "type": "date_picker",
  "label": "Select Date",
  "mode": "date",
  "date_format": "yyyy-MM-dd",
  "min_date": "2020-01-01",
  "max_date": "2025-12-31",
  "initial_date": "2024-01-15"
}
```

**Time Only:**
```json
{
  "type": "time_picker",
  "label": "Select Time",
  "mode": "time",
  "initial_time": "14:30"
}
```

**Both:**
```json
{
  "type": "date_time_picker",
  "label": "Appointment Date & Time",
  "mode": "both",
  "date_format": "MMM dd, yyyy"
}
```

### Parameters

- **mode**: `"date"`, `"time"`, or `"both"` (default: `"date"`)
- **label**: Label text (optional)
- **date_format**: Date format pattern (default: `"yyyy-MM-dd"`)
- **min_date**: Minimum selectable date (optional)
- **max_date**: Maximum selectable date (optional)
- **initial_date**: Pre-selected date in `yyyy-MM-dd` format (optional)
- **initial_time**: Pre-selected time in `HH:mm` format (optional)

### Use Cases

- Booking appointments
- Event scheduling
- Birthday selection
- Deadline setting
- Reminder creation

---

## QR Scanner & Generator

Scan QR codes or generate them for sharing.

### Scanner Mode

```json
{
  "type": "qr_scanner",
  "mode": "scan",
  "height": 300
}
```

### Generator Mode

```json
{
  "type": "qr_generator",
  "mode": "generate",
  "data": "https://example.com/product/123",
  "size": 200
}
```

### Parameters

- **mode**: `"scan"` or `"generate"` (default: `"scan"`)
- **height**: Scanner view height (default: `300`)
- **data**: Data to encode in QR (for generate mode)
- **size**: QR code size in pixels (default: `200`)

### Use Cases

- Ticket scanning
- Product verification
- Payment QR codes
- Contact sharing
- WiFi credentials
- Inventory management

---

## Charts & Data Visualization

Display data with line, bar, and pie charts.

### Line Chart

```json
{
  "type": "chart",
  "chart_type": "line",
  "title": "Sales Trend",
  "height": 300,
  "curved": true,
  "fill": true,
  "show_grid": true,
  "data": [
    {"x": 0, "y": 10},
    {"x": 1, "y": 25},
    {"x": 2, "y": 15},
    {"x": 3, "y": 40}
  ]
}
```

### Bar Chart

```json
{
  "type": "chart",
  "chart_type": "bar",
  "title": "Monthly Revenue",
  "height": 300,
  "data": [
    {"label": "Jan", "value": 5000},
    {"label": "Feb", "value": 7500},
    {"label": "Mar", "value": 6200},
    {"label": "Apr", "value": 8900}
  ]
}
```

### Pie Chart

```json
{
  "type": "chart",
  "chart_type": "pie",
  "title": "Market Share",
  "height": 300,
  "donut": false,
  "data": [
    {"label": "Product A", "value": 35},
    {"label": "Product B", "value": 25},
    {"label": "Product C", "value": 40}
  ]
}
```

### Parameters

- **chart_type**: `"line"`, `"bar"`, or `"pie"` (required)
- **title**: Chart title (optional)
- **height**: Chart height in pixels (default: `300`)
- **curved**: Curved lines for line chart (default: `true`)
- **fill**: Fill area under line (default: `false`)
- **show_grid**: Show grid lines (default: `true`)
- **donut**: Donut style for pie chart (default: `false`)
- **data**: Array of data points (required)

### Use Cases

- Sales analytics
- Performance metrics
- Budget tracking
- Survey results
- Health statistics
- Traffic analysis

---

## Maps & Location

Display maps with markers and current location.

### JSON Configuration

```json
{
  "type": "map",
  "latitude": 37.7749,
  "longitude": -122.4194,
  "zoom": 14,
  "height": 400,
  "show_current_location": true,
  "map_type": "normal",
  "markers": [
    {
      "id": "marker1",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "title": "San Francisco",
      "description": "City by the bay"
    },
    {
      "id": "marker2",
      "latitude": 37.8044,
      "longitude": -122.2712,
      "title": "Oakland",
      "description": "East Bay"
    }
  ]
}
```

### Parameters

- **latitude**: Default center latitude (required)
- **longitude**: Default center longitude (required)
- **zoom**: Zoom level 0-20 (default: `12`)
- **height**: Map height in pixels (default: `400`)
- **show_current_location**: Show user's location (default: `false`)
- **map_type**: `"normal"`, `"satellite"`, `"hybrid"`, or `"terrain"` (default: `"normal"`)
- **markers**: Array of map markers (optional)

### Marker Properties

- **id**: Unique marker ID (required)
- **latitude**: Marker latitude (required)
- **longitude**: Marker longitude (required)
- **title**: Marker title (optional)
- **description**: Marker description (optional)

### Use Cases

- Store locator
- Delivery tracking
- Property listings
- Event locations
- Service areas
- Route planning

**Note:** Google Maps requires API key configuration in Android and iOS native files.

---

## PDF Viewer

View PDF documents from URLs.

### JSON Configuration

```json
{
  "type": "pdf_viewer",
  "url": "https://example.com/document.pdf",
  "height": 600,
  "enable_zoom": true
}
```

### Parameters

- **url**: PDF file URL (required)
- **height**: Viewer height in pixels (default: `600`)
- **enable_zoom**: Allow zoom gestures (default: `true`)

### Use Cases

- Contracts and agreements
- Invoices and receipts
- User manuals
- Reports and documents
- E-books and magazines
- Certificates

---

## Social Sharing

Share text and URLs to social media and messaging apps.

### JSON Configuration

```json
{
  "type": "button",
  "label": "Share",
  "action": {
    "type": "share",
    "text": "Check out this amazing product!",
    "url": "https://example.com/product/123",
    "subject": "Product Recommendation"
  }
}
```

### Action Parameters

- **type**: Must be `"share"`
- **text**: Text to share (required)
- **url**: URL to share (optional)
- **subject**: Email subject line (optional)

### Use Cases

- Product sharing
- Content promotion
- Referral programs
- Social media integration
- App invitations

---

## Complete Example: Multi-Feature Screen

Here's a comprehensive example combining multiple all-purpose widgets:

```json
{
  "app_name": "All-Purpose App",
  "display_title": true,
  "widgets": [
    {
      "type": "text",
      "value": "Upload Your Profile Photo",
      "fontSize": 20,
      "bold": true
    },
    {
      "type": "image_picker",
      "mode": "both",
      "max_width": 1024,
      "quality": 90
    },
    {
      "type": "divider"
    },
    {
      "type": "text",
      "value": "Select Your Birthday",
      "fontSize": 18,
      "bold": true
    },
    {
      "type": "date_picker",
      "label": "Date of Birth",
      "mode": "date",
      "max_date": "2024-12-31"
    },
    {
      "type": "divider"
    },
    {
      "type": "text",
      "value": "Location",
      "fontSize": 18,
      "bold": true
    },
    {
      "type": "map",
      "latitude": 40.7128,
      "longitude": -74.0060,
      "zoom": 12,
      "height": 300,
      "show_current_location": true,
      "markers": [
        {
          "id": "office",
          "latitude": 40.7128,
          "longitude": -74.0060,
          "title": "Our Office",
          "description": "Visit us here"
        }
      ]
    },
    {
      "type": "divider"
    },
    {
      "type": "text",
      "value": "Sales Performance",
      "fontSize": 18,
      "bold": true
    },
    {
      "type": "chart",
      "chart_type": "bar",
      "height": 250,
      "data": [
        {"label": "Q1", "value": 45000},
        {"label": "Q2", "value": 52000},
        {"label": "Q3", "value": 48000},
        {"label": "Q4", "value": 63000}
      ]
    },
    {
      "type": "divider"
    },
    {
      "type": "button",
      "label": "Share Results",
      "action": {
        "type": "share",
        "text": "Check out our quarterly performance!",
        "url": "https://example.com/report"
      }
    }
  ]
}
```

---

## Platform-Specific Setup

### Android

1. **Google Maps**: Add API key to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

2. **Camera Permissions**: Already configured in manifest

### iOS

1. **Google Maps**: Add API key to `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

2. **Permissions**: Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location access for maps</string>
```

---

## Integration with Forms

All widgets can be integrated into forms for data collection:

```json
{
  "type": "form",
  "action": {
    "type": "submit",
    "api": "https://api.example.com/submit",
    "method": "POST"
  },
  "fields": [
    {
      "name": "profile_photo",
      "type": "image_picker",
      "label": "Profile Photo"
    },
    {
      "name": "birth_date",
      "type": "date_picker",
      "label": "Date of Birth",
      "required": true
    },
    {
      "name": "appointment_time",
      "type": "time_picker",
      "label": "Preferred Time"
    }
  ]
}
```

---

## Troubleshooting

### Image Picker Not Working
- Run `flutter clean` and rebuild
- Check camera/storage permissions
- Restart the app completely

### Maps Not Displaying
- Verify Google Maps API key is added
- Enable Maps SDK for Android/iOS in Google Cloud Console
- Check billing is enabled for your Google Cloud project

### QR Scanner Black Screen
- Ensure camera permissions are granted
- Test on physical device (not emulator)
- Check camera is not in use by another app

### Video Player Not Loading
- Verify video URL is accessible
- Check network connection
- Ensure video format is supported (MP4 recommended)

---

## Best Practices

1. **Image Picker**: Always set quality and max dimensions to reduce file size
2. **Video Player**: Use adaptive streaming for better performance
3. **WebView**: Enable JavaScript only when necessary for security
4. **Date Picker**: Set realistic min/max dates to improve UX
5. **QR Scanner**: Provide clear instructions to users
6. **Charts**: Keep data points reasonable (< 100 for performance)
7. **Maps**: Limit number of markers for better performance
8. **PDF Viewer**: Use CDN URLs for faster loading
9. **Social Share**: Include both text and URL for better engagement

---

## Conclusion

Your app now supports virtually any use case - from simple forms to complex data visualization, from document management to real-time location tracking. All features are server-driven via JSON, giving you complete control without app updates.

For more information, see:
- [Authentication & Forms Guide](AUTH_FORMS_GUIDE.md)
- [E-commerce Guide](ECOMMERCE_GUIDE.md)
- [Implementation Summary](IMPLEMENTATION_SUMMARY.md)
