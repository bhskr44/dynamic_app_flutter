// filepath: lib/main.dart
import 'package:flutter/material.dart';
import 'screens/dynamic_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Use local sample JSON by default (or change to an http(s) URL)
  static const String initialApi = 'https://app.efficientexams.com/api/get-home-screen';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DynamicScreen(apiUrl: initialApi),
    );
  }
}