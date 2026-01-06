import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;

  const RatingWidget({super.key, required this.widgetData});

  @override
  Widget build(BuildContext context) {
    final rating = (widgetData['rating'] as num?)?.toDouble() ?? 0.0;
    final maxRating = (widgetData['max_rating'] as num?)?.toInt() ?? 5;
    final size = (widgetData['size'] as num?)?.toDouble() ?? 20.0;
    final showValue = widgetData['show_value'] ?? true;
    final reviews = (widgetData['reviews'] as num?)?.toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(maxRating, (index) {
            return Icon(
              _getStarIcon(index + 1, rating),
              size: size,
              color: const Color(0xFFFBBF24),
            );
          }),
          if (showValue) ...[
            const SizedBox(width: 8),
            Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: size * 0.8,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
          if (reviews != null) ...[
            const SizedBox(width: 4),
            Text(
              '($reviews)',
              style: TextStyle(
                fontSize: size * 0.7,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getStarIcon(int position, double rating) {
    if (position <= rating.floor()) {
      return Icons.star;
    } else if (position - 1 < rating && rating < position) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }
}

class RatingInputWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;
  final Function(double)? onRatingChanged;

  const RatingInputWidget({
    super.key,
    required this.widgetData,
    this.onRatingChanged,
  });

  @override
  State<RatingInputWidget> createState() => _RatingInputWidgetState();
}

class _RatingInputWidgetState extends State<RatingInputWidget> {
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _rating = (widget.widgetData['initial_rating'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final maxRating = (widget.widgetData['max_rating'] as num?)?.toInt() ?? 5;
    final size = (widget.widgetData['size'] as num?)?.toDouble() ?? 32.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxRating, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _rating = (index + 1).toDouble();
              });
              widget.onRatingChanged?.call(_rating);
            },
            child: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              size: size,
              color: index < _rating ? const Color(0xFFFBBF24) : const Color(0xFFCBD5E1),
            ),
          );
        }),
      ),
    );
  }
}
