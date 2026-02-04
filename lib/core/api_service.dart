import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ApiService {
  static const Duration _cacheExpiry = Duration(minutes: 5);
  
  static Future<Map<String, String>> _getHeaders({bool includeAuth = true, Map<String, String>? extraHeaders}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (includeAuth) {
      final token = await AuthService.getToken();
      if (token != null && token.isNotEmpty) {
        final scheme = await AuthService.getAuthScheme();
        if (scheme == 'bearer') {
          headers['Authorization'] = 'Bearer $token';
        } else {
          headers['Authorization'] = token;
        }
        debugPrint('API Auth Token (saved) [$scheme] -> ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      } else {
        debugPrint('API Auth Token (saved) -> <none>');
      }
    }

    if (extraHeaders != null && extraHeaders.isNotEmpty) {
      headers.addAll(extraHeaders);
    }
    
    return headers;
  }

  /// GET JSON object from [url]
  static Future<Map<String, dynamic>> fetchJson(
    String url, {
    bool includeAuth = true,
    bool useCache = true,
    Map<String, String>? extraHeaders,
  }) async {
    debugPrint('API GET -> $url');
    if (includeAuth) {
      final token = await AuthService.getToken();
      if (token != null && token.isNotEmpty) {
        // Avoid returning cached unauthenticated responses when token is present
        useCache = false;
      }
    }
    // Check cache first if enabled
    if (useCache) {
      final cachedData = await _getCachedData(url);
      if (cachedData != null) {
        return cachedData;
      }
    }
    
    final uri = Uri.parse(url);
    final headers = await _getHeaders(includeAuth: includeAuth, extraHeaders: extraHeaders);
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = jsonDecode(resp.body);
      Map<String, dynamic> result;
      if (decoded is Map<String, dynamic>) {
        result = decoded;
      } else {
        // if it's list wrap into object
        result = {'widgets': decoded};
      }
      
      // Cache the result if cache is enabled
      if (useCache) {
        await _setCachedData(url, result);
      }
      
      return result;
    } else {
      throw Exception('Failed to load: ${resp.statusCode} ${resp.reasonPhrase}');
    }
  }

  /// Get cached data for a URL
  static Future<Map<String, dynamic>?> _getCachedData(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'cache_$url';
      final timeKey = 'cache_time_$url';
      
      final cachedJson = prefs.getString(cacheKey);
      final cachedTime = prefs.getInt(timeKey);
      
      if (cachedJson != null && cachedTime != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - cachedTime;
        if (cacheAge < _cacheExpiry.inMilliseconds) {
          return jsonDecode(cachedJson) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      // Cache read failed, continue with network request
    }
    return null;
  }

  /// Save data to cache
  static Future<void> _setCachedData(String url, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'cache_$url';
      final timeKey = 'cache_time_$url';
      
      await prefs.setString(cacheKey, jsonEncode(data));
      await prefs.setInt(timeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Cache write failed, but don't throw error
    }
  }

  /// Clear all cached data
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('cache_')).toList();
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      // Ignore cache clear errors
    }
  }

  /// POST to an endpoint with optional body
  static Future<Map<String, dynamic>> postJson(
    String url,
    Map<String, dynamic> body, {
    bool includeAuth = true,
    bool fallbackToForm = true,
    Map<String, String>? extraHeaders,
  }) async {
    debugPrint('API POST -> $url, body=$body');
    final headers = await _getHeaders(includeAuth: includeAuth, extraHeaders: extraHeaders);
    final uri = Uri.parse(url);

    http.Response resp = await http.post(uri, headers: headers, body: jsonEncode(body));

    if (_isRedirect(resp.statusCode)) {
      final redirectUrl = resp.headers['location'];
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        resp = await http.post(Uri.parse(redirectUrl), headers: headers, body: jsonEncode(body));
      }
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return {'success': true};
      try {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map<String, dynamic>) return decoded;
        return {'widgets': decoded};
      } catch (_) {
        return {'message': resp.body};
      }
    }

    if (fallbackToForm && _shouldRetryAsForm(resp)) {
      final formHeaders = Map<String, String>.from(headers);
      formHeaders['Content-Type'] = 'application/x-www-form-urlencoded';
      final formBody = body.map((key, value) => MapEntry(key, value?.toString() ?? ''));

      var formResp = await http.post(uri, headers: formHeaders, body: formBody);
      if (_isRedirect(formResp.statusCode)) {
        final redirectUrl = formResp.headers['location'];
        if (redirectUrl != null && redirectUrl.isNotEmpty) {
          formResp = await http.post(Uri.parse(redirectUrl), headers: formHeaders, body: formBody);
        }
      }
      if (formResp.statusCode >= 200 && formResp.statusCode < 300) {
        if (formResp.body.isEmpty) return {'success': true};
        try {
          final decoded = jsonDecode(formResp.body);
          if (decoded is Map<String, dynamic>) return decoded;
          return {'widgets': decoded};
        } catch (_) {
          return {'message': formResp.body};
        }
      }
    }

    String errorMessage = 'Failed post: ${resp.statusCode} ${resp.reasonPhrase}'.trim();
    if (resp.body.isNotEmpty) {
      try {
        final decodedBody = jsonDecode(resp.body);
        if (decodedBody is Map<String, dynamic>) {
          if (decodedBody['message'] != null) {
            errorMessage = '${decodedBody['message']} ($errorMessage)';
          } else if (decodedBody['error'] != null) {
            errorMessage = '${decodedBody['error']} ($errorMessage)';
          }
        }
      } catch (_) {
        // Not JSON; include raw body text
        errorMessage = '$errorMessage ${resp.body}'.trim();
      }
    }
    // Log the error for easier debugging
    debugPrint('ApiService.postJson error: $errorMessage');
    throw Exception(errorMessage);
  }

  static bool _shouldRetryAsForm(http.Response resp) {
    if (resp.statusCode == 415 || resp.statusCode == 400 || resp.statusCode == 422) {
      return true;
    }
    final contentType = resp.headers['content-type'] ?? '';
    if (contentType.contains('text/html')) {
      return true;
    }
    return false;
  }

  static bool _isRedirect(int statusCode) {
    return statusCode == 301 || statusCode == 302 || statusCode == 307 || statusCode == 308;
  }

  /// PUT request
  static Future<Map<String, dynamic>> putJson(
    String url,
    Map<String, dynamic> body, {
    bool includeAuth = true,
    Map<String, String>? extraHeaders,
  }) async {
    debugPrint('API PUT -> $url, body=$body');
    final headers = await _getHeaders(includeAuth: includeAuth, extraHeaders: extraHeaders);
    final resp = await http.put(Uri.parse(url), headers: headers, body: jsonEncode(body));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    } else {
      throw Exception('Failed put: ${resp.statusCode}');
    }
  }

  /// PATCH request
  static Future<Map<String, dynamic>> patchJson(
    String url,
    Map<String, dynamic> body, {
    bool includeAuth = true,
    Map<String, String>? extraHeaders,
  }) async {
    debugPrint('API PATCH -> $url, body=$body');
    final headers = await _getHeaders(includeAuth: includeAuth, extraHeaders: extraHeaders);
    final resp = await http.patch(Uri.parse(url), headers: headers, body: jsonEncode(body));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    } else {
      throw Exception('Failed patch: ${resp.statusCode}');
    }
  }

  /// DELETE request
  static Future<Map<String, dynamic>> deleteJson(
    String url, {
    bool includeAuth = true,
    Map<String, String>? extraHeaders,
  }) async {
    debugPrint('API DELETE -> $url');
    final headers = await _getHeaders(includeAuth: includeAuth, extraHeaders: extraHeaders);
    final resp = await http.delete(Uri.parse(url), headers: headers);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return {'success': true};
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    } else {
      throw Exception('Failed delete: ${resp.statusCode}');
    }
  }
}

