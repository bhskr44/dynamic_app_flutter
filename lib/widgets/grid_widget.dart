import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
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
            final action = map['action'] as Map<String, dynamic>?;

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
                  onTap: action != null
                      ? () => ActionsHandler.handle(
                            action,
                            context,
                            parentRefresh: onNavigateRefresh,
                          )
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(borderRadius),
                          ),
                          child: _SmartImage(url: img),
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
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                buttonLabel,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
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
}

class _SmartImage extends StatelessWidget {
  final String url;

  const _SmartImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _placeholder();
    }

    return FutureBuilder<bool>(
      future: _isSvg(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _placeholder();
        }

        final isSvg = snapshot.data ?? false;

        return isSvg
            ? SvgPicture.network(
                url,
                fit: BoxFit.cover,
                placeholderBuilder: (context) => _placeholder(),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _errorIcon(),
              );
      },
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

  static Future<bool> _isSvg(String url) async {
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
