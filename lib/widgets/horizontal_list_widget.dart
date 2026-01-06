import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

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
    final height = (widgetData['height'] as num?)?.toDouble() ?? 140.0;
    final imageSize = height - 40;
    final title = (widgetData['title'] ?? '').toString().trim();
    final displayTitle = widgetData['display_title'] ?? true;

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
            height: height,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (ctx, i) {
                final map = items[i] as Map<String, dynamic>;
                final img = map['image']?.toString() ?? '';
                final itemTitle = (map['title'] ?? '').toString();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: imageSize + 20,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 3,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: FutureBuilder<bool>(
                                future: _isSvgImage(img),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return _placeholder(size: imageSize);
                                  }
                                  final isSvg = snapshot.data ?? false;
                                  return isSvg
                                      ? Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: SvgPicture.network(
                                            img,
                                            fit: BoxFit.contain,
                                            placeholderBuilder: (context) =>
                                                _placeholder(size: imageSize),
                                          ),
                                        )
                                      : Image.network(
                                          img,
                                          width: imageSize,
                                          height: imageSize,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  _errorIcon(size: imageSize),
                                        );
                                },
                              ),
                            ),
                          ),
                        ),
                        if (itemTitle.isNotEmpty)
                          Padding(
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
                            ),
                          ),
                      ],
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
