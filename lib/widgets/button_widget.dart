import 'package:flutter/material.dart';
import '../utils/actions_handler.dart';

class ButtonWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;
  final Future<void> Function()? onNavigateRefresh;

  const ButtonWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final label = widgetData['label']?.toString() ?? 'Button';
    final action = widgetData['action'] as Map<String, dynamic>?;
    final style = widgetData['style']?.toString() ?? 'primary';
    final fullWidth = widgetData['full_width'] ?? true;

    Widget button = ElevatedButton(
      onPressed: action != null
          ? () => ActionsHandler.handle(action, context, parentRefresh: onNavigateRefresh)
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getBackgroundColor(style),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (style == 'primary' || style == 'gradient') {
      button = Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: action != null
              ? () => ActionsHandler.handle(action, context, parentRefresh: onNavigateRefresh)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: fullWidth
          ? SizedBox(width: double.infinity, child: button)
          : Center(child: button),
    );
  }

  Color _getBackgroundColor(String style) {
    switch (style) {
      case 'primary':
        return const Color(0xFF6366F1);
      case 'secondary':
        return const Color(0xFF64748B);
      case 'success':
        return const Color(0xFF10B981);
      case 'danger':
        return const Color(0xFFEF4444);
      case 'warning':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }
}
