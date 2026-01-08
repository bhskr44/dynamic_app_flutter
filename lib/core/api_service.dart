import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ApiService {
  static const Duration _cacheExpiry = Duration(minutes: 5);
  
  static Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (includeAuth) {
      final token = await AuthService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }

  /// GET JSON object from [url]
  static Future<Map<String, dynamic>> fetchJson(String url, {bool includeAuth = true, bool useCache = true}) async {
    // Check cache first if enabled
    if (useCache) {
      final cachedData = await _getCachedData(url);
      if (cachedData != null) {
        return cachedData;
      }
    }
    
    final uri = Uri.parse(url);
    final headers = await _getHeaders(includeAuth: includeAuth);
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
  static Future<Map<String, dynamic>> postJson(String url, Map<String, dynamic> body, {bool includeAuth = true}) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    final resp = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'widgets': decoded};
    } else {
      throw Exception('Failed post: ${resp.statusCode}');
    }
  }

  /// PUT request
  static Future<Map<String, dynamic>> putJson(String url, Map<String, dynamic> body, {bool includeAuth = true}) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
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
  static Future<Map<String, dynamic>> patchJson(String url, Map<String, dynamic> body, {bool includeAuth = true}) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
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
  static Future<Map<String, dynamic>> deleteJson(String url, {bool includeAuth = true}) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
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

