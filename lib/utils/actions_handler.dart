import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../core/api_service.dart';
import '../core/auth_service.dart';
import '../core/cart_service.dart';
import '../screens/dynamic_screen.dart';

class ActionsHandler {
  /// [action] is a map like:
  /// { "type": "navigate", "api": "https://..." }
  /// { "type": "open_url", "url": "https://..." }
  /// { "type": "refresh" }
  /// { "type": "login", "api": "...", "method": "POST", "body": {...} }
  /// { "type": "logout", "navigate_to": "..." }
  /// { "type": "add_to_cart", "product_id": "...", "title": "...", "price": 100, ... }
  /// { "type": "remove_from_cart", "cart_item_id": "..." }
  /// { "type": "clear_cart" }
  /// { "type": "toggle_wishlist", "product_id": "..." }
  /// { "type": "call_api", "api": "...", "method": "POST", "body": {...}, "navigate_to_api": "..." }
  /// { "type": "share", "text": "...", "url": "...", "subject": "..." }
  static Future<void> handle(Map<String, dynamic> action, BuildContext ctx, {Future<void> Function()? parentRefresh}) async {
    final type = (action['type'] ?? '').toString();

    switch (type) {
      case 'navigate':
        final api = action['api']?.toString();
        if (api != null && api.isNotEmpty) {
          Navigator.push(ctx, MaterialPageRoute(builder: (_) => DynamicScreen(apiUrl: api)));
        }
        break;

      case 'refresh':
        if (parentRefresh != null) {
          await parentRefresh();
        }
        break;

      case 'open_url':
        final url = action['url']?.toString();
        if (url != null && url.isNotEmpty) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            // can't open
            _showSnack(ctx, 'Cannot open URL');
          }
        }
        break;

      case 'login':
        await _handleLogin(action, ctx);
        break;

      case 'logout':
        await _handleLogout(action, ctx);
        break;

      case 'add_to_cart':
        await _handleAddToCart(action, ctx);
        break;

      case 'remove_from_cart':
        await _handleRemoveFromCart(action, ctx);
        break;

      case 'clear_cart':
        await _handleClearCart(ctx);
        break;

      case 'toggle_wishlist':
        await _handleToggleWishlist(action, ctx);
        break;

      case 'share':
        await _handleShare(action, ctx);
        break;

      case 'call_api':
      case 'submit':
        await _handleApiCall(action, ctx, parentRefresh);
        break;

      default:
        _showSnack(ctx, 'Unknown action: $type');
    }
  }

  static Future<void> _handleLogin(Map<String, dynamic> action, BuildContext ctx) async {
    final api = action['api']?.toString();
    final method = (action['method'] ?? 'POST').toString().toUpperCase();
    final body = action['body'] as Map<String, dynamic>? ?? {};

    try {
      Map<String, dynamic> resp;
      
      if (method == 'POST') {
        resp = await ApiService.postJson(api!, body, includeAuth: false);
      } else {
        resp = await ApiService.fetchJson(api!, includeAuth: false);
      }

      // Save login response (token + user data)
      await AuthService.saveLoginResponse(resp);

      _showSnack(ctx, 'Login successful!');

      // Navigate to specified screen or pop
      final navigateTo = action['navigate_to']?.toString();
      if (navigateTo != null && navigateTo.isNotEmpty) {
        // Replace current screen with new one
        Navigator.pushReplacement(
          ctx,
          MaterialPageRoute(builder: (_) => DynamicScreen(apiUrl: navigateTo)),
        );
      } else {
        // Just pop if no navigation specified
        if (Navigator.canPop(ctx)) {
          Navigator.pop(ctx);
        }
      }
    } catch (e) {
      _showSnack(ctx, 'Login failed: $e');
    }
  }

  static Future<void> _handleLogout(Map<String, dynamic> action, BuildContext ctx) async {
    try {
      await AuthService.clearAuth();
      
      _showSnack(ctx, 'Logged out successfully');

      // Navigate to login or home screen
      final navigateTo = action['navigate_to']?.toString();
      if (navigateTo != null && navigateTo.isNotEmpty) {
        // Clear navigation stack and go to specified screen
        Navigator.pushAndRemoveUntil(
          ctx,
          MaterialPageRoute(builder: (_) => DynamicScreen(apiUrl: navigateTo)),
          (route) => false,
        );
      }
    } catch (e) {
      _showSnack(ctx, 'Logout failed: $e');
    }
  }

  static Future<void> _handleApiCall(Map<String, dynamic> action, BuildContext ctx, Future<void> Function()? parentRefresh) async {
    final api = action['api']?.toString();
    final method = (action['method'] ?? 'GET').toString().toUpperCase();
    final body = action['body'] as Map<String, dynamic>?;
    final includeAuth = action['include_auth'] ?? true;

    try {
      Map<String, dynamic> resp;
      
      switch (method) {
        case 'POST':
          resp = await ApiService.postJson(api!, body ?? {}, includeAuth: includeAuth);
          break;
        case 'PUT':
          resp = await ApiService.putJson(api!, body ?? {}, includeAuth: includeAuth);
          break;
        case 'PATCH':
          resp = await ApiService.patchJson(api!, body ?? {}, includeAuth: includeAuth);
          break;
        case 'DELETE':
          resp = await ApiService.deleteJson(api!, includeAuth: includeAuth);
          break;
        default:
          resp = await ApiService.fetchJson(api!, includeAuth: includeAuth);
      }

      // Show success message if provided
      final successMsg = action['success_message']?.toString();
      if (successMsg != null && successMsg.isNotEmpty) {
        _showSnack(ctx, successMsg);
      }

      // Handle navigation after API call
      final navigateTo = action['navigate_to_api']?.toString();
      if (navigateTo != null && navigateTo.isNotEmpty) {
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => DynamicScreen(apiUrl: navigateTo)));
      } else if (action['pop_on_success'] == true) {
        if (Navigator.canPop(ctx)) {
          Navigator.pop(ctx);
        }
      } else {
        // Refresh parent if no navigation
        if (parentRefresh != null) await parentRefresh();
      }
    } catch (e) {
      final errorMsg = action['error_message']?.toString() ?? 'Action failed: $e';
      _showSnack(ctx, errorMsg);
    }
  }

  // Cart actions

  static Future<void> _handleAddToCart(Map<String, dynamic> action, BuildContext ctx) async {
    try {
      final cartService = CartService();
      await cartService.addItem(
        productId: action['product_id']?.toString() ?? '',
        title: action['title']?.toString() ?? '',
        image: action['image']?.toString(),
        price: (action['price'] as num?)?.toDouble() ?? 0.0,
        quantity: (action['quantity'] as num?)?.toInt() ?? 1,
        variant: action['variant'] as Map<String, dynamic>?,
        metadata: action['metadata'] as Map<String, dynamic>?,
      );
      
      _showSnack(ctx, action['success_message']?.toString() ?? 'Added to cart');
    } catch (e) {
      _showSnack(ctx, 'Failed to add to cart: $e');
    }
  }

  static Future<void> _handleRemoveFromCart(Map<String, dynamic> action, BuildContext ctx) async {
    try {
      final cartService = CartService();
      final itemId = action['cart_item_id']?.toString() ?? '';
      await cartService.removeItem(itemId);
      
      _showSnack(ctx, action['success_message']?.toString() ?? 'Removed from cart');
    } catch (e) {
      _showSnack(ctx, 'Failed to remove from cart: $e');
    }
  }

  static Future<void> _handleClearCart(BuildContext ctx) async {
    try {
      final cartService = CartService();
      await cartService.clearCart();
      
      _showSnack(ctx, 'Cart cleared');
    } catch (e) {
      _showSnack(ctx, 'Failed to clear cart: $e');
    }
  }

  static Future<void> _handleToggleWishlist(Map<String, dynamic> action, BuildContext ctx) async {
    try {
      final cartService = CartService();
      final productId = action['product_id']?.toString() ?? '';
      await cartService.toggleWishlist(productId);
      
      final isInWishlist = cartService.isInWishlist(productId);
      _showSnack(ctx, isInWishlist ? 'Added to wishlist' : 'Removed from wishlist');
    } catch (e) {
      _showSnack(ctx, 'Failed to update wishlist: $e');
    }
  }

  static Future<void> _handleShare(Map<String, dynamic> action, BuildContext ctx) async {
    try {
      final text = action['text']?.toString() ?? '';
      final url = action['url']?.toString();
      final subject = action['subject']?.toString();

      String shareContent = text;
      if (url != null && url.isNotEmpty) {
        shareContent = '$text\n$url';
      }

      if (shareContent.isEmpty) {
        _showSnack(ctx, 'Nothing to share');
        return;
      }

      await Share.share(
        shareContent,
        subject: subject,
      );
    } catch (e) {
      _showSnack(ctx, 'Failed to share: $e');
    }
  }

  static void _showSnack(BuildContext ctx, String message) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(message)));
  }
}
