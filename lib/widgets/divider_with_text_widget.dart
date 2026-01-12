import 'package:flutter/material.dart';

class DividerWithTextWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;

  const DividerWithTextWidget({super.key, required this.widgetData});

  @override
  Widget build(BuildContext context) {
    final text = widgetData['text']?.toString() ?? '';
    final textColor = _parseColor(widgetData['text_color']?.toString()) ?? const Color(0xFF7f8c8d);
    final fontSize = (widgetData['fontSize'] as num?)?.toDouble() ?? 14.0;
    final marginTop = (widgetData['margin_top'] as num?)?.toDouble() ?? 10.0;
    final marginBottom = (widgetData['margin_bottom'] as num?)?.toDouble() ?? 20.0;

    return Container(
      margin: EdgeInsets.only(top: marginTop, bottom: marginBottom),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: const Color(0xFFE0E0E0),
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: const Color(0xFFE0E0E0),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
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
