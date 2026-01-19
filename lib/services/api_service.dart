// lib/services/api_service.dart
import 'dart:async';
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
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Authenticated client for protected endpoints
  final AuthenticatedClient _client = AuthenticatedClient();
  
  // Simple HTTP client for public endpoints (login, signup, OTP)
  final http.Client _publicClient = http.Client();

  // Base URL
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5280/api';
    } 
    // ✅ Works for BOTH emulator AND physical device (after adb reverse)
    return 'http://localhost:5280/api';
  }

  // In-memory token
  String? _inMemoryToken;

  void setInMemoryToken(String token) {
    _inMemoryToken = token;
    _client.setToken(token);
    debugPrint('✅ Token set in memory');
  }

  void debugToken() {
    _client.debugToken();
  }

  /// ─── SIGN UP (public) ───────────────────────────────────────────
  Future<void> signUp(SignUpModel dto) async {
    final uri = Uri.parse('$_baseUrl/Auth/register');
    debugPrint('📤 Signup request to: $uri');
    debugPrint('📤 Signup body: ${jsonEncode(dto.toJson())}');

    try {
      final res = await _publicClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(dto.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('📥 Signup response status: ${res.statusCode}');
      debugPrint('📥 Signup response body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        sendOtp(dto.email);  // Automatically send OTP after signup
        return;
      } else {
        String errorMessage = 'Signup failed';
        try {
          final errorBody = jsonDecode(res.body);
          errorMessage = errorBody['message'] ?? errorBody['Message'] ?? 'Signup failed (${res.statusCode})';
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      debugPrint('❌ Signup timeout');
      throw Exception('Request timed out. Please check your connection.');
    } on SocketException catch (e) {
      debugPrint('❌ Signup socket error: $e');
      throw Exception('Network error. Please check if the server is running.');
    } catch (e) {
      debugPrint('❌ Signup error: $e');
      rethrow;
    }
  }

  /// ─── LOGIN (public) ─────────────────────────────────────────────
  Future<String?> login(SignInModel dto) async {
    final uri = Uri.parse('$_baseUrl/Auth/login');
    
    debugPrint('📤 Login request to: $uri');
    debugPrint('📤 Login body: ${jsonEncode(dto.toJson())}');

    try {
      final res = await _publicClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(dto.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('📥 Login response status: ${res.statusCode}');
      debugPrint('📥 Login response body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;

        // Extract token (handle different cases)
        String? token = body['accessToken'] ?? 
                        body['AccessToken'] ?? 
                        body['token'] ?? 
                        body['Token'];

        if (token == null || token.isEmpty) {
          debugPrint('❌ Token not found in response: $body');
          throw Exception('Token not found in response');
        }

        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        _inMemoryToken = token;
        _client.setToken(token);

        // Save approval status
        bool isApproved = body['isApprovedBySociety'] == true || 
                          body['IsApprovedBySociety'] == true;
        await prefs.setBool('isApprovedBySociety', isApproved);
        
        debugPrint('✅ Login successful, token saved, approved: $isApproved');
        return token;
      } else if (res.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (res.statusCode == 404) {
        throw Exception('User not found');
      } else {
        String errorMessage = 'Login failed';
        try {
          final errorBody = jsonDecode(res.body);
          errorMessage = errorBody['message'] ?? errorBody['Message'] ?? 'Login failed (${res.statusCode})';
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      debugPrint('❌ Login timeout');
      throw Exception('Request timed out. Please check your connection.');
    } on SocketException catch (e) {
      debugPrint('❌ Login socket error: $e');
      throw Exception('Cannot connect to server. Please check if the server is running.');
    } catch (e) {
      debugPrint('❌ Login error: $e');
      rethrow;
    }
  }

  /// ─── LOGOUT ─────────────────────────────────────────────────────
  Future<void> logout() async {
    _inMemoryToken = null;
    _client.clearToken();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      await prefs.remove('isApprovedBySociety');
      await prefs.remove('selected_residence_id');
      debugPrint('✅ Logged out');
    } catch (e) {
      debugPrint('Failed to clear preferences: $e');
    }
  }

  /// ─── OTP: SEND ────────────────────────────────────────────────
  Future<void> sendOtp(String email) async {
    final uri = Uri.parse('$_baseUrl/Auth/send-otp');
    debugPrint('📤 SendOtp request to: $uri');
    debugPrint('📥 SendOtp to email: $email');

    try {
      final res = await _publicClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('📥 SendOtp response: ${res.statusCode}');

      if (res.statusCode != 200 && res.statusCode != 201) {
        String errorMessage = 'Failed to send OTP';
        try {
          final errorBody = jsonDecode(res.body);
          errorMessage = errorBody['message'] ?? errorBody['Message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      debugPrint('❌ SendOtp error: $e');
      rethrow;
    }
  }

  /// ─── OTP: VERIFY ───────────────────────────────────────────────
  Future<void> verifyOtp(String email, String otp) async {
    final uri = Uri.parse('$_baseUrl/Auth/verify-otp');
    debugPrint('📤 VerifyOtp request to: $uri');

    try {
      final res = await _publicClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'otp': otp,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('📥 VerifyOtp response: ${res.statusCode}');

      if (res.statusCode != 200 && res.statusCode != 201) {
        String errorMessage = 'Invalid OTP';
        try {
          final errorBody = jsonDecode(res.body);
          errorMessage = errorBody['message'] ?? errorBody['Message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      debugPrint('❌ VerifyOtp error: $e');
      rethrow;
    }
  }

  /// ─── OTP: RESEND ───────────────────────────────────────────────
  Future<void> resendOtp(String email) async {
    // Resend uses the same endpoint as send
    await sendOtp(email);
  }

  /// ─── PROFILE: GET /Profile/me ───────────────────────────────────
  Future<CreateProfileModel?> getProfile() async {
    final uri = Uri.parse('$_baseUrl/Profile/me');
    debugPrint('📤 GetProfile request to: $uri');

    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 30));
      debugPrint('📥 GetProfile response: ${res.statusCode}');
      debugPrint('📥 GetProfile body: ${res.body}');

      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        return CreateProfileModel.fromJson(jsonBody);
      } else if (res.statusCode == 404) {
        debugPrint('ℹ️ No profile found');
        return null;
      } else if (res.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        throw Exception('Failed to fetch profile (${res.statusCode})');
      }
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      debugPrint('❌ GetProfile error: $e');
      rethrow;
    }
  }

  /// ─── PROFILE: POST /Profile/create ──────────────────────────────
  Future<void> createProfile(CreateProfileModel dto) async {
    final uri = Uri.parse('$_baseUrl/Profile/create');
    debugPrint('📤 CreateProfile request to: $uri');
    debugPrint('📤 CreateProfile body: ${jsonEncode(dto.toJson())}');

    try {
      final res = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(dto.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('📥 CreateProfile response: ${res.statusCode}');
      debugPrint('📥 CreateProfile body: ${res.body}');

      if (res.statusCode != 200 && res.statusCode != 201) {
        String errorMessage = 'Failed to create profile';
        try {
          final errorBody = jsonDecode(res.body);
          errorMessage = errorBody['message'] ?? errorBody['Message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      debugPrint('❌ CreateProfile error: $e');
      rethrow;
    }
  }

  /// ─── PROFILE: PUT /Profile/update ──────────────────────────────
  Future<void> updateProfile(UpdateProfileModel dto) async {
    final uri = Uri.parse('$_baseUrl/Profile/update');

    try {
      final res = await _client
          .patch(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(dto.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception('Update profile failed (${res.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ UpdateProfile error: $e');
      rethrow;
    }
  }

  /// ─── PROFILE: PUT /Profile/password/update ─────────────────────────────
  Future<void> updatePassword(UpdatePasswordModel dto) async {
    final uri = Uri.parse('$_baseUrl/Profile/password/update');
    
    final res = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(dto.toJson()),
        )
        .timeout(const Duration(seconds: 30));
    
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Password update failed (${res.statusCode})');
    }
  }

  /// ─── VEHICLE: POST /Vehicles ─────────────────────────────────
  Future<void> addVehicle(VehicleModel dto) async {
    final uri = Uri.parse('$_baseUrl/Vehicles');

    final res = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(dto.toJson()),
        )
        .timeout(const Duration(seconds: 30));

    if (res.statusCode != 200 && res.statusCode != 201) {
      String errorMessage = 'Failed to add vehicle';
      try {
        final errorBody = jsonDecode(res.body);
        errorMessage = errorBody['message'] ?? errorBody['Message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  /// ─── VEHICLE: GET /Vehicles ─────────────────────────────────────
  Future<List<VehicleModel>> getVehicles() async {
    final uri = Uri.parse('$_baseUrl/Vehicles');
    debugPrint('📤 GetVehicles request to: $uri');

    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 30));
      debugPrint('📥 GetVehicles response: ${res.statusCode}');

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((json) => VehicleModel.fromJson(json)).toList();
      } else if (res.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to fetch vehicles (${res.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ GetVehicles error: $e');
      rethrow;
    }
  }

  /// ─── GUEST: POST /Guests/register ─────────────────────────────────
  Future<String> registerGuest(AddGuestModel dto) async {
    final uri = Uri.parse('$_baseUrl/Guests/register');

    final res = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(dto.toJson()),
        )
        .timeout(const Duration(seconds: 30));

    if (res.statusCode == 200 || res.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(res.body);
      return responseData['qrCode'] ?? '';
    } else {
      String errorMessage = 'Failed to register guest';
      try {
        final errorBody = jsonDecode(res.body);
        errorMessage = errorBody['message'] ?? errorBody['Message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  /// ─── GUEST: GET /Guests/my-guests ─────────────────────────────────
  Future<List<GuestModel>> getGuests() async {
    final uri = Uri.parse('$_baseUrl/Guests/my-guests');
    debugPrint('📤 GetGuests request to: $uri');

    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 30));
      debugPrint('📥 GetGuests response: ${res.statusCode}');

      if (res.statusCode == 200) {
        // API returns a wrapped object with guests array inside
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        final List<dynamic> guestsJson = responseData['guests'] as List<dynamic>? ?? [];
        return guestsJson.map((json) => GuestModel.fromJson(json)).toList();
      } else if (res.statusCode == 404) {
        return [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('❌ GetGuests error: $e');
      return [];
    }
  }

  /// ─── GUEST: POST /Guests/{guestId}/verify ─────────────────────
  Future<Map<String, dynamic>> verifyGuest(String guestId) async {
    final uri = Uri.parse('$_baseUrl/Guests/$guestId/verify');

    final res = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({}),
        )
        .timeout(const Duration(seconds: 30));

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Verify guest failed (${res.statusCode})');
    }
  }

  // ─── RESIDENCE MANAGEMENT ───────────────────────────────────────────────

  /// Get all user residences
  Future<List<ResidenceModel>> getResidences() async {
    final uri = Uri.parse('$_baseUrl/Profile/residences');
    debugPrint('📤 GetResidences request to: $uri');

    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 30));
      debugPrint('📥 GetResidences response: ${res.statusCode}');

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((json) => ResidenceModel.fromJson(json)).toList();
      } else if (res.statusCode == 404) {
        return [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('❌ GetResidences error: $e');
      return [];
    }
  }

  /// Get specific residence details
  Future<ResidenceModel> getResidenceDetails(String residenceId) async {
    final uri = Uri.parse('$_baseUrl/Profile/residences/$residenceId');
    
    final res = await _client.get(uri).timeout(const Duration(seconds: 30));
    
    if (res.statusCode == 200) {
      return ResidenceModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to fetch residence details (${res.statusCode})');
    }
  }

  /// Add new residence
  Future<void> addResidence(AddResidenceDto dto) async {
    final uri = Uri.parse('$_baseUrl/Profile/add-residence');
    
    final res = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(dto.toJson()),
        )
        .timeout(const Duration(seconds: 30));
    
    if (res.statusCode != 200 && res.statusCode != 201) {
      final error = jsonDecode(res.body)['message'] ?? 'Failed to add residence';
      throw Exception(error);
    }
  }

  /// Add secondary residence
  Future<void> addSecondaryResidence(AddSecondaryResidenceDto dto) async {
    final uri = Uri.parse('$_baseUrl/Residences');
    debugPrint('📤 AddSecondaryResidence request to: $uri');
    debugPrint('📤 AddSecondaryResidence body: ${jsonEncode(dto.toJson())}');
    
    final res = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(dto.toJson()),
        )
        .timeout(const Duration(seconds: 30));
    
    debugPrint('📥 AddSecondaryResidence response status: ${res.statusCode}');
    debugPrint('📥 AddSecondaryResidence response body: ${res.body}');
    
    if (res.statusCode != 200 && res.statusCode != 201) {
      String errorMessage = 'Failed to add secondary residence';
      try {
        final errorBody = jsonDecode(res.body);
        errorMessage = errorBody['message'] ?? errorBody['Message'] ?? 'Failed to add secondary residence (${res.statusCode})';
      } catch (_) {
        errorMessage = 'Failed to add secondary residence (${res.statusCode}): ${res.body}';
      }
      throw Exception(errorMessage);
    }
  }

  /// Set residence as primary
  Future<void> setPrimaryResidence(String residenceId) async {
    final uri = Uri.parse('$_baseUrl/Profile/residences/$residenceId/set-primary');
    
    final res = await _client.patch(uri).timeout(const Duration(seconds: 30));
    
    if (res.statusCode != 200) {
      final error = jsonDecode(res.body)['message'] ?? 'Failed to set primary residence';
      throw Exception(error);
    }
  }

  /// Delete residence
  Future<void> deleteResidence(String residenceId) async {
    final uri = Uri.parse('$_baseUrl/Profile/residences/$residenceId');
    
    final res = await _client.delete(uri).timeout(const Duration(seconds: 30));
    
    if (res.statusCode != 200) {
      final error = jsonDecode(res.body)['message'] ?? 'Failed to delete residence';
      throw Exception(error);
    }
  }

  /// Get guests by residence
  Future<List<GuestModel>> getGuestsByResidence(String residenceId) async {
    final uri = Uri.parse('$_baseUrl/Guests/residence/$residenceId');
    
    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 30));
      
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((json) => GuestModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('❌ GetGuestsByResidence error: $e');
      return [];
    }
  }

  /// Get vehicles by residence
  Future<List<VehicleModel>> getVehiclesByResidence(String residenceId) async {
    final uri = Uri.parse('$_baseUrl/Vehicles/residence/$residenceId');
    
    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 30));
      
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((json) => VehicleModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('❌ GetVehiclesByResidence error: $e');
      return [];
    }
  }
}
