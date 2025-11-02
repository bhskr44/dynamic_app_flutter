import 'package:flutter/material.dart';
import '../screens/dynamic_screen.dart';
import '../utils/actions_handler.dart';

typedef RefreshCallback = Future<void> Function();

class DynamicCard extends StatelessWidget {
  final String title;
  final String image;
  final String? subtitle;
  final Map<String, dynamic>? action;
  final RefreshCallback? onNavigateRefresh;

  const DynamicCard({
    super.key,
    required this.title,
    required this.image,
    this.subtitle,
    this.action,
    this.onNavigateRefresh,
  });

  void _handleTap(BuildContext context) {
    if (action == null) return;
    ActionsHandler.handle(action!, context, parentRefresh: onNavigateRefresh);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(image, height: 100, width: double.infinity, fit: BoxFit.cover),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(subtitle!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
