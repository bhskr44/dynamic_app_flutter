import 'package:flutter/material.dart';
import '../core/form_data_manager.dart';
import '../utils/actions_handler.dart';

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
    // Support both legacy and new API keys
    final iconName = widgetData['button_icon']?.toString() ?? widgetData['icon']?.toString() ?? 'info';
    final iconColor = _parseColor(widgetData['icon_color']?.toString()) ?? Colors.white;
    final backgroundColor = _parseColor(widgetData['button_color']?.toString()) ?? Colors.blue;
    final textColor = _parseColor(widgetData['text_color']?.toString()) ?? Colors.white;
    final borderRadius = (widgetData['border_radius'] as num?)?.toDouble() ?? 8.0;
    final height = (widgetData['height'] as num?)?.toDouble() ?? 48.0;
    final tooltip = widgetData['tooltip']?.toString();
    final buttonText = widgetData['button_text']?.toString() ?? '';
    final key = widgetData['key']?.toString();
    final value = widgetData['value']?.toString();
    final action = widgetData['action'] as Map<String, dynamic>?;

    return AnimatedBuilder(
      animation: formDataManager ?? ChangeNotifier(),
      builder: (context, child) {
        final currentValue = formDataManager?.getValue(key ?? '');
        final isSelected = currentValue == value;

        // Alignment logic
        final alignment = (widgetData['alignment']?.toString() ?? 'center').toLowerCase();
        MainAxisAlignment rowAlignment;
        switch (alignment) {
          case 'left':
            rowAlignment = MainAxisAlignment.start;
            break;
          case 'right':
            rowAlignment = MainAxisAlignment.end;
            break;
          default:
            rowAlignment = MainAxisAlignment.center;
        }


        Widget button = Container(
          margin: const EdgeInsets.all(10),
          width: double.infinity,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () {
                if (action != null) {
                  ActionsHandler.handle(action, context);
                } else if (key != null && value != null && formDataManager != null) {
                  formDataManager!.setValue(key, value);
                }
              },
              child: Row(
                mainAxisAlignment: () {
                  switch (alignment) {
                    case 'left':
                      return MainAxisAlignment.start;
                    case 'right':
                      return MainAxisAlignment.end;
                    default:
                      return MainAxisAlignment.center;
                  }
                }(),
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(_getIconData(iconName), color: iconColor, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    buttonText,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
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
