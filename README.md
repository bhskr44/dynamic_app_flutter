# Dynamic App Flutter

Build complete Flutter apps directly from JSON APIs.

Dynamic App Flutter is a **server-driven UI framework for Flutter** that allows you to control the entire app layout, widgets, and actions from your backend.

No need to publish app updates for UI changes.

Perfect for:
- E-commerce apps
- CMS driven apps
- SaaS dashboards
- Admin panels
- Educational apps
- Content platforms

The server sends JSON and the Flutter app renders the UI dynamically.



**A powerful, server-driven Flutter application that builds dynamic UIs from JSON APIs** — Perfect for building adaptable apps without constant updates. Create anything from simple content apps to full-featured e-commerce platforms, all controlled by your server.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## 🚀 Features

### Core Capabilities
- 📱 **Server-Driven UI** - Build entire screens from JSON APIs
- 🔄 **Hot Updates** - Change UI instantly without app updates
- 🎨 **Rich Widget Library** - 25+ pre-built widget types
- 🌐 **Cross-Platform** - Single codebase for Android, iOS, and Web

### Advanced Features
- 🔐 **Authentication** - Login/logout with bearer token support
- 📝 **Dynamic Forms** - Text, email, password, dropdown, checkbox, and more
- 🛒 **E-Commerce Ready** - Shopping cart, wishlist, product cards, variants
- 📊 **Data Visualization** - Line, bar, and pie charts
- 🗺️ **Maps & Location** - Google Maps integration with markers
- 📷 **Media Handling** - Image picker, video player, PDF viewer
- 🔍 **QR Codes** - Scanner (mobile) and generator
- 🌐 **WebView** - Embed websites and HTML content
- 🔔 **Permissions** - Smart, user-friendly permission requests
- 🎯 **Actions** - Navigate, refresh, API calls, share, and more

## 📦 What's Included

### Widget Types (25+)
- **Layout**: app_header, horizontal_list, carousel, grid, divider
- **Content**: text, image, card, button, video_player, pdf_viewer, webview
- **Forms**: form, text_field, dropdown, checkbox, date_picker, time_picker
- **E-Commerce**: product_card, price, cart, variant_selector, rating, quantity_selector
- **Media**: image_picker, video_player, qr_scanner, qr_generator
- **Data**: chart (line/bar/pie), map, search_bar
- **Interactive**: button, search_bar, form

### Action Types
- **Navigation**: navigate, refresh, open_url
- **Auth**: login, logout
- **API**: call_api, submit
- **Cart**: add_to_cart, remove_from_cart, clear_cart, toggle_wishlist
- **Social**: share

## 🎯 Use Cases

Perfect for building:
- 📱 **Content Apps** - News, blogs, magazines
- 🛍️ **E-Commerce** - Online stores, marketplaces
- 📚 **Educational Apps** - Courses, tutorials, e-learning
- 🏢 **Business Apps** - CRM, inventory, dashboards
- 🎫 **Booking Systems** - Hotels, tickets, appointments
- 📊 **Analytics Dashboards** - Charts, reports, KPIs
- 🎮 **Gaming Portals** - Game catalogs, leaderboards
- 🍔 **Food Delivery** - Menus, orders, tracking
- 🏥 **Healthcare** - Appointments, records, prescriptions
- 🎓 **School Management** - Attendance, grades, assignments

## 🚀 Quick Start

### Prerequisites
- Flutter 3.0 or higher
- Dart 2.18 or higher
- Android Studio / VS Code
- Google Maps API key (for map features)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/dynamic_app_flutter.git
cd dynamic_app_flutter
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure API endpoint**

Edit `lib/main.dart`:
```dart
final apiUrl = 'https://your-api.com/home';
```

4. **Add Google Maps API Key** (Optional, for maps)

**Android**: `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**iOS**: `ios/Runner/AppDelegate.swift`
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

5. **Run the app**
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## 📱 Sample JSON Structure

Create a complete screen with just JSON:

```json
{
  "app_name": "My Dynamic App",
  "display_title": true,
  "widgets": [
    {
      "type": "carousel",
      "items": [
        {
          "type": "image",
          "url": "https://example.com/banner1.jpg"
        }
      ]
    },
    {
      "type": "horizontal_list",
      "title": "Categories",
      "items": [
        {
          "type": "card",
          "title": "Electronics",
          "image": "https://example.com/electronics.jpg",
          "action": {
            "type": "navigate",
            "api": "https://api.example.com/category/electronics"
          }
        }
      ]
    },
    {
      "type": "grid",
      "title": "Featured Products",
      "columns": 2,
      "items": [
        {
          "type": "product_card",
          "id": "prod_123",
          "title": "Smartphone",
          "image": "https://example.com/phone.jpg",
          "price": 599.99,
          "original_price": 799.99,
          "rating": 4.5,
          "action": {
            "type": "add_to_cart",
            "product_id": "prod_123",
            "success_message": "Added to cart!"
          }
        }
      ]
    }
  ]
}
```

## 📖 Documentation

Comprehensive guides available:

- **[All-Purpose Features Guide](ALL_PURPOSE_GUIDE.md)** - Complete widget reference
- **[Authentication & Forms Guide](AUTH_FORMS_GUIDE.md)** - Login, forms, validation
- **[E-Commerce Guide](ECOMMERCE_GUIDE.md)** - Shopping cart, products, checkout
- **[Permissions Guide](PERMISSIONS_GUIDE.md)** - Camera, location, contacts
- **[Dynamic Permissions](DYNAMIC_PERMISSIONS_GUIDE.md)** - Platform-specific configuration
- **[UI Improvements](UI_IMPROVEMENTS.md)** - Design system and patterns

## 🛠️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── api_service.dart              # HTTP client with auth
│   ├── auth_service.dart             # Token & session management
│   ├── cart_service.dart             # Shopping cart & wishlist
│   └── permission_service.dart       # Permission handling
├── screens/
│   └── dynamic_screen.dart           # Main screen builder
├── widgets/
│   ├── dynamic_widget_builder.dart   # Widget factory
│   ├── app_header_widget.dart
│   ├── carousel_widget.dart
│   ├── chart_widget.dart
│   ├── cart_widget.dart
│   ├── date_time_picker_widget.dart
│   ├── form_widget.dart
│   ├── grid_widget.dart
│   ├── horizontal_list_widget.dart
│   ├── image_picker_widget.dart
│   ├── map_widget.dart
│   ├── pdf_viewer_widget.dart
│   ├── product_card_widget.dart
│   ├── qr_scanner_widget.dart
│   ├── rating_widget.dart
│   ├── search_bar_widget.dart
│   ├── video_player_widget.dart
│   ├── webview_widget.dart
│   └── ... (more widgets)
└── utils/
    └── actions_handler.dart          # Action dispatcher
```

## 🎨 Customization

### Add Custom Widgets

1. Create widget file: `lib/widgets/my_custom_widget.dart`
2. Register in `dynamic_widget_builder.dart`:

```dart
case 'my_custom_widget':
  return MyCustomWidget(widgetData: widgetData);
```

3. Use in JSON:
```json
{
  "type": "my_custom_widget",
  "custom_property": "value"
}
```

### Add Custom Actions

1. Add to `actions_handler.dart`:

```dart
case 'my_custom_action':
  await _handleMyCustomAction(action, ctx);
  break;
```

2. Implement handler:
```dart
static Future<void> _handleMyCustomAction(
  Map<String, dynamic> action,
  BuildContext ctx
) async {
  // Your logic here
}
```

## 🔐 Authentication Example

```json
{
  "type": "form",
  "action": {
    "type": "login",
    "api": "https://api.example.com/login",
    "method": "POST",
    "navigate_to": "https://api.example.com/dashboard"
  },
  "fields": [
    {
      "name": "email",
      "type": "email",
      "label": "Email",
      "required": true
    },
    {
      "name": "password",
      "type": "password",
      "label": "Password",
      "required": true
    }
  ]
}
```

Server response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

Token automatically stored and sent with all subsequent API calls.

## 🛒 E-Commerce Example

```json
{
  "type": "product_card",
  "id": "prod_456",
  "title": "Wireless Headphones",
  "description": "Premium noise-cancelling",
  "image": "https://example.com/headphones.jpg",
  "price": 149.99,
  "original_price": 199.99,
  "rating": 4.8,
  "reviews_count": 1250,
  "in_stock": true,
  "variants": [
    {"label": "Color", "options": ["Black", "White", "Blue"]},
    {"label": "Size", "options": ["Small", "Medium", "Large"]}
  ],
  "action": {
    "type": "add_to_cart",
    "product_id": "prod_456",
    "title": "Wireless Headphones",
    "image": "https://example.com/headphones.jpg",
    "price": 149.99,
    "success_message": "Added to cart!"
  }
}
```

## 📊 Charts Example

```json
{
  "type": "chart",
  "chart_type": "bar",
  "title": "Monthly Sales",
  "height": 300,
  "data": [
    {"label": "Jan", "value": 45000},
    {"label": "Feb", "value": 52000},
    {"label": "Mar", "value": 48000},
    {"label": "Apr", "value": 63000}
  ]
}
```

## 🗺️ Maps Example

```json
{
  "type": "map",
  "latitude": 37.7749,
  "longitude": -122.4194,
  "zoom": 14,
  "height": 400,
  "show_current_location": true,
  "markers": [
    {
      "id": "store1",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "title": "Our Store",
      "description": "Visit us here"
    }
  ]
}
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## 📱 Platform-Specific Features

### Android
- ✅ All features supported
- ✅ QR Scanner works
- ✅ Camera, location, contacts permissions
- ✅ Background services
- ✅ Push notifications (with setup)

### iOS
- ✅ All features supported
- ✅ QR Scanner works
- ✅ Camera, location, contacts permissions
- ✅ Background services
- ✅ Push notifications (with setup)

### Web
- ✅ Most features supported
- ⚠️ QR Scanner not available (generator only)
- ⚠️ Some native permissions not applicable
- ✅ Full e-commerce functionality
- ✅ Charts, forms, authentication

## 🔧 Troubleshooting

### Issue: MissingPluginException for shared_preferences
**Solution**: Run `flutter clean` and rebuild completely (not hot reload)

### Issue: Camera/Location not working
**Solution**: Check platform-specific permission declarations in AndroidManifest.xml and Info.plist

### Issue: Maps not showing
**Solution**: Verify Google Maps API key is added for your platform and billing is enabled

### Issue: QR Scanner not working on web
**Expected**: QR scanning only works on mobile. Use QR generator mode on web.

## 🚀 Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All package contributors
- Community for feedback and suggestions

## 📞 Support

- 📧 Email: your-email@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/dynamic_app_flutter/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/yourusername/dynamic_app_flutter/discussions)

## 🗺️ Roadmap

- [ ] Push notifications
- [ ] Offline mode with caching
- [ ] Advanced analytics integration
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Accessibility improvements
- [ ] Performance optimizations
- [ ] More widget types
- [ ] GraphQL support
- [ ] Real-time updates via WebSockets

---

**Made with ❤️ using Flutter**
