// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultx_solution/models/update_profile_model.dart';

import 'authenticated_client.dart';
import '../models/sign_up_model.dart';
import '../models/sign_in_model.dart';
import '../models/create_profile_model.dart';
import '../models/update_password_model.dart';
import '../models/vehicle_model.dart';
import '../models/guest_model.dart';
import '../models/residence_model.dart';

class ApiService {
  // 1) our custom HTTP client that injects Authorization header
  final AuthenticatedClient _client = AuthenticatedClient();

  // 2) Base URL switches for Android vs iOS/web
  String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5280/api';
    } else {
      return 'http://10.0.2.2:5280/api';  // ✅ Added /api
    }
  }

  // Add in-memory token storage
  String? _inMemoryToken;

  // Set token in memory
  void setInMemoryToken(String token) {
    _inMemoryToken = token;
    _client.setToken(token);
  }

  // Add this method to debug the token
  void debugToken() {
    _client.debugToken();
  }

  /// ─── SIGN UP (public) ───────────────────────────────────────────
  /// ✅ CHANGED: /auth/signup → /auth/register
  Future<void> signUp(SignUpModel dto) async {
    final uri = Uri.parse('$_baseUrl/auth/register');  // ✅ Changed endpoint

    try {
      debugPrint('Sending signup request to: $uri');
      debugPrint('Request body: ${jsonEncode(dto.toJson())}');

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dto.toJson()),
      );

      debugPrint('Signup response status: ${res.statusCode}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        debugPrint('Signup successful');
        return;
      } else {
        // Try to parse error message from response
        String errorMessage;
        try {
          final errorBody = jsonDecode(res.body);
          errorMessage =
              errorBody['message'] ?? 'Signup failed (${res.statusCode})';
        } catch (_) {
          errorMessage = 'Signup failed (${res.statusCode}): ${res.body}';
        }

        debugPrint('Signup error: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// ─── LOGIN (public) ─────────────────────────────────────────────
  /// ✅ Already correct - no changes needed
  Future<String?> login(SignInModel dto) async {
    final uri = Uri.parse('$_baseUrl/Auth/login');

    debugPrint('Sending login request to: $uri');
    debugPrint('Request body: ${jsonEncode(dto.toJson())}');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    debugPrint('Login response status: ${res.statusCode}');
    debugPrint('Login response body: ${res.body}');

    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;

      // ✅ Extract accessToken (handle both cases)
      String? token;
      if (body.containsKey('accessToken')) {
        token = body['accessToken'] as String?;
      } else if (body.containsKey('AccessToken')) {
        token = body['AccessToken'] as String?;
      }

      if (token == null || token.isEmpty) {
        throw Exception('Token not found in response');
      }

      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);

      // ✅ Save approval status (handle both field names)
      bool isApproved = false;
      if (body.containsKey('isApprovedBySociety')) {
        isApproved = body['isApprovedBySociety'] == true;
      } else if (body.containsKey('IsApprovedBySociety')) {
        isApproved = body['IsApprovedBySociety'] == true;
      }
      
      await prefs.setBool('isApprovedBySociety', isApproved);
      debugPrint('✅ Approval status saved: $isApproved');

      return token;
    } else {
      String errorMessage;
      try {
        final errorBody = jsonDecode(res.body);
        errorMessage = errorBody['message'] ?? 'Login failed (${res.statusCode})';
      } catch (_) {
        errorMessage = 'Login failed (${res.statusCode}): ${res.body}';
      }
      debugPrint('Login error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  /// ─── LOGOUT ─────────────────────────────────────────────────────
  /// ✅ No changes needed
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
    } catch (e) {
      debugPrint('Failed to remove token from SharedPreferences: $e');
    }

    // Always clear the in-memory token
    _inMemoryToken = null;
    _client.clearToken();
  }

  /// ─── PROFILE: GET /Profile/me ───────────────────────────────────
  /// ✅ Already correct - no changes needed
  Future<CreateProfileModel?> getProfile() async {
    final uri = Uri.parse('$_baseUrl/Profile/me');

    debugPrint('Fetching profile from: $uri');
    debugPrint('Token being used: ${await _getTokenForDebug()}');

    final res = await _client.get(uri);

    debugPrint('Get profile response status: ${res.statusCode}');
    debugPrint('Get profile response body: ${res.body}');

    if (res.statusCode == 200) {
      try {
        final jsonBody = jsonDecode(res.body);
        debugPrint('Parsed JSON structure: ${jsonBody.keys.join(", ")}');
        final profileData = CreateProfileModel.fromJson(jsonBody);
        debugPrint('Profile parsed successfully: ${profileData.email}');
        return profileData;
      } catch (e, stackTrace) {
        debugPrint('Error parsing profile: $e');
        debugPrint('Stack trace: $stackTrace');
        rethrow;
      }
    } else if (res.statusCode == 404) {
      debugPrint('No profile found (404) - user needs to create profile');
      return null;
    } else {
      String errorMessage;
      try {
        final errorBody = jsonDecode(res.body);
        errorMessage = errorBody['message'] ?? errorBody['title'] ?? 'Fetch profile failed (${res.statusCode})';
        debugPrint('Error response JSON: $errorBody');
      } catch (_) {
        errorMessage = 'Fetch profile failed (${res.statusCode}): ${res.body}';
      }
      debugPrint('Get profile error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  // Helper method to get token for debugging
  Future<String> _getTokenForDebug() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      return token != null ? '${token.substring(0, 20)}...' : 'No token';
    } catch (_) {
      return 'Error reading token';
    }
  }

  /// ─── PROFILE: POST /Profile/create ──────────────────────────────
  /// ✅ CHANGED: /profile/create → /Profile/create (capitalized)
  Future<void> createProfile(CreateProfileModel dto) async {
    final uri = Uri.parse('$_baseUrl/Profile/create');  // ✅ Capitalized Profile

    debugPrint('About to create profile, checking token:');
    _client.debugToken();

    final requestBody = jsonEncode(dto.toJson());
    debugPrint('Profile create request body: $requestBody');

    try {
      final res = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      debugPrint('Profile create response status: ${res.statusCode}');
      debugPrint('Profile create response body: ${res.body}');

      if (res.statusCode != 200 && res.statusCode != 201) {
        String errorMessage;
        try {
          final errorBody = jsonDecode(res.body);
          errorMessage = errorBody['message'] ??
              'Create profile failed (${res.statusCode})';
        } catch (_) {
          errorMessage =
              'Create profile failed (${res.statusCode}): ${res.body}';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Profile create error: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// ─── PROFILE: PUT /Profile/update ──────────────────────────────
  /// ✅ CHANGED: /profile/update → /Profile/update + PATCH → PUT
  Future<void> updateProfile(UpdateProfileModel dto) async {
    final uri = Uri.parse('$_baseUrl/Profile/update');  // ✅ Capitalized Profile

    debugPrint('About to update profile, checking token:');
    _client.debugToken();

    final requestBody = jsonEncode(dto.toJson());
    debugPrint('Profile update request body: $requestBody');

    try {
      final res = await _client.put(  // ✅ Changed from patch to put
        uri,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      debugPrint('Profile update response status: ${res.statusCode}');
      debugPrint('Profile update response body: ${res.body}');

      if (res.statusCode != 200 && res.statusCode != 204) {  // ✅ Accept 204 No Content
        String errorMessage;
        try {
          final errorBody = jsonDecode(res.body);
          errorMessage = errorBody['message'] ??
              'Update profile failed (${res.statusCode})';
        } catch (_) {
          errorMessage =
              'Update profile failed (${res.statusCode}): ${res.body}';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Profile update error: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// ─── PROFILE: PUT /Profile/password ─────────────────────────────
  /// ✅ CHANGED: /profile/password/update → /Profile/password + POST → PUT
  Future<void> updatePassword(UpdatePasswordModel dto) async {
    final uri = Uri.parse('$_baseUrl/Profile/password');  // ✅ Changed endpoint
    
    final res = await _client.put(  // ✅ Changed from post to put
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );
    
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception(
          'Password update failed (${res.statusCode}): ${res.body}');
    }
  }

  /// ─── VEHICLE: POST /Vehicles ─────────────────────────────────
  /// ✅ CHANGED: /vehicle/add → /Vehicles
  Future<void> addVehicle(VehicleModel dto) async {
    final uri = Uri.parse('$_baseUrl/Vehicles');  // ✅ Changed endpoint

    debugPrint('Adding vehicle: ${jsonEncode(dto.toJson())}');

    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    debugPrint('Add vehicle response: ${res.statusCode}');
    if (res.statusCode != 200 && res.statusCode != 201) {
      debugPrint('Add vehicle error body: ${res.body}');
      throw Exception('Add vehicle failed (${res.statusCode}): ${res.body}');
    }
  }

  /// ─── VEHICLE: GET /Vehicles/user/me ─────────────────────────────────────
  /// ✅ CHANGED: /vehicle → /Vehicles/user/me
  Future<List<VehicleModel>> getVehicles() async {
    final uri = Uri.parse('$_baseUrl/Vehicles');

    debugPrint('Fetching vehicles from: $uri');

    final res = await _client.get(uri);

    debugPrint('Get vehicles response status: ${res.statusCode}');
    debugPrint('Get vehicles response body: ${res.body}');

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      debugPrint('Received ${data.length} vehicles');
      return data.map((json) => VehicleModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch vehicles (${res.statusCode})');
    }
  }

  /// ─── GUEST: POST /Guests ─────────────────────────────────
  /// ✅ CHANGED: /guest/register → /Guests + qrCodeImage → qrCode
  Future<String> registerGuest(AddGuestModel dto) async {
    final uri = Uri.parse('$_baseUrl/Guests');  // ✅ Changed endpoint

    debugPrint('Registering guest: ${jsonEncode(dto.toJson())}');

    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    debugPrint('Register guest response: ${res.statusCode}');
    if (res.statusCode == 200 || res.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(res.body);
      return responseData['qrCode'] ?? '';  // ✅ Changed from qrCodeImage to qrCode
    } else {
      debugPrint('Register guest error body: ${res.body}');
      throw Exception('Register guest failed (${res.statusCode}): ${res.body}');
    }
  }

  /// ─── GUEST: GET /Guests/user/me ─────────────────────────────────────────
  /// ✅ CHANGED: /Guest/guest/mine → /Guests/user/me
  Future<List<GuestModel>> getGuests() async {
    final uri = Uri.parse('$_baseUrl/Guests/user/me');  // ✅ Changed endpoint
    
    final res = await _client.get(uri);

    if (res.statusCode == 200) {
      final List<dynamic> guestsJson = jsonDecode(res.body);
      return guestsJson.map((json) => GuestModel.fromJson(json)).toList();
    } else {
      throw Exception('Fetch guests failed (${res.statusCode}): ${res.body}');
    }
  }

  /// ─── GUEST: POST /Guests/{guestId}/verify ─────────────────────────────────
  /// ✅ CHANGED: /guest/verify → /Guests/{guestId}/verify (RESTful pattern)
  Future<Map<String, dynamic>> verifyGuest(String guestId) async {
    final uri = Uri.parse('$_baseUrl/Guests/$guestId/verify');  // ✅ Changed to RESTful pattern

    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),  // Empty body for verification
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Verify guest failed (${res.statusCode}): ${res.body}');
    }
  }

  /// ─── AUTH: POST /otps/send ────────────────────────────────
  /// ✅ CHANGED: /auth/otp/send → /otps/send
  Future<void> sendOtp(String email) async {
    final uri = Uri.parse('$_baseUrl/otps/send');  // ✅ Changed endpoint
    
    final body = jsonEncode({'email': email});
    debugPrint('Sending OTP request to: $uri');
    debugPrint('Request body: $body');
    
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    
    debugPrint('Send OTP response status: ${res.statusCode}');
    if (res.statusCode == 200 || res.statusCode == 201) {
      debugPrint('OTP sent successfully');
      return;
    } else {
      String errorMessage;
      try {
        final errorBody = jsonDecode(res.body);
        errorMessage =
            errorBody['message'] ?? 'Send OTP failed (${res.statusCode})';
      } catch (_) {
        errorMessage = 'Send OTP failed (${res.statusCode}): ${res.body}';
      }
      throw Exception(errorMessage);
    }
  }

  /// ─── AUTH: POST /otps/verify ───────────────────────────────
  /// ✅ CHANGED: /auth/otp/verify → /otps/verify
  Future<void> verifyOtp(String email, String otp) async {
    final uri = Uri.parse('$_baseUrl/otps/verify');  // ✅ Changed endpoint
    
    final body = jsonEncode({'email': email, 'otp': otp});
    debugPrint('Verifying OTP at: $uri');
    debugPrint('Request body: $body');
    
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    
    debugPrint('Verify OTP response status: ${res.statusCode}');
    if (res.statusCode == 200 || res.statusCode == 201) {
      debugPrint('OTP verified successfully');
      return;
    } else {
      String errorMessage;
      try {
        final errorBody = jsonDecode(res.body);
        errorMessage =
            errorBody['message'] ?? 'Verify OTP failed (${res.statusCode})';
      } catch (_) {
        errorMessage = 'Verify OTP failed (${res.statusCode}): ${res.body}';
      }
      throw Exception(errorMessage);
    }
  }

  /// ─── AUTH: POST /otps/resend ───────────────────────────────
  /// ✅ CHANGED: /auth/resend-otp → /otps/resend
  Future<void> resendOtp(String email) async {
    final uri = Uri.parse('$_baseUrl/otps/resend');  // ✅ Changed endpoint
    
    final body = jsonEncode({'email': email});
    debugPrint('Resending OTP request to: $uri');
    debugPrint('Request body: $body');
    
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    
    debugPrint('Resend OTP response status: ${res.statusCode}');
    if (res.statusCode == 200 || res.statusCode == 201) {
      return;
    } else {
      String errorMessage;
      try {
        final errorBody = jsonDecode(res.body);
        errorMessage =
            errorBody['message'] ?? 'Resend OTP failed (${res.statusCode})';
      } catch (_) {
        errorMessage = 'Resend OTP failed (${res.statusCode}): ${res.body}';
      }
      throw Exception(errorMessage);
    }
  }

  // ─── RESIDENCE MANAGEMENT ───────────────────────────────────────────────

  /// Get all user residences
  Future<List<ResidenceModel>> getResidences() async {
    final uri = Uri.parse('$_baseUrl/Profile/residences');
    
    debugPrint('Fetching residences from: $uri');
    
    final res = await _client.get(uri);
    debugPrint('Get residences response status: ${res.statusCode}');
    
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      debugPrint('Received ${data.length} residences');
      return data.map((json) => ResidenceModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch residences (${res.statusCode})');
    }
  }

  /// Get specific residence details
  Future<ResidenceModel> getResidenceDetails(String residenceId) async {
    final uri = Uri.parse('$_baseUrl/Profile/residences/$residenceId');
    
    final res = await _client.get(uri);
    
    if (res.statusCode == 200) {
      return ResidenceModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to fetch residence details (${res.statusCode})');
    }
  }

  /// Add new residence
  Future<void> addResidence(AddResidenceDto dto) async {
    final uri = Uri.parse('$_baseUrl/Profile/add-residence');
    
    debugPrint('Adding residence: ${dto.toJson()}');
    
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );
    
    if (res.statusCode != 200 && res.statusCode != 201) {
      final error = jsonDecode(res.body)['message'] ?? 'Failed to add residence';
      throw Exception(error);
    }
  }

  /// Set residence as primary
  Future<void> setPrimaryResidence(String residenceId) async {
    final uri = Uri.parse('$_baseUrl/Profile/residences/$residenceId/set-primary');
    
    final res = await _client.patch(uri);
    
    if (res.statusCode != 200) {
      final error = jsonDecode(res.body)['message'] ?? 'Failed to set primary residence';
      throw Exception(error);
    }
  }

  /// Delete residence
  Future<void> deleteResidence(String residenceId) async {
    final uri = Uri.parse('$_baseUrl/Profile/residences/$residenceId');
    
    final res = await _client.delete(uri);
    
    if (res.statusCode != 200) {
      final error = jsonDecode(res.body)['message'] ?? 'Failed to delete residence';
      throw Exception(error);
    }
  }

  /// Get guests by residence
  Future<List<GuestModel>> getGuestsByResidence(String residenceId) async {
    final uri = Uri.parse('$_baseUrl/Guests/residence/$residenceId');
    
    final res = await _client.get(uri);
    
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => GuestModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch guests (${res.statusCode})');
    }
  }

  /// Get vehicles by residence
  Future<List<VehicleModel>> getVehiclesByResidence(String residenceId) async {
    final uri = Uri.parse('$_baseUrl/Vehicles/residence/$residenceId');
    
    final res = await _client.get(uri);
    
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => VehicleModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch vehicles (${res.statusCode})');
    }
  }
}
