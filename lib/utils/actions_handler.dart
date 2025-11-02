import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/api_service.dart';
import '../screens/dynamic_screen.dart';

class ActionsHandler {
  /// [action] is a map like:
  /// { "type": "navigate", "api": "https://..." }
  /// { "type": "open_url", "url": "https://..." }
  /// { "type": "refresh" }
  /// { "type": "call_api", "api": "...", "method": "POST", "body": {...}, "navigate_to_api": "..." }
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

      case 'call_api':
        final api = action['api']?.toString();
        final method = (action['method'] ?? 'GET').toString().toUpperCase();
        final body = action['body'] as Map<String, dynamic>?;

        try {
          Map<String, dynamic> resp;
          if (method == 'POST' && body != null) {
            resp = await ApiService.postJson(api!, body);
          } else {
            resp = await ApiService.fetchJson(api!);
          }

          // If navigate_to_api is present, navigate to that new API
          final navigateTo = action['navigate_to_api']?.toString();
          if (navigateTo != null && navigateTo.isNotEmpty) {
            Navigator.push(ctx, MaterialPageRoute(builder: (_) => DynamicScreen(apiUrl: navigateTo)));
          } else {
            // Optionally show response or refresh parent
            _showSnack(ctx, 'Action completed');
            if (parentRefresh != null) await parentRefresh();
          }
        } catch (e) {
          _showSnack(ctx, 'Call failed: $e');
        }
        break;

      default:
        _showSnack(ctx, 'Unknown action: $type');
    }
  }

  static void _showSnack(BuildContext ctx, String message) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(message)));
  }
}
