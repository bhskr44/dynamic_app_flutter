import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// GET JSON object from [url]
  static Future<Map<String, dynamic>> fetchJson(String url) async {
    final uri = Uri.parse(url);
    final resp = await http.get(uri, headers: _headers);
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
  static Future<Map<String, dynamic>> postJson(String url, Map<String, dynamic> body) async {
    final resp = await http.post(Uri.parse(url), headers: _headers, body: jsonEncode(body));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'widgets': decoded};
    } else {
      throw Exception('Failed post: ${resp.statusCode}');
    }
  }
}
