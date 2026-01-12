import 'package:flutter/material.dart';
import '../core/form_data_manager.dart';

class IconButtonWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;
  final FormDataManager? formDataManager;

  const IconButtonWidget({
    super.key,
    required this.widgetData,
    this.formDataManager,
  });

  @override
  Widget build(BuildContext context) {
    final iconName = widgetData['icon']?.toString() ?? 'info';
    final iconColor = _parseColor(widgetData['icon_color']?.toString()) ?? Colors.blue;
    final backgroundColor = _parseColor(widgetData['background_color']?.toString()) ?? Colors.blue.withOpacity(0.1);
    final size = (widgetData['size'] as num?)?.toDouble() ?? 36.0;
    final borderRadius = (widgetData['border_radius'] as num?)?.toDouble() ?? 18.0;
    final tooltip = widgetData['tooltip']?.toString();
    final key = widgetData['key']?.toString();
    final value = widgetData['value']?.toString();

    return AnimatedBuilder(
      animation: formDataManager ?? ChangeNotifier(),
      builder: (context, child) {
        // Check if this button's value matches the current form value
        final currentValue = formDataManager?.getValue(key ?? '');
        final isSelected = currentValue == value;

        Widget button = InkWell(
          onTap: () {
            if (key != null && value != null && formDataManager != null) {
              formDataManager!.setValue(key, value);
            }
          },
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isSelected ? iconColor.withOpacity(0.2) : backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: isSelected 
                  ? Border.all(color: iconColor, width: 2)
                  : null,
            ),
            child: Icon(
              _getIconData(iconName),
              color: iconColor,
              size: size * 0.5,
            ),
          ),
        );

        if (tooltip != null && tooltip.isNotEmpty) {
          button = Tooltip(
            message: tooltip,
            child: button,
          );
        }

        return button;
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'photo_library':
      case 'photo':
        return Icons.photo_library;
      case 'videocam':
      case 'video':
        return Icons.videocam;
      case 'text_fields':
      case 'text':
        return Icons.text_fields;
      case 'location_on':
      case 'location':
        return Icons.location_on;
      case 'emoji_emotions':
      case 'emoji':
        return Icons.emoji_emotions;
      case 'add_photo_alternate':
        return Icons.add_photo_alternate;
      default:
        return Icons.info;
    }
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return Colors.grey;
    
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
      return Colors.grey;
    }
    return Colors.grey;
  }
}
