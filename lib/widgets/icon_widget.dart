import 'package:flutter/material.dart';

class IconWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;

  const IconWidget({
    super.key,
    required this.widgetData,
  });

  @override
  Widget build(BuildContext context) {
    final iconName = widgetData['icon']?.toString() ?? 'info';
    final color = _parseColor(widgetData['color']?.toString()) ?? Colors.grey;
    final size = (widgetData['size'] as num?)?.toDouble() ?? 24.0;
    final marginBottom = (widgetData['margin_bottom'] as num?)?.toDouble() ?? 0.0;
    final marginTop = (widgetData['margin_top'] as num?)?.toDouble() ?? 0.0;
    final marginLeft = (widgetData['margin_left'] as num?)?.toDouble() ?? 0.0;
    final marginRight = (widgetData['margin_right'] as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: EdgeInsets.only(
        top: marginTop,
        bottom: marginBottom,
        left: marginLeft,
        right: marginRight,
      ),
      child: Icon(
        _getIconData(iconName),
        color: color,
        size: size,
      ),
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
        return Icons.text_fields;
      case 'location_on':
      case 'location':
        return Icons.location_on;
      case 'emoji_emotions':
      case 'emoji':
        return Icons.emoji_emotions;
      case 'home':
        return Icons.home;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'account_circle':
      case 'person':
        return Icons.account_circle;
      case 'people':
        return Icons.people;
      case 'info':
        return Icons.info;
      case 'check':
        return Icons.check;
      case 'close':
        return Icons.close;
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
