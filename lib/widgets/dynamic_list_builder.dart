import 'package:flutter/material.dart';
import 'dynamic_widget_builder.dart';
import '../utils/actions_handler.dart';

typedef RefreshCallback = Future<void> Function();

class DynamicListBuilder {
  static Widget buildList(Map<String, dynamic> widgetData, BuildContext context, {RefreshCallback? onNavigateRefresh}) {
    final items = (widgetData['items'] as List<dynamic>?) ?? [];
    final type = widgetData['type']?.toString() ?? 'vertical_list';

    if (type == 'horizontal_list') {
      return SizedBox(
        height: (widgetData['height'] as num?)?.toDouble() ?? 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemBuilder: (ctx, index) {
            final map = items[index] as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: DynamicWidgetBuilder.build(map, context, onNavigateRefresh: onNavigateRefresh),
            );
          },
        ),
      );
    } else if (type == 'grid') {
      final columns = (widgetData['columns'] as num?)?.toInt() ?? 2;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: (widgetData['aspectRatio'] as num?)?.toDouble() ?? 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (ctx, index) {
          final map = items[index] as Map<String, dynamic>;
          return DynamicWidgetBuilder.build(map, context, onNavigateRefresh: onNavigateRefresh);
        },
      );
    } else {
      // vertical list
      return Column(
        children: items.map((it) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DynamicWidgetBuilder.build(it as Map<String, dynamic>, context, onNavigateRefresh: onNavigateRefresh),
          );
        }).toList(),
      );
    }
  }
}
