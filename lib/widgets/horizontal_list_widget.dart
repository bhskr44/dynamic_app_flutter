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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 6),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          SizedBox(
            height: height,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
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
                        ClipOval(
                          child: FutureBuilder<bool>(
                            future: _isSvgImage(img),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _placeholder(size: imageSize);
                              }
                              final isSvg = snapshot.data ?? false;
                              return isSvg
                                  ? SvgPicture.network(
                                      img,
                                      width: imageSize,
                                      height: imageSize,
                                      fit: BoxFit.cover,
                                      placeholderBuilder: (context) =>
                                          _placeholder(size: imageSize),
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
                        if (itemTitle.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              itemTitle,
                              style: const TextStyle(fontSize: 13),
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
        color: Colors.grey.shade200,
      );

  Widget _errorIcon({required double size}) => Container(
        width: size,
        height: size,
        color: Colors.grey.shade300,
        child: const Icon(Icons.broken_image),
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
