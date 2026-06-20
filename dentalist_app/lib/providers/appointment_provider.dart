import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../repositories/appointment_repository.dart';
import 'api_service_provider.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository(ref.read(apiServiceProvider));
});

class AppointmentListState {
  final bool isLoading;
  final List<Appointment> appointments;
  final String? error;

  const AppointmentListState({
    this.isLoading = false,
    this.appointments = const [],
    this.error,
  });

  AppointmentListState copyWith({
    bool? isLoading,
    List<Appointment>? appointments,
    String? error,
  }) {
    return AppointmentListState(
      isLoading: isLoading ?? this.isLoading,
      appointments: appointments ?? this.appointments,
      error: error,
    );
  }
}

final appointmentListProvider = StateNotifierProvider<AppointmentListNotifier, AppointmentListState>((ref) {
  return AppointmentListNotifier(ref.read(appointmentRepositoryProvider));
});

class AppointmentListNotifier extends StateNotifier<AppointmentListState> {
  final AppointmentRepository _repository;

  AppointmentListNotifier(this._repository) : super(const AppointmentListState());

  Future<void> loadAppointments({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    final appointments = await _repository.getAppointments(status: status);
    state = state.copyWith(isLoading: false, appointments: appointments);
  }

  Future<bool> cancelAppointment(int id, {String? reason}) async {
    final success = await _repository.cancelAppointment(id, reason: reason);
    if (success) {
      state = state.copyWith(
        appointments: state.appointments.map((a) {
          if (a.id == id) {
            return Appointment(
              id: a.id,
              patient: a.patient,
              date: a.date,
              time: a.time,
              status: 'cancelled',
            );
          }
          return a;
        }).toList(),
      );
    }
    return success;
  }

  Future<Appointment?> createAppointment(Map<String, dynamic> data) async {
    final appointment = await _repository.createAppointment(data);
    if (appointment != null) {
      state = state.copyWith(
        appointments: [appointment, ...state.appointments],
      );
    }
    return appointment;
  }
}
