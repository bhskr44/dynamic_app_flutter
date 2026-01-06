import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
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
  static Future<Map<String, dynamic>> fetchJson(String url, {bool includeAuth = true}) async {
    final uri = Uri.parse(url);
    final headers = await _getHeaders(includeAuth: includeAuth);
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
      // if it's list wrap into object
      return {'widgets': decoded};
    } else {
      throw Exception('Failed to load: ${resp.statusCode} ${resp.reasonPhrase}');
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

