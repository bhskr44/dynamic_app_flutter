import 'package:flutter/material.dart';
import '../core/form_data_manager.dart';
import 'dynamic_widget_builder.dart';

class FbCreatePostFullCardWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;
  final Future<void> Function()? onNavigateRefresh;
  final FormDataManager? formDataManager;

  const FbCreatePostFullCardWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
    this.formDataManager,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _parseColor(widgetData['background_color']?.toString()) ?? Colors.white;
    final borderRadius = (widgetData['border_radius'] as num?)?.toDouble() ?? 8.0;
    final marginBottom = (widgetData['margin_bottom'] as num?)?.toDouble() ?? 16.0;
    final marginTop = (widgetData['margin_top'] as num?)?.toDouble() ?? 0.0;
    final elevation = (widgetData['elevation'] as num?)?.toDouble() ?? 2.0;
    final padding = (widgetData['padding'] as num?)?.toDouble() ?? 16.0;
    final widgets = widgetData['widgets'] as List<dynamic>? ?? [];

    return Container(
      margin: EdgeInsets.only(top: marginTop, bottom: marginBottom),
      child: Card(
        color: backgroundColor,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets.map((widgetConfig) {
              if (widgetConfig is Map<String, dynamic>) {
                return DynamicWidgetBuilder.build(
                  widgetConfig,
                  context,
                  onNavigateRefresh: onNavigateRefresh,
                  formDataManager: formDataManager,
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ),
        ),
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
      return null;
    }
    return null;
  }
}
