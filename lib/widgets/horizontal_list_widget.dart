import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/actions_handler.dart';

typedef RefreshCallback = Future<void> Function();

class HorizontalListWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;
  final RefreshCallback? onNavigateRefresh;

  const HorizontalListWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final items = (widgetData['items'] as List<dynamic>?) ?? [];
    final style = widgetData['style'] as Map<String, dynamic>?;
    final shape = style?['shape']?.toString() ?? 'circle';
    final styleHeight = (style?['height'] as num?)?.toDouble();
    final styleWidth = (style?['width'] as num?)?.toDouble();
    final styleFit = style?['fit']?.toString();
    
    // Container height: use style height if provided, else default
    final containerHeight = styleHeight ?? (widgetData['height'] as num?)?.toDouble() ?? 140.0;
    
    // For width, use styleWidth if provided, else default
    final itemWidth = styleWidth ?? 120.0;
    // For image height, ensure it fits within container height with space for title
    final imageHeight = containerHeight - 50; // Leave 50px for title/padding
    
    final title = (widgetData['title'] ?? '').toString().trim();
    final displayTitle = widgetData['display_title'] ?? true;
    final isCircle = shape.toLowerCase() == 'circle';
    
    // Determine BoxFit from style
    final BoxFit boxFit;
    if (styleFit != null) {
      switch (styleFit.toLowerCase()) {
        case 'cover':
          boxFit = BoxFit.cover;
          break;
        case 'contain':
          boxFit = BoxFit.contain;
          break;
        case 'fill':
          boxFit = BoxFit.fill;
          break;
        case 'fitwidth':
          boxFit = BoxFit.fitWidth;
          break;
        case 'fitheight':
          boxFit = BoxFit.fitHeight;
          break;
        default:
          boxFit = isCircle ? BoxFit.cover : BoxFit.contain;
      }
    } else {
      boxFit = isCircle ? BoxFit.cover : BoxFit.contain;
    }

    // Show "No data" message if items are empty
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty && displayTitle)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 32,
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'No data available',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty && displayTitle)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
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
          SizedBox(
            height: containerHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (ctx, i) {
                final map = items[i] as Map<String, dynamic>;
                final img = map['image']?.toString() ?? '';
                final itemTitle = (map['title'] ?? '').toString();
                final action = map['action'] as Map<String, dynamic>?;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: InkWell(
                    onTap: action != null
                        ? () => ActionsHandler.handle(action, context, parentRefresh: onNavigateRefresh)
                        : null,
                    borderRadius: BorderRadius.circular(isCircle ? 100 : 16),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    child: SizedBox(
                      width: isCircle ? (imageHeight + 20) : itemWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: isCircle ? imageHeight : itemWidth,
                            height: imageHeight,
                            decoration: BoxDecoration(
                              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                              borderRadius: isCircle ? null : BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withOpacity(0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: isCircle
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                        width: 3,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: _buildImage(img, imageHeight, boxFit),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                          width: 3,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: _buildImage(img, imageHeight, boxFit),
                                    ),
                                  ),
                          ),
                          if (itemTitle.isNotEmpty)
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  itemTitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder({required double size}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.image_rounded,
          color: Color(0xFF94A3B8),
          size: 32,
        ),
      );

  Widget _errorIcon({required double size}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.broken_image_rounded,
          color: Color(0xFFEF4444),
          size: 32,
        ),
      );

  String _sanitizeUrl(String url) {
    if (url.isEmpty) return url;
    
    // Remove CSS url() wrapper if present
    String cleaned = url.trim();
    if (cleaned.startsWith('url(')) {
      cleaned = cleaned.substring(4);
      if (cleaned.endsWith(')')) {
        cleaned = cleaned.substring(0, cleaned.length - 1);
      }
    }
    
    // Remove quotes
    cleaned = cleaned.replaceAll('"', '').replaceAll("'", '').trim();
    
    return cleaned;
  }

  Widget _buildImage(String url, double size, BoxFit fit) {
    if (url.isEmpty) return _placeholder(size: size);
    
    // Sanitize URL
    final cleanUrl = _sanitizeUrl(url);
    if (cleanUrl.isEmpty) return _placeholder(size: size);
    
    // Check if SVG by file extension only (faster and more reliable)
    final isSvg = cleanUrl.toLowerCase().endsWith('.svg');
    
    if (isSvg) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SvgPicture.network(
          cleanUrl,
          fit: fit == BoxFit.cover ? BoxFit.contain : fit,
          placeholderBuilder: (context) => _placeholder(size: size),
        ),
      );
    }
    
    // For regular images (PNG, JPG, etc.) - use cached image
    return CachedNetworkImage(
      imageUrl: cleanUrl,
      width: size,
      height: size,
      fit: fit,
      placeholder: (context, url) => _placeholder(size: size),
      errorWidget: (context, url, error) {
        print('Image load error for $cleanUrl: $error');
        return _errorIcon(size: size);
      },
      fadeInDuration: const Duration(milliseconds: 200),
      memCacheWidth: size.toInt(),
    );
  }

  /// Detects if the image is SVG by checking URL or headers
  Future<bool> _isSvgImage(String url) async {
    if (url.isEmpty) return false;
    if (url.toLowerCase().endsWith('.svg')) return true;
    try {
      final res = await http.head(Uri.parse(url));
      final type = res.headers['content-type'] ?? '';
      return type.contains('svg');
    } catch (_) {
      return false;
    }
  }
}
