import '../models/doctor.dart';
import '../models/specialization.dart';
import '../models/doctor_schedule.dart';
import '../models/blocked_slot.dart';
import '../models/review.dart';
import '../services/api_service.dart';
import '../core/constants.dart';

class DoctorRepository {
  final ApiService _api;

  DoctorRepository(this._api);

  Future<List<Doctor>> getDoctors({
    int? specialization,
    String? search,
    double? minRating,
    String? gender,
    String? patientType,
    bool? is24_7,
    String? ordering,
    double? latitude,
    double? longitude,
    Map<String, String>? extraParams,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (specialization != null) params['specialization'] = specialization;
      if (search != null) params['search'] = search;
      if (minRating != null) params['min_rating'] = minRating;
      if (gender != null) params['gender'] = gender;
      if (patientType != null) params['patient_type'] = patientType;
      if (is24_7 == true) params['is_24_7'] = 'true';
      if (ordering != null) params['ordering'] = ordering;
      if (latitude != null) params['latitude'] = latitude;
      if (longitude != null) params['longitude'] = longitude;
      if (extraParams != null) params.addAll(extraParams);

      final response = await _api.get(ApiConstants.doctors, queryParameters: params);
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => Doctor.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Doctor>> getNearbyDoctors({double? latitude, double? longitude, double? radiusKm}) async {
    try {
      final params = <String, dynamic>{};
      if (latitude != null) params['latitude'] = latitude;
      if (longitude != null) params['longitude'] = longitude;
      if (radiusKm != null) params['radius_km'] = radiusKm;
      final response = await _api.get(ApiConstants.doctorNearby, queryParameters: params);
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => Doctor.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Doctor?> getDoctor(int id) async {
    try {
      final response = await _api.get('${ApiConstants.doctors}$id/');
      return Doctor.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<List<Specialization>> getSpecializations() async {
    try {
      final response = await _api.get(ApiConstants.specializations);
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => Specialization.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      await _api.patch('${ApiConstants.doctors}profile/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadImage(String filePath) async {
    try {
      await _api.uploadFile('${ApiConstants.doctors}profile/', filePath: filePath, fieldName: 'image');
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Dashboard ──
  Future<Map<String, dynamic>?> getDashboard() async {
    try {
      final response = await _api.get(ApiConstants.doctorDashboard);
      return response.data is Map ? response.data as Map<String, dynamic> : null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDoctorProfile() async {
    try {
      final response = await _api.get(ApiConstants.doctorProfile);
      return response.data is Map ? response.data as Map<String, dynamic> : null;
    } catch (e) {
      return null;
    }
  }

  // ── Doctor Schedule ──
  Future<List<DoctorSchedule>> getSchedule() async {
    try {
      final response = await _api.get(ApiConstants.doctorSchedule);
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => DoctorSchedule.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createSchedule(Map<String, dynamic> data) async {
    try {
      await _api.post(ApiConstants.doctorSchedule, data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSchedule(int id, Map<String, dynamic> data) async {
    try {
      await _api.patch('${ApiConstants.doctorSchedule}$id/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSchedule(int id) async {
    try {
      await _api.delete('${ApiConstants.doctorSchedule}$id/');
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Doctor Services ──
  Future<List<dynamic>> getServices() async {
    try {
      final response = await _api.get(ApiConstants.doctorServices);
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return results is List ? results : [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createService(Map<String, dynamic> data) async {
    try {
      await _api.post(ApiConstants.doctorServices, data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateService(int id, Map<String, dynamic> data) async {
    try {
      await _api.patch('${ApiConstants.doctorServices}$id/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteService(int id) async {
    try {
      await _api.delete('${ApiConstants.doctorServices}$id/');
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Slots ──
  Future<List<dynamic>> getSlots({String? date}) async {
    try {
      final params = <String, dynamic>{};
      if (date != null) params['date'] = date;
      final response = await _api.get(ApiConstants.doctorSlots, queryParameters: params);
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return results is List ? results : [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createSlot(Map<String, dynamic> data) async {
    try {
      await _api.post(ApiConstants.doctorSlots, data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSlot(int id) async {
    try {
      await _api.delete('${ApiConstants.doctorSlots}$id/');
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Blocked Slots ──
  Future<List<BlockedSlot>> getBlockedSlots() async {
    try {
      final response = await _api.get(ApiConstants.doctorBlockedSlots);
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => BlockedSlot.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // ── Reviews (for doctor detail page) ──
  Future<List<Review>> getReviews(int doctorId) async {
    try {
      final response = await _api.get('${ApiConstants.reviewsBase}doctor/$doctorId/');
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => Review.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // ── Upload clinic image (doctor dashboard) ──
  Future<bool> uploadClinicImage(String filePath) async {
    try {
      await _api.uploadFile(ApiConstants.doctorUploadClinicImage, filePath: filePath, fieldName: 'image');
      return true;
    } catch (e) {
      return false;
    }
  }
}
