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
import 'form_widget.dart';
import 'button_widget.dart';
import 'price_widget.dart';
import 'product_card_widget.dart';
import 'cart_widget.dart';
import 'variant_selector_widget.dart';
import 'rating_widget.dart';
import 'image_picker_widget.dart';
import 'video_player_widget.dart';
import 'webview_widget.dart' show DynamicWebViewWidget;
import 'date_time_picker_widget.dart';
import 'qr_scanner_widget.dart'
    if (dart.library.html) 'qr_scanner_widget_web.dart';
import 'chart_widget.dart';
import 'map_widget.dart';
import 'pdf_viewer_widget.dart';

typedef RefreshCallback = Future<void> Function();

class DynamicWidgetBuilder {
  static Widget build(Map<String, dynamic> widgetData, BuildContext context, {RefreshCallback? onNavigateRefresh, Map<String, dynamic>? screenData}) {
    final type = (widgetData['type'] ?? '').toString();
    final displayTitle = screenData?['display_title'] ?? true;

    switch (type) {
      case 'app_header':
        if (!displayTitle) return const SizedBox.shrink();
        return AppHeaderWidget(title: widgetData['app_name']?.toString() ?? widgetData['title']?.toString() ?? 'App');

      case 'search_bar':
        return SearchBarWidget(widgetData: widgetData);

      case 'horizontal_list':
        return HorizontalListWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      case 'carousel':
        return CarouselWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      case 'grid':
        return GridWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      case 'form':
        return FormWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      case 'button':
        return ButtonWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      // E-commerce widgets
      case 'price':
        return PriceWidget(widgetData: widgetData);

      case 'product_card':
        return ProductCardWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      case 'cart':
        return CartWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      case 'variant_selector':
        return VariantSelectorWidget(widgetData: widgetData);

      case 'rating':
        return RatingWidget(widgetData: widgetData);

      // All-purpose widgets
      case 'image_picker':
        return ImagePickerWidget(widgetData: widgetData);

      case 'video_player':
        return VideoPlayerWidget(widgetData: widgetData);

      case 'webview':
        return DynamicWebViewWidget(widgetData: widgetData);

      case 'date_picker':
      case 'time_picker':
      case 'date_time_picker':
        return DateTimePickerWidget(widgetData: widgetData);

      case 'qr_scanner':
      case 'qr_generator':
        return QRScannerWidget(widgetData: widgetData);

      case 'chart':
        return ChartWidget(widgetData: widgetData);

      case 'map':
        return MapWidget(widgetData: widgetData);

      case 'pdf_viewer':
        return PdfViewerWidget(widgetData: widgetData);

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