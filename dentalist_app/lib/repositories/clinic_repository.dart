import '../models/clinic.dart';
import '../models/clinic_service.dart';
import '../models/gallery_image.dart';
import '../models/working_hours.dart';
import '../models/review.dart';
import '../services/api_service.dart';
import '../core/constants.dart';

class ClinicRepository {
  final ApiService _api;

  ClinicRepository(this._api);

  Future<List<Clinic>> getClinics({
    String? search,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (search != null) params['search'] = search;
      if (latitude != null) params['latitude'] = latitude;
      if (longitude != null) params['longitude'] = longitude;
      if (radiusKm != null) params['radius_km'] = radiusKm;

      final response = await _api.get(ApiConstants.clinics, queryParameters: params);
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => Clinic.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Clinic?> getClinic(int id) async {
    try {
      final response = await _api.get('${ApiConstants.clinics}$id/');
      return Clinic.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  // ── Services ──
  Future<List<ClinicService>> getServices(int clinicId) async {
    try {
      final response = await _api.get('${ApiConstants.clinics}$clinicId/services/');
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => ClinicService.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addService(int clinicId, Map<String, dynamic> data) async {
    try {
      await _api.post('${ApiConstants.clinics}$clinicId/services/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateService(int clinicId, int serviceId, Map<String, dynamic> data) async {
    try {
      await _api.patch('${ApiConstants.clinics}$clinicId/services/$serviceId/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteService(int clinicId, int serviceId) async {
    try {
      await _api.delete('${ApiConstants.clinics}$clinicId/services/$serviceId/');
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Gallery ──
  Future<List<GalleryImage>> getGallery(int clinicId) async {
    try {
      final response = await _api.get('${ApiConstants.clinics}$clinicId/gallery/');
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => GalleryImage.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> uploadGalleryImage(int clinicId, String filePath) async {
    try {
      await _api.uploadFile(
        '${ApiConstants.clinics}$clinicId/gallery/upload/',
        filePath: filePath,
        fieldName: 'image',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteGalleryImage(int imageId) async {
    try {
      await _api.delete('${ApiConstants.clinics}gallery/$imageId/delete/');
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Avatar ──
  Future<bool> uploadAvatar(int clinicId, String filePath) async {
    try {
      await _api.uploadFile(
        '${ApiConstants.clinics}$clinicId/avatar/',
        filePath: filePath,
        fieldName: 'file',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAvatar(int clinicId) async {
    try {
      await _api.delete('${ApiConstants.clinics}$clinicId/avatar/');
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Working Hours ──
  Future<List<WorkingHours>> getWorkingHours(int clinicId) async {
    try {
      final response = await _api.get('${ApiConstants.clinics}$clinicId/working-hours/');
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => WorkingHours.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateWorkingHours(int clinicId, Map<String, dynamic> data) async {
    try {
      await _api.post('${ApiConstants.clinics}$clinicId/working-hours/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Reviews ──
  Future<List<Review>> getReviews(int clinicId) async {
    try {
      final response = await _api.get('${ApiConstants.clinics}$clinicId/reviews/');
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => Review.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> checkReview(int clinicId) async {
    try {
      final response = await _api.get('${ApiConstants.clinics}$clinicId/reviews/check/');
      return response.data is Map ? response.data as Map<String, dynamic> : null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> createReview(int clinicId, Map<String, dynamic> data) async {
    try {
      await _api.post('${ApiConstants.clinics}$clinicId/reviews/create/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateReview(int clinicId, Map<String, dynamic> data) async {
    try {
      await _api.put('${ApiConstants.clinics}$clinicId/reviews/update/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }
}
