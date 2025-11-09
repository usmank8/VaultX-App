// lib/services/authenticated_client.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// A client that automatically injects `Authorization: Bearer <token>`.
class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  String? _inMemoryToken; // Add in-memory token storage

  AuthenticatedClient([http.Client? inner]) : _inner = inner ?? http.Client();

  // Set token directly in memory
  void setToken(String token) {
    _inMemoryToken = token;
  }

  // Clear token (for logout)
  void clearToken() {
    _inMemoryToken = null;
  }

  // Debug method to print current token
  void debugToken() {
    debugPrint('Current token: $_inMemoryToken');
  }

  Future<String?> _getToken() async {
    // First check in-memory token
    if (_inMemoryToken != null) {
      return _inMemoryToken;
    }

    // Fall back to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      debugPrint(
          'Token from SharedPreferences: ${token != null ? 'Found' : 'Not found'}');
      return token;
    } catch (e) {
      debugPrint('Error accessing SharedPreferences: $e');
      return null;
    }
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _getToken();

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
      debugPrint('Added Authorization header for ${request.url.path}');
    } else {
      debugPrint('No token available for request to ${request.url.path}');
    }

    // Always ensure JSON content-type for POST/PUT requests
    if (request.method == 'POST' || request.method == 'PUT') {
      request.headers['Content-Type'] = 'application/json';
    }

    // Log headers for debugging (without sensitive info)
    debugPrint(
        'Request headers for ${request.url.path}: ${request.headers.keys.join(', ')}');

    return _inner.send(request);
  }

  // Save isApprovedBySocietyAdmin flag to SharedPreferences
  Future<void> setIsApprovedBySocietyAdmin(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isApprovedBySocietyAdmin', value);
    } catch (e) {
      debugPrint('Error saving isApprovedBySocietyAdmin: $e');
    }
  }

  // Get isApprovedBySocietyAdmin flag from SharedPreferences
  Future<bool?> getIsApprovedBySocietyAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isApprovedBySocietyAdmin');
    } catch (e) {
      debugPrint('Error accessing isApprovedBySocietyAdmin: $e');
      return null;
    }
  }

  // Clear isApprovedBySocietyAdmin flag (for logout)
  Future<void> clearIsApprovedBySocietyAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isApprovedBySocietyAdmin');
    } catch (e) {
      debugPrint('Error clearing isApprovedBySocietyAdmin: $e');
    }
  }
}
