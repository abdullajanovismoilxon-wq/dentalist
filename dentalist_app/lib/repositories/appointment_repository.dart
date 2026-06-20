import '../models/appointment.dart';
import '../models/slot.dart';
import '../models/working_hours.dart';
import '../services/api_service.dart';
import '../core/constants.dart';

class AppointmentRepository {
  final ApiService _api;

  AppointmentRepository(this._api);

  Future<List<Appointment>> getAppointments({String? status}) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status;
      final response = await _api.get(ApiConstants.appointments, queryParameters: params);
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => Appointment.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Appointment?> getAppointment(int id) async {
    try {
      final response = await _api.get('${ApiConstants.appointments}$id/');
      return Appointment.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<Appointment?> createAppointment(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(ApiConstants.appointments, data: data);
      if (response.statusCode == 201) {
        return Appointment.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> cancelAppointment(int id, {String? reason}) async {
    try {
      await _api.patch(
        '${ApiConstants.appointments}$id/',
        data: {'status': 'cancelled', 'cancel_reason': reason},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Slot>> getDoctorSlots(int doctorId, DateTime date) async {
    try {
      final response = await _api.get(
        '${ApiConstants.doctors}$doctorId/slots/',
        queryParameters: {'date': date.toIso8601String().split('T')[0]},
      );
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => Slot.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createSlot(Map<String, dynamic> data) async {
    try {
      await _api.post('${ApiConstants.appointments}slots/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSlot(int id) async {
    try {
      await _api.delete('${ApiConstants.appointments}slots/$id/');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<WorkingHours>> getSchedule() async {
    try {
      final response = await _api.get('${ApiConstants.appointments}schedule/');
      final data = response.data;
      final results = data['results'] ?? data ?? [];
      return (results as List).map((e) => WorkingHours.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateSchedule(List<Map<String, dynamic>> data) async {
    try {
      await _api.post('${ApiConstants.appointments}schedule/', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }
}
