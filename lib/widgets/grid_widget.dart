import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/actions_handler.dart';

typedef RefreshCallback = Future<void> Function();

class GridWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;
  final RefreshCallback? onNavigateRefresh;

  const GridWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final title = widgetData['title']?.toString();
    final items = (widgetData['items'] as List<dynamic>?) ?? [];
    final columns = (widgetData['columns'] as num?)?.toInt() ?? 2;
    final aspectRatio = (widgetData['aspectRatio'] as num?)?.toDouble() ?? 0.8;
    final style = widgetData['style'] as Map<String, dynamic>? ?? {};
    final displayTitle = widgetData['display_title'] ?? true;

    final borderRadius =
        (style['border_radius'] as num?)?.toDouble() ?? 16.0;
    final buttonLabel =
        style['button_label']?.toString() ?? 'Open';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title.isNotEmpty && displayTitle)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: aspectRatio,
          children: items.map((it) {
            final map = it as Map<String, dynamic>;
            final img = map['image']?.toString() ?? '';
            final title = map['title']?.toString() ?? '';
            final price = map['price']?.toString();
            final mrpPrice = map['mrp_price']?.toString();
            final highLight = map['high_light']?.toString();
            final actions = map['action'];
            
            // Parse actions - can be a single action or array
            Map<String, dynamic>? navigateAction;
            Map<String, dynamic>? buttonAction;
            Map<String, dynamic>? addToCartAction;
            
            if (actions is List) {
              for (var action in actions) {
                final actionMap = action as Map<String, dynamic>;
                final type = actionMap['type']?.toString();
                if (type == 'navigate') {
                  navigateAction = actionMap;
                } else if (type == 'button') {
                  buttonAction = actionMap;
                } else if (type == 'info') {
                  addToCartAction = actionMap;
                }
              }
            } else if (actions is Map<String, dynamic>) {
              // Legacy support for single action
              navigateAction = actions;
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(borderRadius),
                  onTap: navigateAction != null
                      ? () => ActionsHandler.handle(
                            navigateAction!,
                            context,
                            parentRefresh: onNavigateRefresh,
                          )
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image with Add to Cart button overlay
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(borderRadius),
                              ),
                              child: SizedBox.expand(
                                child: _SmartImage(url: img),
                              ),
                            ),
                            // Add to Cart icon button
                            if (addToCartAction != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Material(
                                  color: _parseColor(addToCartAction['button_color']?.toString()),
                                  borderRadius: BorderRadius.circular(20),
                                  elevation: 2,
                                  child: InkWell(
                                    onTap: () => ActionsHandler.handle(
                                      addToCartAction!,
                                      context,
                                      parentRefresh: onNavigateRefresh,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.add_shopping_cart_rounded,
                                        size: 20,
                                        color: _parseColor(addToCartAction['text_color']?.toString()) ?? Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // Highlight badge
                            if (highLight != null && highLight.isNotEmpty)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    highLight,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            if (price != null && price.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (mrpPrice != null && mrpPrice.isNotEmpty) ...[
                                    Text(
                                      mrpPrice,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF94A3B8),
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    price,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            // View Details button
                            if (buttonAction != null) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => ActionsHandler.handle(
                                    buttonAction!,
                                    context,
                                    parentRefresh: onNavigateRefresh,
                                  ),
                                  icon: Icon(
                                    _getButtonIcon(buttonAction['button_icon']?.toString()),
                                    size: 16,
                                  ),
                                  label: Text(
                                    buttonAction['button_text']?.toString() ?? 'View',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _parseColor(buttonAction['button_color']?.toString()) ?? const Color(0xFF6366F1),
                                    foregroundColor: _parseColor(buttonAction['text_color']?.toString()) ?? Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getButtonIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'info':
        return Icons.info_outline_rounded;
      case 'cart':
        return Icons.shopping_cart_rounded;
      case 'view':
        return Icons.visibility_rounded;
      case 'arrow':
        return Icons.arrow_forward_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color? _parseColor(String? colorString) {
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

class _SmartImage extends StatelessWidget {
  final String url;

  const _SmartImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _placeholder();
    }

    // Check if SVG
    if (url.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        url,
        fit: BoxFit.cover,
        placeholderBuilder: (context) => _placeholder(),
      );
    }

    // Use cached network image for better performance
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => _placeholder(),
      errorWidget: (context, url, error) => _errorIcon(),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
      memCacheWidth: 600, // Resize for memory efficiency
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFF1F5F9),
        child: const Center(
          child: Icon(
            Icons.image_rounded,
            size: 48,
            color: Color(0xFF94A3B8),
          ),
        ),
      );

  Widget _errorIcon() => Container(
        color: const Color(0xFFFEF2F2),
        child: const Center(
          child: Icon(
            Icons.broken_image_rounded,
            size: 48,
            color: Color(0xFFEF4444),
          ),
        ),
      );
}
