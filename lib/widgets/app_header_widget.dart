// filepath: lib/widgets/app_header_widget.dart
import 'package:flutter/material.dart';

class AppHeaderWidget extends StatelessWidget {
  final String title;
  const AppHeaderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    );
  }
}