
// filepath: lib/widgets/carousel_widget.dart
import 'package:flutter/material.dart';

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

    return Column(
      children: [
        SizedBox(
          height: (widget.widgetData['height'] as num?)?.toDouble() ?? 160,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: items.length,
            onPageChanged: (p) => setState(() => _page = p),
            itemBuilder: (ctx, i) {
              final map = items[i] as Map<String, dynamic>;
              final img = map['image']?.toString() ?? '';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: img.isNotEmpty ? Image.network(img, fit: BoxFit.cover) : Container(color: Colors.grey.shade300),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _page == i ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _page == i ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}