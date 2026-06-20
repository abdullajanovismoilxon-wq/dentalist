import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../core/constants.dart';
import '../models/user.dart';

class AuthService {
  final ApiService _api = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  User? _currentUser;
  String? _lastError;

  User? get currentUser => _currentUser;
  String? get lastError => _lastError;

  AuthService() {
    debugPrint('[AuthService] API_BASE_URL=${ApiConstants.baseUrl}');
  }

  String _extractError(dynamic data) {
    if (data == null) return 'Serverdan javob olinmadi';
    debugPrint('[AuthService] _extractError RAW: $data');
    if (data is String) return data;
    if (data is Map) {
      if (data['detail'] != null) return data['detail'].toString();
      if (data['non_field_errors'] != null) {
        final v = data['non_field_errors'];
        return (v is List) ? v.join(', ') : v.toString();
      }
      final buf = StringBuffer();
      for (final entry in data.entries) {
        final key = entry.key;
        final val = entry.value;
        final label = {
          'phone': 'Telefon',
          'password': 'Parol',
          'password2': 'Parolni tasdiqlash',
          'first_name': 'Ism',
          'last_name': 'Familiya',
          'gender': 'Jins',
          'clinic_name': 'Klinika nomi',
          'experience_years': 'Tajriba',
        }[key] ?? key;
        final msg = (val is List) ? val.join(', ') : val.toString();
        buf.write('$label: $msg\n');
      }
      return buf.toString().trim();
    }
    return data.toString();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    debugPrint('[AuthService] isLoggedIn: token=${token != null} token_length=${token?.length}');
    return token != null;
  }

  Future<User?> login(String phone, String password) async {
    try {
      debugPrint('[AuthService] login: phone=$phone');
      final response = await _api.post(
        ApiConstants.login,
        data: {'phone': phone, 'password': password},
      );

      debugPrint('[AuthService] login response: status=${response.statusCode}');
      debugPrint('[AuthService] login response data: ${response.data}');

      if (response.statusCode == 200) {
        final accessToken = response.data['access'] as String?;
        final refreshToken = response.data['refresh'] as String?;
        debugPrint('[AuthService] access_token: ${accessToken?.substring(0, 20)}...');
        debugPrint('[AuthService] refresh_token: ${refreshToken?.substring(0, 20)}...');

        if (accessToken == null || refreshToken == null) {
          debugPrint('[AuthService] ERROR: Tokens missing from response!');
          return null;
        }

        await _storage.write(key: AppConstants.tokenKey, value: accessToken);
        await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);

        final userData = response.data['user'] ?? response.data;
        _currentUser = User.fromJson(userData);
        debugPrint('[AuthService] user: ${_currentUser?.phone} id=${_currentUser?.id}');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userKey, _currentUser!.phone);
        debugPrint('[AuthService] login SUCCESS');
        return _currentUser;
      }
      _lastError = _extractError(response.data);
      debugPrint('[AuthService] login FAILED: status=${response.statusCode} body=${response.data}');
      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        _lastError = 'Server bilan bog\'lanib bo\'lmadi. Internet yoki serverni tekshiring.';
      } else if (e.type == DioExceptionType.connectionError) {
        _lastError = 'Server topilmadi. API manzilini tekshiring: ${ApiConstants.baseUrl}';
      } else if (e.response != null) {
        _lastError = _extractError(e.response?.data);
      } else {
        _lastError = 'Tarmoq xatoligi: ${e.message}';
      }
      debugPrint('[AuthService] login ERROR type=${e.type} message=${e.message} response=${e.response?.data}');
      return null;
    } catch (e) {
      _lastError = 'Kutilmagan xatolik: $e';
      debugPrint('[AuthService] login ERROR: $e');
      return null;
    }
  }

  Future<User?> register({
    required String phone,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.register,
        data: {
          'phone': phone,
          'password': password,
          'password2': password,
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      if (response.statusCode == 201) {
        final accessToken = response.data['access'] as String?;
        final refreshToken = response.data['refresh'] as String?;
        await _storage.write(key: AppConstants.tokenKey, value: accessToken);
        await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);

        final userData = response.data['user'] ?? response.data;
        _currentUser = User.fromJson(userData);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userKey, _currentUser!.phone);
        debugPrint('[AuthService] register SUCCESS');
        return _currentUser;
      }
      _lastError = _extractError(response.data);
      debugPrint('[AuthService] register FAILED: status=${response.statusCode} body=${response.data}');
      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        _lastError = 'Server bilan bog\'lanib bo\'lmadi. Internet yoki serverni tekshiring.';
      } else if (e.type == DioExceptionType.connectionError) {
        _lastError = 'Server topilmadi. API manzilini tekshiring: ${ApiConstants.baseUrl}';
      } else if (e.response != null) {
        _lastError = _extractError(e.response?.data);
      } else {
        _lastError = 'Tarmoq xatoligi: ${e.message}';
      }
      debugPrint('[AuthService] register ERROR type=${e.type} message=${e.message} response=${e.response?.data}');
      return null;
    } catch (e) {
      _lastError = 'Kutilmagan xatolik: $e';
      debugPrint('[AuthService] register ERROR: $e');
      return null;
    }
  }

  Future<User?> registerDoctor({
    required String phone,
    required String password,
    String? firstName,
    String? lastName,
    String? gender,
    int? experienceYears,
    String? clinicName,
    String? patientType,
    List<String>? specializations,
    String? clinicAddress,
  }) async {
    try {
      final data = <String, dynamic>{
        'phone': phone,
        'password': password,
        'password2': password,
        'first_name': firstName ?? '',
        'last_name': lastName ?? '',
        'gender': gender ?? 'male',
        'experience_years': experienceYears ?? 0,
        'clinic_name': clinicName ?? 'Klinika',
        'patient_type': patientType ?? 'both',
        'specializations': specializations ?? [],
        'clinic_address': clinicAddress ?? '',
      };
      final response = await _api.post(ApiConstants.registerDoctor, data: data);

      if (response.statusCode == 201) {
        final accessToken = response.data['access'] as String?;
        final refreshToken = response.data['refresh'] as String?;
        await _storage.write(key: AppConstants.tokenKey, value: accessToken);
        await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);

        final userData = response.data['user'] ?? response.data;
        _currentUser = User.fromJson(userData);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userKey, _currentUser!.phone);
        debugPrint('[AuthService] registerDoctor SUCCESS');
        return _currentUser;
      }
      _lastError = _extractError(response.data);
      debugPrint('[AuthService] registerDoctor FAILED: status=${response.statusCode} body=${response.data}');
      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        _lastError = 'Server bilan bog\'lanib bo\'lmadi. Internet yoki serverni tekshiring.';
      } else if (e.type == DioExceptionType.connectionError) {
        _lastError = 'Server topilmadi. API manzilini tekshiring: ${ApiConstants.baseUrl}';
      } else if (e.response != null) {
        _lastError = _extractError(e.response?.data);
      } else {
        _lastError = 'Tarmoq xatoligi: ${e.message}';
      }
      debugPrint('[AuthService] registerDoctor ERROR type=${e.type} message=${e.message} response=${e.response?.data}');
      return null;
    } catch (e) {
      _lastError = 'Kutilmagan xatolik: $e';
      debugPrint('[AuthService] registerDoctor ERROR: $e');
      return null;
    }
  }

  Future<User?> getProfile() async {
    try {
      final response = await _api.get(ApiConstants.profile);
      debugPrint('[AuthService] getProfile: status=${response.statusCode}');
      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.data);
        debugPrint('[AuthService] getProfile: user=${_currentUser?.phone}');
        return _currentUser;
      }
      return null;
    } catch (e) {
      debugPrint('[AuthService] getProfile ERROR: $e');
      return null;
    }
  }

  Future<User?> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _api.patch(ApiConstants.profile, data: data);
      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.data);
        return _currentUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> uploadAvatar(String filePath) async {
    try {
      await _api.uploadFile(ApiConstants.profile, filePath: filePath, fieldName: 'avatar');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAvatar() async {
    try {
      await _api.patch(ApiConstants.profile, data: {'avatar': null});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userKey);
    debugPrint('[AuthService] logout: tokens cleared');
  }
}
