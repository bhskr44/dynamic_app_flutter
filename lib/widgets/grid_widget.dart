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
    final items = (widgetData['items'] as List<dynamic>?) ?? [];
    final columns = (widgetData['columns'] as num?)?.toInt() ?? 2;
    final aspectRatio = (widgetData['aspectRatio'] as num?)?.toDouble() ?? 0.8;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: aspectRatio,
      children: items.map((it) {
        final map = it as Map<String, dynamic>;
        final img = map['image']?.toString() ?? '';
        final title = map['title']?.toString() ?? '';
        final action = map['action'] as Map<String, dynamic>?;

        return Card(
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _SmartImage(url: img),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                child: ElevatedButton(
                  onPressed: action != null
                      ? () => ActionsHandler.handle(
                            action,
                            context,
                            parentRefresh: onNavigateRefresh,
                          )
                      : null,
                  child: const Text('Open'),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
        color: Colors.grey.shade200,
      );

  Widget _errorIcon() => Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.broken_image),
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
