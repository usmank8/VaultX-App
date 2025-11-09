import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vaultx_solution/models/notification_model.dart';
import 'package:vaultx_solution/services/authenticated_client.dart';

class NotificationService {
  final AuthenticatedClient _client = AuthenticatedClient();
  final String _baseUrl = 'YOUR_API_BASE_URL'; // Replace with your actual API base URL

  // Get all notifications
  Future<List<NotificationModel>> getNotifications({bool unreadOnly = false}) async {
    try {
      final endpoint = unreadOnly 
          ? '/notifications?isRead=false' 
          : '/notifications';
      
      final response = await _client.get(Uri.parse('$_baseUrl$endpoint'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      // Return empty list on error for graceful handling
      return [];
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _client.patch(
        Uri.parse('$_baseUrl/notifications/$notificationId/read'),
        body: json.encode({'isRead': true}),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _client.patch(
        Uri.parse('$_baseUrl/notifications/read-all'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return false;
    }
  }
}
