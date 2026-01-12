// filepath: lib/widgets/dynamic_widget_builder.dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../core/form_data_manager.dart';
import 'dynamic_card.dart';
import 'dynamic_list_builder.dart';
import '../utils/actions_handler.dart';

// New modular widget imports
import 'app_header_widget.dart';
import 'search_bar_widget.dart';
import 'horizontal_list_widget.dart';
import 'vertical_list_widget.dart';
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
import 'webview_widget.dart'
    if (dart.library.html) 'webview_widget_web.dart';
import 'date_time_picker_widget.dart';
import 'qr_scanner_widget.dart'
    if (dart.library.html) 'qr_scanner_widget_web.dart';
import 'chart_widget.dart';
import 'map_widget.dart';
import 'pdf_viewer_widget.dart';
import 'input_widget.dart';
import 'divider_with_text_widget.dart';
import 'social_button_widget.dart';
import 'horizontal_layout_widget.dart';
import 'fb_create_post_card_widget.dart';
import 'create_post_form_widget.dart';
import 'icon_widget.dart';
import 'icon_button_widget.dart';
import 'fb_create_post_full_card_widget.dart';
import 'file_input_widget.dart';
import 'fb_post_card_widget.dart';

typedef RefreshCallback = Future<void> Function();

class DynamicWidgetBuilder {
  static Widget build(
    Map<String, dynamic> widgetData, 
    BuildContext context, 
    {
      RefreshCallback? onNavigateRefresh, 
      Map<String, dynamic>? screenData,
      FormDataManager? formDataManager,
    }
  ) {
    final type = (widgetData['type'] ?? '').toString();
    final displayTitle = screenData?['display_title'] ?? true;
    final widgetId = widgetData['id']?.toString();
    final visibility = widgetData['visibility']?.toString() ?? 'visible';
    final visibleWhen = widgetData['visible_when'] as Map<String, dynamic>?;

    // Check visibility using FormDataManager if widgetId is provided
    if (widgetId != null && formDataManager != null) {
      if (!formDataManager.isWidgetVisible(widgetId)) {
        return const SizedBox.shrink();
      }
    } else if (visibility == 'hidden') {
      return const SizedBox.shrink();
    }

    // Wrap widget with AnimatedBuilder if it has conditional visibility
    if (visibleWhen != null && formDataManager != null) {
      return AnimatedBuilder(
        animation: formDataManager,
        builder: (context, child) {
          // Check if all conditions are met
          bool shouldShow = true;
          visibleWhen.forEach((key, value) {
            final formValue = formDataManager.getValue(key);
            if (formValue != value.toString()) {
              shouldShow = false;
            }
          });
          
          if (!shouldShow) {
            return const SizedBox.shrink();
          }
          
          return child!;
        },
        child: _buildWidget(type, widgetData, context, onNavigateRefresh, screenData, formDataManager, displayTitle),
      );
    }

    return _buildWidget(type, widgetData, context, onNavigateRefresh, screenData, formDataManager, displayTitle);
  }

  static Widget _buildWidget(
    String type,
    Map<String, dynamic> widgetData,
    BuildContext context,
    RefreshCallback? onNavigateRefresh,
    Map<String, dynamic>? screenData,
    FormDataManager? formDataManager,
    bool displayTitle,
  ) {

    switch (type) {
      case 'app_header':
        if (!displayTitle) return const SizedBox.shrink();
        return AppHeaderWidget(title: widgetData['app_name']?.toString() ?? widgetData['title']?.toString() ?? 'App');

      case 'search_bar':
        return SearchBarWidget(widgetData: widgetData);

      case 'horizontal_list':
        return HorizontalListWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      case 'vertical_list':
        debugPrint('DynamicWidgetBuilder: building vertical_list with data: ' + widgetData.toString());
        return VerticalListWidget(
          widgetData: widgetData,
          onNavigateRefresh: onNavigateRefresh,
          formDataManager: formDataManager,
        );

      case 'carousel':
        return CarouselWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      case 'grid':
        return GridWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      case 'form':
        return FormWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      case 'button':
        return ButtonWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh, formDataManager: formDataManager);

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

      case 'file_input':
        return FileInputWidget(
          widgetData: widgetData,
          formDataManager: formDataManager,
        );

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

      // New widget types for login/auth screens
      case 'input':
        return InputWidget(widgetData: widgetData, formDataManager: formDataManager);

      case 'divider_with_text':
        return DividerWithTextWidget(widgetData: widgetData);

      case 'social_button':
        return SocialButtonWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh);

      case 'horizontal_layout':
        return HorizontalLayoutWidget(widgetData: widgetData, onNavigateRefresh: onNavigateRefresh, formDataManager: formDataManager);

      // existing types:
      case 'text':
        return _buildTextWidget(widgetData);

      case 'image':
        return _buildImageWidget(widgetData);

      case 'card':
        final title = widgetData['title']?.toString();
        final widgets = widgetData['widgets'] as List<dynamic>?;
        
        // If card has nested widgets, render as container card
        if (widgets != null && widgets.isNotEmpty) {
          final backgroundColor = _parseColor(widgetData['background_color']?.toString()) ?? Colors.white;
          final borderRadius = (widgetData['border_radius'] as num?)?.toDouble() ?? 8.0;
          final marginBottom = (widgetData['margin_bottom'] as num?)?.toDouble() ?? 16.0;
          final elevation = (widgetData['elevation'] as num?)?.toDouble() ?? 2.0;
          final padding = (widgetData['padding'] as num?)?.toDouble() ?? 16.0;
          
          return Container(
            margin: EdgeInsets.only(bottom: marginBottom),
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
                      return build(
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
        
        // Legacy card with title/image
        if (title == null || title.isEmpty) {
          return const SizedBox.shrink();
        }
        return DynamicCard(
          title: title,
          image: widgetData['image']?.toString() ?? '',
          subtitle: widgetData['subtitle']?.toString(),
          action: widgetData['action'] as Map<String, dynamic>?,
          onNavigateRefresh: onNavigateRefresh,
        );

      case 'grid':
        return DynamicListBuilder.buildList(widgetData, context, onNavigateRefresh: onNavigateRefresh);

      case 'fb_create_post_card':
        return FbCreatePostCardWidget(
          widgetData: widgetData,
          onNavigateRefresh: onNavigateRefresh,
        );

      case 'fb_post_card':
        return FbPostCardWidget(
          widgetData: widgetData,
          onNavigateRefresh: onNavigateRefresh,
        );

      case 'create_post_form':
        return CreatePostFormWidget(
          widgetData: widgetData,
          onNavigateRefresh: onNavigateRefresh,
          formDataManager: formDataManager,
        );

      case 'icon':
        return IconWidget(widgetData: widgetData);

      case 'icon_button':
        return IconButtonWidget(
          widgetData: widgetData,
          formDataManager: formDataManager,
        );

      case 'fb_create_post_full_card':
        return FbCreatePostFullCardWidget(
          widgetData: widgetData,
          onNavigateRefresh: onNavigateRefresh,
          formDataManager: formDataManager,
        );

      case 'divider':
        final height = (widgetData['height'] as num?)?.toDouble() ?? 16.0;
        final colorStr = widgetData['color']?.toString();
        final marginBottom = (widgetData['margin_bottom'] as num?)?.toDouble() ?? 0.0;
        Color? dividerColor;
        if (colorStr != null) {
          dividerColor = _parseColor(colorStr);
        }
        return Container(
          margin: EdgeInsets.only(bottom: marginBottom),
          child: Divider(
            height: height,
            thickness: height > 1 ? height : null,
            color: dividerColor,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  static Widget _buildTextWidget(Map<String, dynamic> widgetData) {
    final value = widgetData['value']?.toString() ?? '';
    final fontSize = (widgetData['fontSize'] as num?)?.toDouble() ?? 16;
    final bold = widgetData['bold'] == true;
    final strikethrough = widgetData['strikethrough'] == true;
    final colorStr = widgetData['color']?.toString();
    final alignment = widgetData['alignment']?.toString() ?? 'left';
    final marginBottom = (widgetData['margin_bottom'] as num?)?.toDouble() ?? 6.0;

    // Parse color
    Color? textColor;
    if (colorStr != null && colorStr.isNotEmpty) {
      try {
        var hex = colorStr.replaceAll('#', '').trim();
        if (hex.length == 8) {
          final alpha = hex.substring(6, 8);
          final rgb = hex.substring(0, 6);
          hex = alpha + rgb;
        } else if (hex.length == 6) {
          hex = 'FF$hex';
        }
        textColor = Color(int.parse(hex, radix: 16));
      } catch (e) {
        textColor = null;
      }
    }

    // Check if content contains HTML tags
    final hasHtml = value.contains(RegExp(r'<[^>]+>'));

    if (hasHtml) {
      // Check for iframe with PDF - render using webview
      final iframeMatch = RegExp('<iframe[^>]+src=[\"\']([^\"\'>]+\\.pdf[^\"\'>]*)[\"\']', caseSensitive: false).firstMatch(value);
      if (iframeMatch != null) {
        final pdfUrl = iframeMatch.group(1) ?? '';
        // Create a simple HTML wrapper for the PDF
        final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    body, html { 
      margin: 0; 
      padding: 0; 
      width: 100%; 
      height: 100%; 
      overflow: hidden;
    }
    iframe { 
      border: 0; 
      width: 100%; 
      height: 100%; 
    }
  </style>
</head>
<body>
  <iframe src="$pdfUrl" width="100%" height="100%" frameborder="0"></iframe>
</body>
</html>
''';
        return Container(
          height: 600,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: DynamicWebViewWidget(
            widgetData: {
              'html': htmlContent,
              'javascript_enabled': true,
            },
          ),
        );
      }

      // Use HTML widget for regular HTML rendering
      return Padding(
        padding: EdgeInsets.only(bottom: marginBottom),
        child: Html(
          data: value,
          style: {
            'body': Style(
              fontSize: FontSize(fontSize),
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              color: textColor,
              textDecoration: strikethrough ? TextDecoration.lineThrough : TextDecoration.none,
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            'p': Style(
              margin: Margins.only(bottom: 8),
            ),
          },
        ),
      );
    }

    // Use regular Text widget for plain text
    TextAlign textAlign = TextAlign.left;
    switch (alignment) {
      case 'center':
        textAlign = TextAlign.center;
        break;
      case 'right':
        textAlign = TextAlign.right;
        break;
      case 'justify':
        textAlign = TextAlign.justify;
        break;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom),
      child: Text(
        value,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: textColor,
          decoration: strikethrough ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
    );
  }

  static Widget _buildImageWidget(Map<String, dynamic> widgetData) {
    final url = widgetData['url']?.toString() ?? '';
    if (url.isEmpty) return const SizedBox.shrink();

    final width = (widgetData['width'] as num?)?.toDouble();
    final height = (widgetData['height'] as num?)?.toDouble();
    final alignment = widgetData['alignment']?.toString() ?? 'left';
    final marginTop = (widgetData['margin_top'] as num?)?.toDouble() ?? 0.0;
    final marginBottom = (widgetData['margin_bottom'] as num?)?.toDouble() ?? 8.0;
    final shape = widgetData['shape']?.toString() ?? 'rectangle';

    // Parse alignment
    Alignment imageAlignment;
    switch (alignment) {
      case 'center':
        imageAlignment = Alignment.center;
        break;
      case 'right':
        imageAlignment = Alignment.centerRight;
        break;
      default:
        imageAlignment = Alignment.centerLeft;
    }

    Widget imageWidget;
    
    if (shape == 'circle') {
      // Circular image
      final size = width ?? height ?? 40.0;
      imageWidget = CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey[300],
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (error, stackTrace) {},
        child: Container(), // Empty child to show background image
      );
    } else {
      // Regular image
      imageWidget = Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.broken_image,
          size: height ?? 100,
          color: Colors.grey,
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: marginTop, bottom: marginBottom),
      alignment: imageAlignment,
      child: imageWidget,
    );
  }

  static Color? _parseColor(String? colorString) {
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
