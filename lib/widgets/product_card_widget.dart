import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/cart_service.dart';
import '../utils/actions_handler.dart';

typedef RefreshCallback = Future<void> Function();

class ProductCardWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;
  final RefreshCallback? onNavigateRefresh;

  const ProductCardWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
  });

  @override
  State<ProductCardWidget> createState() => _ProductCardWidgetState();
}

class _ProductCardWidgetState extends State<ProductCardWidget> {
  final _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    final productId = widget.widgetData['id']?.toString() ?? '';
    final title = widget.widgetData['title']?.toString() ?? '';
    final image = widget.widgetData['image']?.toString() ?? '';
    final price = (widget.widgetData['price'] as num?)?.toDouble() ?? 0.0;
    final originalPrice = (widget.widgetData['original_price'] as num?)?.toDouble();
    final currency = widget.widgetData['currency']?.toString() ?? '\$';
    final rating = (widget.widgetData['rating'] as num?)?.toDouble();
    final reviews = (widget.widgetData['reviews'] as num?)?.toInt();
    final action = widget.widgetData['action'] as Map<String, dynamic>?;

    return ListenableBuilder(
      listenable: _cartService,
      builder: (context, _) {
        final isInWishlist = _cartService.isInWishlist(productId);
        final isInCart = _cartService.isInCart(productId);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: action != null
                ? () => ActionsHandler.handle(action, context, parentRefresh: widget.onNavigateRefresh)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: image.isNotEmpty
                          ? Image.network(image, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 48, color: Color(0xFFCBD5E1)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (rating != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < rating.floor() ? Icons.star : Icons.star_border,
                                  size: 16,
                                  color: const Color(0xFFFBBF24),
                                );
                              }),
                              if (reviews != null) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '($reviews)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _formatPrice(price, currency),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                            if (originalPrice != null && originalPrice > price) ...[
                              const SizedBox(width: 8),
                              Text(
                                _formatPrice(originalPrice, currency),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF94A3B8),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: isInWishlist ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                        ),
                        onPressed: () => _cartService.toggleWishlist(productId),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        icon: Icon(
                          isInCart ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                          color: isInCart ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
                        ),
                        onPressed: () => _addToCart(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addToCart() async {
    await _cartService.addItem(
      productId: widget.widgetData['id']?.toString() ?? '',
      title: widget.widgetData['title']?.toString() ?? '',
      image: widget.widgetData['image']?.toString(),
      price: (widget.widgetData['price'] as num?)?.toDouble() ?? 0.0,
      quantity: 1,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to cart'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatPrice(double price, String currency) {
    final formatter = NumberFormat('#,##0.00');
    return '$currency${formatter.format(price)}';
  }
}
