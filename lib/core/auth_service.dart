import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  static String? _cachedToken;
  static Map<String, dynamic>? _cachedUser;

  /// Get the current auth token
  static Future<String?> getToken() async {
    try {
      if (_cachedToken != null) return _cachedToken;
      
      final prefs = await SharedPreferences.getInstance();
      _cachedToken = prefs.getString(_tokenKey);
      return _cachedToken;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  /// Save auth token
  static Future<void> saveToken(String token) async {
    try {
      print('DEBUG saveToken: saving token length=${token.length}');
      _cachedToken = token;
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_tokenKey, token);
      print('DEBUG saveToken: SharedPreferences.setString returned $success');
    } catch (e) {
      print('ERROR saveToken: $e');
    }
  }

  /// Get user data
  static Future<Map<String, dynamic>?> getUser() async {
    if (_cachedUser != null) return _cachedUser;
    
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      // Simple parse - in production use proper JSON decoding
      _cachedUser = {}; // Store parsed user data
    }
    return _cachedUser;
  }

  /// Save user data
  static Future<void> saveUser(Map<String, dynamic> user) async {
    _cachedUser = user;
    final prefs = await SharedPreferences.getInstance();
    // In production, use jsonEncode(user)
    await prefs.setString(_userKey, user.toString());
  }

  /// Clear all auth data (logout)
  static Future<void> clearAuth() async {
    _cachedToken = null;
    _cachedUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save complete login response (token + user data)
  static Future<void> saveLoginResponse(Map<String, dynamic> response) async {
    print('DEBUG saveLoginResponse: response=$response');
    
    // Extract token from various possible keys
    final token = response['token'] ?? 
                  response['access_token'] ?? 
                  response['bearer_token'] ??
                  response['auth_token'];
    
    print('DEBUG saveLoginResponse: extracted token=$token');
    
    if (token != null) {
      await saveToken(token.toString());
      print('DEBUG saveLoginResponse: token saved, verifying...');
      final verified = await getToken();
      print('DEBUG saveLoginResponse: verified token=${verified?.substring(0, 20)}...');
    } else {
      print('DEBUG saveLoginResponse: NO TOKEN FOUND IN RESPONSE');
    }

    // Extract user data if present
    final user = response['user'] ?? response['data'];
    if (user != null && user is Map<String, dynamic>) {
      await saveUser(user);
    }
  }
}
