import 'package:flutter/material.dart';
import '../core/form_data_manager.dart';
import 'dynamic_widget_builder.dart';

class HorizontalLayoutWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;
  final Future<void> Function()? onNavigateRefresh;
  final FormDataManager? formDataManager;

  const HorizontalLayoutWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
    this.formDataManager,
  });

  @override
  Widget build(BuildContext context) {
    final items = (widgetData['items'] as List<dynamic>?) ?? [];
    final alignment = widgetData['alignment']?.toString() ?? 'left';
    final spacing = (widgetData['spacing'] as num?)?.toDouble() ?? 10.0;
    final marginBottom = (widgetData['margin_bottom'] as num?)?.toDouble() ?? 0.0;

    MainAxisAlignment mainAxisAlignment;
    switch (alignment) {
      case 'center':
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      case 'right':
        mainAxisAlignment = MainAxisAlignment.end;
        break;
      case 'space-between':
        mainAxisAlignment = MainAxisAlignment.spaceBetween;
        break;
      case 'space-around':
        mainAxisAlignment = MainAxisAlignment.spaceAround;
        break;
      default:
        mainAxisAlignment = MainAxisAlignment.start;
    }

    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : spacing),
            child: DynamicWidgetBuilder.build(
              entry.value as Map<String, dynamic>,
              context,
              onNavigateRefresh: onNavigateRefresh,
              formDataManager: formDataManager,
            ),
          );
        }).toList(),
      ),
    );
  }
}
