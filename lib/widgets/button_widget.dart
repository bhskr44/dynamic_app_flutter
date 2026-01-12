import 'package:flutter/material.dart';
import '../utils/actions_handler.dart';
import '../core/form_data_manager.dart';

class ButtonWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;
  final Future<void> Function()? onNavigateRefresh;
  final FormDataManager? formDataManager;

  const ButtonWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
    this.formDataManager,
  });

  @override
  Widget build(BuildContext context) {
    // Support both 'label' and 'button_text' for backwards compatibility
    final label = widgetData['button_text']?.toString() ?? widgetData['label']?.toString() ?? 'Button';
    final action = widgetData['action'] as Map<String, dynamic>?;
    final style = widgetData['style']?.toString() ?? 'primary';
    final fullWidth = widgetData['full_width'] ?? true;
    final enabled = widgetData['enabled'] ?? true;
    final readOnly = widgetData['read_only'] ?? false;
    
    // New properties
    final buttonIcon = widgetData['button_icon']?.toString();
    final buttonColor = _parseColor(widgetData['button_color']?.toString());
    final textColor = _parseColor(widgetData['text_color']?.toString()) ?? Colors.white;
    final borderColor = _parseColor(widgetData['border_color']?.toString());
    final borderWidth = (widgetData['border_width'] as num?)?.toDouble() ?? 0.0;
    final height = (widgetData['height'] as num?)?.toDouble() ?? 50.0;
    final marginBottom = (widgetData['margin_bottom'] as num?)?.toDouble() ?? 8.0;
    final borderRadius = (widgetData['border_radius'] as num?)?.toDouble() ?? 12.0;
    final bold = widgetData['bold'] == true;
    final fontSize = (widgetData['fontSize'] as num?)?.toDouble() ?? 16.0;

    // Build button content with optional icon
    Widget buttonChild;
    if (buttonIcon != null && buttonIcon.isNotEmpty) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getIconData(buttonIcon), size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      );
    } else {
      buttonChild = Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          color: textColor,
        ),
      );

    }

    // Use custom styling if colors are provided
    if (buttonColor != null || borderColor != null) {
      Widget customButton = ElevatedButton(
        onPressed: (action != null && enabled && !readOnly)
            ? () => ActionsHandler.handle(action, context, parentRefresh: onNavigateRefresh, formDataManager: formDataManager)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? const Color(0xFF6366F1),
          foregroundColor: textColor,
          disabledBackgroundColor: buttonColor ?? const Color(0xFFCCCCCC),
          disabledForegroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: Size(0, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: borderWidth)
                : BorderSide.none,
          ),
          elevation: borderWidth > 0 ? 0 : 2,
        ),
        child: buttonChild,
      );

      return Padding(
        padding: EdgeInsets.only(bottom: marginBottom),
        child: Center(child: customButton),
      );
    }

    // Legacy sty(action != null && enabled)ring
    Widget button = ElevatedButton(
      onPressed: action != null
          ? () => ActionsHandler.handle(action, context, parentRefresh: onNavigateRefresh, formDataManager: formDataManager)
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getBackgroundColor(style),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        minimumSize: Size(0, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 0,
      ),
      child: buttonChild,
    );

    if (style == 'primary' || style == 'gradient') {
      button = Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: (action != null && enabled && !readOnly)
              ? () => ActionsHandler.handle(action, context, parentRefresh: onNavigateRefresh, formDataManager: formDataManager)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            minimumSize: Size(0, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonChild,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom),
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

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'shopping_cart':
      case 'cart':
        return Icons.shopping_cart;
      case 'flash_on':
      case 'lightning':
        return Icons.flash_on;
      case 'add':
        return Icons.add;
      case 'remove':
        return Icons.remove;
      case 'favorite':
      case 'heart':
        return Icons.favorite;
      case 'share':
        return Icons.share;
      case 'search':
        return Icons.search;
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'person':
      case 'profile':
        return Icons.person;
      case 'info':
        return Icons.info;
      case 'check':
        return Icons.check;
      case 'close':
        return Icons.close;
      case 'card_giftcard':
      case 'gift':
        return Icons.card_giftcard;
      default:
        return Icons.arrow_forward;
    }
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    
    try {
      var hex = colorString.replaceAll('#', '').trim().toLowerCase();
      
      if (hex.length == 8) {
        // Handle RRGGBBAA format - convert to AARRGGBB for Flutter
        final alpha = hex.substring(6, 8);
        final rgb = hex.substring(0, 6);
        hex = alpha + rgb;
        return Color(int.parse(hex, radix: 16));
      } else if (hex.length == 6) {
        // RRGGBB format - add FF for full opacity
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }
}
