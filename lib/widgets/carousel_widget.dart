
// filepath: lib/widgets/carousel_widget.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/actions_handler.dart';

typedef RefreshCallback = Future<void> Function();

class CarouselWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;
  final RefreshCallback? onNavigateRefresh;
  const CarouselWidget({super.key, required this.widgetData, this.onNavigateRefresh});

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _page = 0;
  final PageController _ctrl = PageController(viewportFraction: 0.95);

  @override
  Widget build(BuildContext context) {
    final items = (widget.widgetData['items'] as List<dynamic>?) ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          SizedBox(
            height: (widget.widgetData['height'] as num?)?.toDouble() ?? 200,
            child: PageView.builder(
              controller: _ctrl,
              itemCount: items.length,
              onPageChanged: (p) => setState(() => _page = p),
              itemBuilder: (ctx, i) {
                final map = items[i] as Map<String, dynamic>;
                // Support both 'image' and 'url' fields
                final img = map['image']?.toString() ?? map['url']?.toString() ?? '';
                return AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_ctrl.position.haveDimensions) {
                      value = _ctrl.page! - i;
                      value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                    }
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: img.isNotEmpty
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: img,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: const Color(0xFFF1F5F9),
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: const Color(0xFFFEF2F2),
                                    child: const Icon(Icons.broken_image_rounded, size: 48, color: Color(0xFFEF4444)),
                                  ),
                                  fadeInDuration: const Duration(milliseconds: 200),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_rounded, size: 48, color: Color(0xFF94A3B8)),
                            ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(items.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? const Color(0xFF6366F1) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}