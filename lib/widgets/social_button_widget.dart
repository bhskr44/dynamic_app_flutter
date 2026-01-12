import 'package:flutter/material.dart';
import '../utils/actions_handler.dart';

class SocialButtonWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;
  final Future<void> Function()? onNavigateRefresh;

  const SocialButtonWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final provider = widgetData['provider']?.toString() ?? '';
    final icon = widgetData['icon']?.toString() ?? provider;
    final width = (widgetData['width'] as num?)?.toDouble() ?? 60.0;
    final height = (widgetData['height'] as num?)?.toDouble() ?? 60.0;
    final borderRadius = (widgetData['border_radius'] as num?)?.toDouble() ?? 30.0;
    final backgroundColor = _parseColor(widgetData['background_color']?.toString()) ?? Colors.white;
    final borderColor = _parseColor(widgetData['border_color']?.toString()) ?? const Color(0xFFE0E0E0);
    final borderWidth = (widgetData['border_width'] as num?)?.toDouble() ?? 1.0;
    final action = widgetData['action'] as Map<String, dynamic>?;

    return GestureDetector(
      onTap: action != null
          ? () => ActionsHandler.handle(action, context, parentRefresh: onNavigateRefresh)
          : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: Center(
          child: _buildIcon(icon, provider),
        ),
      ),
    );
  }

  Widget _buildIcon(String icon, String provider) {
    // Use Material icons for social providers
    IconData iconData;
    Color iconColor;

    switch (provider.toLowerCase()) {
      case 'facebook':
        iconData = Icons.facebook;
        iconColor = const Color(0xFF1877F2);
        break;
      case 'google':
        iconData = Icons.g_mobiledata;
        iconColor = const Color(0xFFDB4437);
        break;
      case 'apple':
        iconData = Icons.apple;
        iconColor = Colors.black;
        break;
      default:
        iconData = Icons.login;
        iconColor = const Color(0xFF6366F1);
    }

    return Icon(iconData, size: 28, color: iconColor);
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    
    try {
      var hex = colorString.replaceAll('#', '').trim().toLowerCase();
      
      if (hex.length == 8) {
        final alpha = hex.substring(6, 8);
        final rgb = hex.substring(0, 6);
        hex = alpha + rgb;
        return Color(int.parse(hex, radix: 16));
      } else if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }
}
