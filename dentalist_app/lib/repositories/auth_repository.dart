import '../models/user.dart';
import '../models/doctor.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../core/constants.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<User?> login(String phone, String password) {
    return _authService.login(phone, password);
  }

  Future<User?> register({
    required String phone,
    required String password,
    String? firstName,
    String? lastName,
  }) {
    return _authService.register(
      phone: phone,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
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
  }) {
    return _authService.registerDoctor(
      phone: phone,
      password: password,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      experienceYears: experienceYears,
      clinicName: clinicName,
      patientType: patientType,
      specializations: specializations,
      clinicAddress: clinicAddress,
    );
  }

  Future<User?> getProfile() {
    return _authService.getProfile();
  }

  Future<User?> updateProfile(Map<String, dynamic> data) {
    return _authService.updateProfile(data);
  }

  Future<bool> uploadAvatar(String filePath) {
    return _authService.uploadAvatar(filePath);
  }

  Future<bool> deleteAvatar() {
    return _authService.deleteAvatar();
  }

  Future<void> logout() {
    return _authService.logout();
  }

  Future<bool> isLoggedIn() {
    return _authService.isLoggedIn();
  }

  User? get currentUser => _authService.currentUser;
  String? get lastError => _authService.lastError;
}

class FavoriteRepository {
  final ApiService _api;

  FavoriteRepository(this._api);

  Future<List<Doctor>> getFavorites() async {
    try {
      final response = await _api.get(ApiConstants.favorites);
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) {
        final item = e is Map<String, dynamic> ? e : <String, dynamic>{};
        // Backend returns FavoriteSerializer with doctor_detail nested
        if (item.containsKey('doctor_detail') && item['doctor_detail'] != null) {
          return Doctor.fromJson(item['doctor_detail']);
        }
        // Fallback: try parsing the whole object as Doctor
        return Doctor.fromJson(item);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addFavorite(int doctorId) async {
    try {
      await _api.post('${ApiConstants.favorites}add/', data: {'doctor': doctorId});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavorite(int doctorId) async {
    try {
      await _api.delete('${ApiConstants.favorites}remove/$doctorId/');
      return true;
    } catch (e) {
      return false;
    }
  }
}
