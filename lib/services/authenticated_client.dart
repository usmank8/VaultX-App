// lib/services/authenticated_client.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Simplified authenticated HTTP client
/// Automatically adds Authorization header to all requests
class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  String? _token;

  /// Set token directly in memory
  void setToken(String token) {
    _token = token;
    debugPrint('✅ Token set in AuthenticatedClient');
  }

  /// Clear token
  void clearToken() {
    _token = null;
    debugPrint('✅ Token cleared from AuthenticatedClient');
  }

  /// Debug token
  void debugToken() {
    if (_token != null && _token!.isNotEmpty) {
      final displayLength = _token!.length > 30 ? 30 : _token!.length;
      debugPrint('🔑 Token (first $displayLength chars): ${_token!.substring(0, displayLength)}...');
    } else {
      debugPrint('🔑 No token in memory');
    }
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Get token from memory or SharedPreferences
    String? token = _token;
    
    if (token == null || token.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('jwt_token');
        if (token != null && token.isNotEmpty) {
          _token = token; // Cache it
          debugPrint('🔑 Token loaded from SharedPreferences');
        }
      } catch (e) {
        debugPrint('❌ Error reading token: $e');
      }
    }

    // Add Authorization header if token exists
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add Content-Type if not already set
    if (!request.headers.containsKey('Content-Type')) {
      request.headers['Content-Type'] = 'application/json';
    }
    request.headers['Accept'] = 'application/json';

    debugPrint('🌐 ${request.method} ${request.url}');

    return _inner.send(request);
  }
}

String get baseUrl {
  // In a real app, you might want to use different URLs for different environments
  // For example, using `kReleaseMode` to check if the app is in release mode
  // and returning the appropriate URL.
  return 'http://localhost:5280/api';
}
