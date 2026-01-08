// filepath: lib/main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'core/cart_service.dart';
import 'core/api_service.dart';
import 'core/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize cart service
  await CartService().init();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Splash screen API - loads configuration and navigates to home
  static const String splashApi = 'http://10.177.48.175:8000/api/app-screens/splash-screen';
  final appConfig = AppConfig();

  @override
  void initState() {
    super.initState();
    _loadAppConfig();
  }

  Future<void> _loadAppConfig() async {
    try {
      final data = await ApiService.fetchJson(splashApi);
      final appName = data['app_name']?.toString();
      final appLogo = data['app_logo']?.toString();
      
      if (appName != null && appName.isNotEmpty) {
        appConfig.setAppTitle(appName);
      }
      
      if (appLogo != null && appLogo.isNotEmpty) {
        appConfig.setAppLogoUrl(appLogo);
      }
      
      setState(() {}); // Trigger rebuild with new config
    } catch (e) {
      // Keep default title if API fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appConfig.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1E293B),
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF475569),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: SplashScreen(apiUrl: splashApi),
    );
  }
}