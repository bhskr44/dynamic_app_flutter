// filepath: lib/widgets/dynamic_widget_builder.dart
import 'package:flutter/material.dart';
import 'dynamic_card.dart';
import 'dynamic_list_builder.dart';
import '../utils/actions_handler.dart';

// New modular widget imports
import 'app_header_widget.dart';
import 'search_bar_widget.dart';
import 'horizontal_list_widget.dart';
import 'carousel_widget.dart';
import 'grid_widget.dart';

typedef RefreshCallback = Future<void> Function();

class DynamicWidgetBuilder {
  static Widget build(Map<String, dynamic> widgetData, BuildContext context, {RefreshCallback? onNavigateRefresh}) {
    final type = (widgetData['type'] ?? '').toString();

    switch (type) {
      case 'app_header':
        return AppHeaderWidget(title: widgetData['title']?.toString() ?? 'App');

      case 'search_bar':
        return SearchBarWidget(widgetData: widgetData);

      case 'horizontal_list':
        return HorizontalListWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      case 'carousel':
        return CarouselWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      case 'grid':
        return GridWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      // existing types:
      case 'text':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            widgetData['value']?.toString() ?? '',
            style: TextStyle(
              fontSize: (widgetData['fontSize'] as num?)?.toDouble() ?? 16,
              fontWeight: widgetData['bold'] == true ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        );

      case 'image':
        final url = widgetData['url']?.toString() ?? '';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: url.isNotEmpty ? Image.network(url, fit: BoxFit.cover) : const SizedBox.shrink(),
        );

      case 'card':
        return DynamicCard(
          title: widgetData['title']?.toString() ?? 'Untitled',
          image: widgetData['image']?.toString() ?? '',
          subtitle: widgetData['subtitle']?.toString(),
          action: widgetData['action'] as Map<String, dynamic>?,
          onNavigateRefresh: onNavigateRefresh,
        );

      case 'horizontal_list':
      case 'vertical_list':
      case 'grid':
        return DynamicListBuilder.buildList(widgetData, context, onNavigateRefresh: onNavigateRefresh);

      case 'divider':
        return const Divider(height: 16);

      default:
        return const SizedBox.shrink();
    }
  }
}