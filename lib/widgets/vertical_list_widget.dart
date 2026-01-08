import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/actions_handler.dart';

typedef RefreshCallback = Future<void> Function();

class VerticalListWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;
  final RefreshCallback? onNavigateRefresh;

  const VerticalListWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final items = (widgetData['items'] as List<dynamic>?) ?? [];
    final style = widgetData['style'] as Map<String, dynamic>?;
    final shape = style?['shape']?.toString() ?? 'rectangle';
    final styleHeight = (style?['height'] as num?)?.toDouble();
    final itemHeight = styleHeight ?? 120.0;
    final title = (widgetData['title'] ?? '').toString().trim();
    final displayTitle = widgetData['display_title'] ?? true;
    final isCircle = shape.toLowerCase() == 'circle';

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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final map = items[i] as Map<String, dynamic>;
              final img = map['image']?.toString() ?? '';
              final itemTitle = (map['title'] ?? '').toString();
              final subtitle = (map['subtitle'] ?? '').toString();
              final description = (map['description'] ?? '').toString();
              final action = map['action'] as Map<String, dynamic>?;

              return InkWell(
                onTap: action != null
                    ? () => ActionsHandler.handle(action, context, parentRefresh: onNavigateRefresh)
                    : null,
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: itemHeight,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Image section
                      Container(
                        width: itemHeight,
                        height: itemHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        child: isCircle
                            ? Center(
                                child: Container(
                                  width: itemHeight - 32,
                                  height: itemHeight - 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: _buildImage(img, itemHeight - 32, isCircle),
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                                child: _buildImage(img, itemHeight, isCircle),
                              ),
                      ),
                      // Content section
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (itemTitle.isNotEmpty)
                                Text(
                                  itemTitle,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (subtitle.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // Arrow icon
                      if (action != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
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

  Widget _buildImage(String url, double size, bool isCircle) {
    if (url.isEmpty) return _placeholder(size: size);

    // Sanitize URL
    final cleanUrl = _sanitizeUrl(url);
    if (cleanUrl.isEmpty) return _placeholder(size: size);

    // Check if SVG by file extension
    final isSvg = cleanUrl.toLowerCase().endsWith('.svg');

    if (isSvg) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SvgPicture.network(
          cleanUrl,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => _placeholder(size: size),
        ),
      );
    }

    // For regular images
    return Image.network(
      cleanUrl,
      width: size,
      height: size,
      fit: isCircle ? BoxFit.cover : BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _placeholder(size: size);
      },
      errorBuilder: (context, error, stackTrace) {
        print('Image load error for $cleanUrl: $error');
        return _errorIcon(size: size);
      },
    );
  }
}
