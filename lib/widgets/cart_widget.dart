import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/cart_service.dart';
import 'quantity_selector.dart';
import '../utils/actions_handler.dart';

class CartWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;
  final Future<void> Function()? onNavigateRefresh;

  const CartWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();
    final currency = widgetData['currency']?.toString() ?? '\$';
    final showCheckout = widgetData['show_checkout'] ?? true;
    final checkoutAction = widgetData['checkout_action'] as Map<String, dynamic>?;

    return ListenableBuilder(
      listenable: cartService,
      builder: (context, _) {
        if (cartService.isEmpty) {
          return _buildEmptyCart(context);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cart Items
              ...cartService.items.map((item) => _buildCartItem(context, item, cartService, currency)),
              
              const Divider(height: 32),
              
              // Summary
              _buildSummary(context, cartService, currency),
              
              if (showCheckout) ...[
                const SizedBox(height: 16),
                _buildCheckoutButton(context, checkoutAction, cartService),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items to get started',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, CartService cartService, String currency) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.image != null
                    ? Image.network(item.image!, fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 40, color: Color(0xFFCBD5E1)),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.variant != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatVariant(item.variant!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _formatPrice(item.price, currency),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      const Spacer(),
                      QuantitySelector(
                        initialQuantity: item.quantity,
                        onChanged: (quantity) => cartService.updateQuantity(item.id, quantity),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Delete
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              onPressed: () => cartService.removeItem(item.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CartService cartService, String currency) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Items', '${cartService.itemCount}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal', _formatPrice(cartService.subtotal, currency)),
          const Divider(height: 24),
          _buildSummaryRow(
            'Total',
            _formatPrice(cartService.subtotal, currency),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? const Color(0xFF6366F1) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(BuildContext context, Map<String, dynamic>? action, CartService cartService) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: action != null
            ? () {
                // Add cart data to action
                final actionWithData = Map<String, dynamic>.from(action);
                actionWithData['body'] = {
                  'items': cartService.items.map((item) => item.toJson()).toList(),
                  'subtotal': cartService.subtotal,
                  'itemCount': cartService.itemCount,
                };
                ActionsHandler.handle(actionWithData, context, parentRefresh: onNavigateRefresh);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Proceed to Checkout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price, String currency) {
    final formatter = NumberFormat('#,##0.00');
    return '$currency${formatter.format(price)}';
  }

  String _formatVariant(Map<String, dynamic> variant) {
    return variant.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }
}
