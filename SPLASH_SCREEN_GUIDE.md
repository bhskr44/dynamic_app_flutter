# Splash Screen Guide

## Overview
The dynamic splash screen feature allows you to configure your app's splash screen entirely through a JSON API response. This enables you to update your splash screen without rebuilding the app.

## Features
✅ **Dynamic Logo** - Load logo from URL  
✅ **Custom Backgrounds** - Gradients with configurable colors and angles  
✅ **Animations** - Fade-in, scale, or custom animations  
✅ **Auto Navigation** - Automatically navigate to home screen after delay  
✅ **Flexible Text** - Configure app title and welcome message  
✅ **Error Handling** - Fallback to default screen on error

## API Endpoint
Configure your splash screen API endpoint in `lib/main.dart`:
```dart
static const String splashApi = 'http://your-api.com/api/splash-screen';
```

## JSON Structure

### Complete Example
```json
{
  "app_name": "NEEComplit",
  "display_title": false,
  "background": {
    "type": "gradient",
    "colors": ["#6366F1", "#8B5CF6"],
    "angle": 135
  },
  "animation": {
    "type": "fade_in",
    "duration": 2000
  },
  "app_logo": "http://your-api.com/logo.png",
  "app_title": "Welcome to Your App",
  "navigation": {
    "type": "auto",
    "delay": 1000,
    "target": "http://your-api.com/api/home-screen"
  }
}
```

## Configuration Options

### 1. App Information
```json
{
  "app_name": "Your App Name",
  "app_title": "Welcome Message"
}
```
- **app_name**: Displayed if no `app_title` is provided
- **app_title**: Main welcome message on splash screen

### 2. Background
```json
{
  "background": {
    "type": "gradient",
    "colors": ["#FFFFFF", "#F2F2F2"],
    "angle": 90
  }
}
```

**Options:**
- **type**: `"gradient"` (only gradient supported currently)
- **colors**: Array of hex color codes (2+ colors)
- **angle**: Gradient angle in degrees
  - `0` = left to right
  - `90` = top to bottom
  - `180` = right to left
  - `270` = bottom to top
  - Any angle between 0-360

**Color Format:**
- Short hex: `"#FFF"` → Not supported, use 6 digits
- Standard hex: `"#FFFFFF"`
- With alpha: `"#FFFFFFFF"` (ARGB format)

### 3. Animation
```json
{
  "animation": {
    "type": "fade_in",
    "duration": 2000
  }
}
```

**Options:**
- **type**: 
  - `"fade_in"` - Fade in from transparent to opaque
  - More types can be added in the future
- **duration**: Animation duration in milliseconds (1000 = 1 second)

### 4. App Logo
```json
{
  "app_logo": "http://your-api.com/files/logo.png"
}
```

**Supported formats:**
- PNG (recommended)
- JPG/JPEG
- WebP
- SVG

**Recommendations:**
- Use transparent PNG for best results
- Recommended size: 512x512px or 1024x1024px
- Logo is displayed at 150x150dp on screen

### 5. Navigation
```json
{
  "navigation": {
    "type": "auto",
    "delay": 1000,
    "target": "http://your-api.com/api/home-screen"
  }
}
```

**Options:**
- **type**: 
  - `"auto"` - Automatically navigate after delay
  - `"manual"` - User taps to continue (future feature)
- **delay**: Milliseconds to wait before navigation (after animation completes)
- **target**: API URL for the home screen

**Total display time** = `animation.duration` + `navigation.delay`

Example: `2000ms (animation)` + `1000ms (delay)` = 3 seconds total

## Implementation Flow

```
App Start
    ↓
Load Splash API
    ↓
Parse JSON Configuration
    ↓
Display Splash Screen with:
  - Background Gradient
  - Logo (animated)
  - App Title
    ↓
Wait for duration + delay
    ↓
Navigate to Target Screen
```

## Error Handling

If the splash screen API fails:
1. Shows a default circular progress indicator
2. Waits 2 seconds
3. Navigates to default home screen

## Usage Examples

### Example 1: Simple White to Gray Gradient
```json
{
  "app_name": "My App",
  "background": {
    "type": "gradient",
    "colors": ["#FFFFFF", "#F2F2F2"],
    "angle": 90
  },
  "animation": {
    "type": "fade_in",
    "duration": 1500
  },
  "app_logo": "http://api.com/logo.png",
  "navigation": {
    "type": "auto",
    "delay": 500,
    "target": "http://api.com/api/home"
  }
}
```
**Result**: White to gray vertical gradient, 2 second total display (1.5s animation + 0.5s delay)

### Example 2: Brand Colors with Longer Display
```json
{
  "app_name": "Brand App",
  "app_title": "Welcome to Brand",
  "background": {
    "type": "gradient",
    "colors": ["#6366F1", "#8B5CF6"],
    "angle": 135
  },
  "animation": {
    "type": "fade_in",
    "duration": 2500
  },
  "app_logo": "http://api.com/brand-logo.png",
  "navigation": {
    "type": "auto",
    "delay": 1500,
    "target": "http://api.com/api/home"
  }
}
```
**Result**: Purple diagonal gradient, 4 second total display (2.5s animation + 1.5s delay)

### Example 3: Minimal Fast Splash
```json
{
  "app_name": "Quick App",
  "background": {
    "type": "gradient",
    "colors": ["#000000", "#333333"],
    "angle": 180
  },
  "animation": {
    "type": "fade_in",
    "duration": 1000
  },
  "app_logo": "http://api.com/logo.png",
  "navigation": {
    "type": "auto",
    "delay": 500,
    "target": "http://api.com/api/home"
  }
}
```
**Result**: Dark theme, 1.5 second total display

## Design Tips

### Color Combinations
1. **Modern Tech**: `["#6366F1", "#8B5CF6"]` (Purple gradient)
2. **Fresh & Clean**: `["#FFFFFF", "#F0F9FF"]` (White to light blue)
3. **Elegant Dark**: `["#1E293B", "#0F172A"]` (Dark slate)
4. **Vibrant**: `["#F59E0B", "#EF4444"]` (Orange to red)
5. **Nature**: `["#10B981", "#059669"]` (Green gradient)
6. **Ocean**: `["#0EA5E9", "#0284C7"]` (Blue gradient)

### Timing Recommendations
- **Quick splash**: 1-2 seconds (for returning users)
- **Standard**: 2-3 seconds (balanced)
- **Branded experience**: 3-4 seconds (showcase brand)
- **Maximum**: 5 seconds (longer may frustrate users)

### Logo Guidelines
- Keep it simple and recognizable
- Use high contrast against background
- Ensure it works on both light and dark backgrounds
- Test at different screen sizes

## Troubleshooting

### Logo Not Displaying
- ✅ Check URL is accessible
- ✅ Verify image format is supported
- ✅ Check CORS settings on your server
- ✅ Test URL in browser first

### Colors Not Matching
- ✅ Use 6-digit hex codes (e.g., `#FF0000` not `#F00`)
- ✅ Include the `#` symbol
- ✅ Ensure colors array has at least 2 colors

### Splash Shows Too Long/Short
- ✅ Adjust `animation.duration` for animation speed
- ✅ Adjust `navigation.delay` for pause after animation
- ✅ Remember: Total time = duration + delay

### Navigation Not Working
- ✅ Verify target URL returns valid JSON
- ✅ Check network connectivity
- ✅ Ensure target API follows the app's JSON structure

## Testing

Test your splash screen with different configurations:

```bash
# 1. Test with your API
curl http://your-api.com/api/splash-screen

# 2. Verify JSON is valid
# Use https://jsonlint.com/

# 3. Test in app
flutter run
```

## Future Enhancements

Potential features for future versions:
- [ ] Multiple animation types (scale, slide, rotate)
- [ ] Video splash screens
- [ ] Lottie animations
- [ ] Sound effects
- [ ] Manual navigation (tap to continue)
- [ ] A/B testing support
- [ ] Offline caching

## Code Location

- Splash Screen Widget: `lib/screens/splash_screen.dart`
- Main Configuration: `lib/main.dart`
- This Guide: `SPLASH_SCREEN_GUIDE.md`

## Support

For issues or questions:
1. Check this guide first
2. Review example configurations
3. Test JSON validity
4. Check app logs for errors

---

**Version**: 1.0  
**Last Updated**: January 2026  
**Compatibility**: Flutter 2.18+
