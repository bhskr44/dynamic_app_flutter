import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;

  const PriceWidget({super.key, required this.widgetData});

  @override
  Widget build(BuildContext context) {
    final price = (widgetData['price'] as num?)?.toDouble() ?? 0.0;
    final originalPrice = (widgetData['original_price'] as num?)?.toDouble();
    final currency = widgetData['currency']?.toString() ?? '\$';
    final fontSize = (widgetData['font_size'] as num?)?.toDouble() ?? 24.0;
    final showDiscount = widgetData['show_discount'] ?? true;

    final discount = originalPrice != null && originalPrice > price
        ? ((originalPrice - price) / originalPrice * 100).round()
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _formatPrice(price, currency),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          if (originalPrice != null && originalPrice > price) ...[
            const SizedBox(width: 8),
            Text(
              _formatPrice(originalPrice, currency),
              style: TextStyle(
                fontSize: fontSize * 0.65,
                color: const Color(0xFF94A3B8),
                decoration: TextDecoration.lineThrough,
              ),
            ),
            if (showDiscount && discount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '-$discount%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _formatPrice(double price, String currency) {
    final formatter = NumberFormat('#,##0.00');
    return '$currency${formatter.format(price)}';
  }
}
