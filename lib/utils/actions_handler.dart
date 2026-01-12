import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../core/api_service.dart';
import '../core/auth_service.dart';
import '../core/cart_service.dart';
import '../core/form_data_manager.dart';
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
  static Future<void> handle(Map<String, dynamic> action, BuildContext ctx, {Future<void> Function()? parentRefresh, FormDataManager? formDataManager}) async {
    final type = (action['type'] ?? '').toString();

    switch (type) {
      case 'navigate':
        final api = action['api']?.toString();
        if (api != null && api.isNotEmpty) {
          String finalUrl = api;
          
          // Handle pass_data parameter - pass form fields as query parameters
          final passData = action['pass_data'] as List<dynamic>?;
          if (passData != null && passData.isNotEmpty && formDataManager != null) {
            final queryParams = <String, String>{};
            for (var key in passData) {
              final value = formDataManager.getValue(key.toString());
              if (value != null && value.isNotEmpty) {
                queryParams[key.toString()] = value;
              }
            }
            
            // Append query parameters to URL
            if (queryParams.isNotEmpty) {
              final uri = Uri.parse(finalUrl);
              final newUri = uri.replace(queryParameters: {...uri.queryParameters, ...queryParams});
              finalUrl = newUri.toString();
            }
          }
          
          Navigator.push(ctx, MaterialPageRoute(builder: (_) => DynamicScreen(apiUrl: finalUrl)));
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
        await _handleLogin(action, ctx, formDataManager: formDataManager);
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

      case 'call_phone':
        await _handleCallPhone(action, ctx);
        break;

      case 'api_call':
      case 'call_api':
      case 'submit':
        await _handleApiCall(action, ctx, parentRefresh, formDataManager);
        break;

      case 'button':
        await _handleButton(action, ctx, parentRefresh, formDataManager);
        break;

      case 'info':
        await _handleInfo(action, ctx, parentRefresh, formDataManager);
        break;

      case 'show_widget':
        _handleShowWidget(action, formDataManager);
        break;

      default:
        _showSnack(ctx, 'Unknown action: $type');
    }
  }






  static Future<void> _handleButton(Map<String, dynamic> action, BuildContext ctx, Future<void> Function()? parentRefresh, FormDataManager? formDataManager) async {
    // Check if button is read-only
    final readOnly = action['read_only'] ?? false;
    if (readOnly) {
      // Don't process read-only buttons
      return;
    }
    
    final clickAction = action['click_action']?.toString();
    if (clickAction == null || clickAction.isEmpty) {
      _showSnack(ctx, 'Button action missing click_action');
      return;
    }

    // Create a new action map with the click_action type and all other fields
    final newAction = Map<String, dynamic>.from(action);
    newAction['type'] = clickAction;
    newAction.remove('click_action');

    // Recursively handle the click action
    await handle(newAction, ctx, parentRefresh: parentRefresh, formDataManager: formDataManager);
  }

  static Future<void> _handleInfo(Map<String, dynamic> action, BuildContext ctx, Future<void> Function()? parentRefresh, FormDataManager? formDataManager) async {
    // Check if authentication is required
    final requireAuth = action['require_auth'] ?? false;
    
    if (requireAuth) {
      final isAuth = await AuthService.isAuthenticated();
      final token = await AuthService.getToken();
      print('DEBUG Auth Check: isAuth=$isAuth, token=${token?.substring(0, 20)}...');
      
      if (!isAuth) {
        // Handle authentication failure
        final authFailedAction = action['auth_failed_action'] as Map<String, dynamic>?;
        if (authFailedAction != null) {
          // Show message if provided
          final message = authFailedAction['message']?.toString();
          if (message != null && message.isNotEmpty) {
            _showSnack(ctx, message);
          }
          // Execute the auth failed action (usually navigate to login)
          await handle(authFailedAction, ctx, parentRefresh: parentRefresh);
        } else {
          _showSnack(ctx, 'Please login to continue');
        }
        return;
      }
    }

    // Process as API call
    final api = action['api']?.toString();
    if (api == null || api.isEmpty) {
      _showSnack(ctx, 'No API endpoint specified');
      return;
    }

    final method = (action['method'] ?? 'POST').toString().toUpperCase();
    // Support both 'params' and 'body' for data, merge with form data if available
    final requestData = (action['params'] ?? action['body']) as Map<String, dynamic>? ?? {};
    
    // Merge form data from FormDataManager if available
    if (formDataManager != null) {
      requestData.addAll(formDataManager.getAllData());
    }
    
    print('DEBUG API Call: endpoint=$api, method=$method, data=$requestData');
    
    final includeAuth = action['include_auth'] ?? true;

    try {
      Map<String, dynamic> resp;
      
      switch (method) {
        case 'POST':
          resp = await ApiService.postJson(api, requestData, includeAuth: includeAuth);
          break;
        case 'PUT':
          resp = await ApiService.putJson(api, requestData, includeAuth: includeAuth);
          break;
        case 'PATCH':
          resp = await ApiService.patchJson(api, requestData, includeAuth: includeAuth);
          break;
        case 'DELETE':
          resp = await ApiService.deleteJson(api, includeAuth: includeAuth);
          break;
        default:
          resp = await ApiService.fetchJson(api, includeAuth: includeAuth);
      }

      // Show success message if provided
      final successMsg = action['success_message']?.toString() ?? resp['message']?.toString();
      if (successMsg != null && successMsg.isNotEmpty) {
        _showSnack(ctx, successMsg);
      }

      // Handle success_action if provided
      final successAction = action['success_action'] as Map<String, dynamic>?;
      if (successAction != null) {
        await handle(successAction, ctx, parentRefresh: parentRefresh, formDataManager: formDataManager);
        return; // Don't continue with other navigation if success_action is handled
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

  static Future<void> _handleLogin(Map<String, dynamic> action, BuildContext ctx, {FormDataManager? formDataManager}) async {
    final api = action['api']?.toString();
    final method = (action['method'] ?? 'POST').toString().toUpperCase();
    final body = action['body'] as Map<String, dynamic>? ?? {};
    
    // Merge form data from FormDataManager if available
    if (formDataManager != null) {
      body.addAll(formDataManager.getAllData());
    }

    try {
      Map<String, dynamic> resp;
      
      if (method == 'POST') {
        resp = await ApiService.postJson(api!, body, includeAuth: false);
      } else {
        resp = await ApiService.fetchJson(api!, includeAuth: false);
      }

      // Save login response (token + user data)
      await AuthService.saveLoginResponse(resp);
      
      // Debug: Verify token was saved
      final savedToken = await AuthService.getToken();
      print('DEBUG Login Success: Token saved=${savedToken != null}, length=${savedToken?.length}');

      _showSnack(ctx, 'Login successful!');

      // Handle success_action if provided (preferred)
      final successAction = action['success_action'] as Map<String, dynamic>?;
      if (successAction != null) {
        await handle(successAction, ctx, formDataManager: formDataManager);
        return;
      }

      // Fallback to navigate_to for backwards compatibility
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
      final errorMsg = action['error_message']?.toString() ?? 'Login failed: $e';
      _showSnack(ctx, errorMsg);
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

  static Future<void> _handleApiCall(Map<String, dynamic> action, BuildContext ctx, Future<void> Function()? parentRefresh, FormDataManager? formDataManager) async {
    final api = action['api']?.toString();
    final method = (action['method'] ?? 'GET').toString().toUpperCase();
    // Support both 'params' and 'body' for data
    final body = (action['params'] ?? action['body']) as Map<String, dynamic>? ?? {};
    
    // Merge form data from FormDataManager if available
    if (formDataManager != null) {
      body.addAll(formDataManager.getAllData());
    }
    
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

      // Handle success_action if provided
      final successAction = action['success_action'] as Map<String, dynamic>?;
      if (successAction != null) {
        await handle(successAction, ctx, parentRefresh: parentRefresh, formDataManager: formDataManager);
        return; // Don't continue with other navigation if success_action is handled
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

  static void _handleShowWidget(Map<String, dynamic> action, FormDataManager? formDataManager) {
    if (formDataManager == null) return;
    
    final widgetId = action['widget_id']?.toString();
    if (widgetId != null && widgetId.isNotEmpty) {
      formDataManager.setWidgetVisibility(widgetId, true);
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

  static Future<void> _handleCallPhone(Map<String, dynamic> action, BuildContext ctx) async {
    try {
      final phoneUrl = action['api']?.toString() ?? '';
      
      if (phoneUrl.isEmpty) {
        _showSnack(ctx, 'No phone number provided');
        return;
      }

      // Extract phone number from tel: URL
      String phoneNumber = phoneUrl;
      if (phoneUrl.startsWith('tel:')) {
        phoneNumber = phoneUrl.substring(4);
      }

      final uri = Uri.parse(phoneUrl.startsWith('tel:') ? phoneUrl : 'tel:$phoneUrl');
      
      // Try to launch the phone dialer
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // If can't launch (web/desktop), copy to clipboard
        await Clipboard.setData(ClipboardData(text: phoneNumber));
        _showSnack(ctx, 'Phone number copied to clipboard: $phoneNumber');
      }
    } catch (e) {
      // Fallback: copy to clipboard on any error
      try {
        final phoneUrl = action['api']?.toString() ?? '';
        String phoneNumber = phoneUrl;
        if (phoneUrl.startsWith('tel:')) {
          phoneNumber = phoneUrl.substring(4);
        }
        await Clipboard.setData(ClipboardData(text: phoneNumber));
        _showSnack(ctx, 'Phone number copied to clipboard: $phoneNumber');
      } catch (clipboardError) {
        _showSnack(ctx, 'Failed to copy phone number');
      }
    }
  }

  static void _showSnack(BuildContext ctx, String message) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(message)));
  }
}
