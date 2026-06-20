import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doctor.dart';
import '../models/specialization.dart';
import '../repositories/doctor_repository.dart';
import 'api_service_provider.dart';

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository(ref.read(apiServiceProvider));
});

class DoctorListState {
  final bool isLoading;
  final List<Doctor> doctors;
  final String? error;
  final int? selectedSpecialization;
  final String? searchQuery;
  final Map<String, dynamic> filterParams;

  const DoctorListState({
    this.isLoading = false,
    this.doctors = const [],
    this.error,
    this.selectedSpecialization,
    this.searchQuery,
    this.filterParams = const {},
  });

  DoctorListState copyWith({
    bool? isLoading,
    List<Doctor>? doctors,
    String? error,
    int? selectedSpecialization,
    String? searchQuery,
    Map<String, dynamic>? filterParams,
  }) {
    return DoctorListState(
      isLoading: isLoading ?? this.isLoading,
      doctors: doctors ?? this.doctors,
      error: error,
      selectedSpecialization: selectedSpecialization,
      searchQuery: searchQuery ?? this.searchQuery,
      filterParams: filterParams ?? this.filterParams,
    );
  }
}

final doctorListProvider = StateNotifierProvider<DoctorListNotifier, DoctorListState>((ref) {
  return DoctorListNotifier(ref.read(doctorRepositoryProvider));
});

class DoctorListNotifier extends StateNotifier<DoctorListState> {
  final DoctorRepository _repository;

  DoctorListNotifier(this._repository) : super(const DoctorListState());

  Future<void> loadDoctors() async {
    state = state.copyWith(isLoading: true, error: null);
    final doctors = await _repository.getDoctors(
      specialization: state.selectedSpecialization,
      search: state.searchQuery,
      gender: state.filterParams['gender'] as String?,
      patientType: state.filterParams['patient_type'] as String?,
      is24_7: state.filterParams['is_24_7'] as bool?,
      ordering: state.filterParams['ordering'] as String?,
      latitude: state.filterParams['latitude'] as double?,
      longitude: state.filterParams['longitude'] as double?,
    );
    state = state.copyWith(isLoading: false, doctors: doctors);
  }

  void setFilter(Map<String, dynamic> params) {
    state = state.copyWith(filterParams: params);
    loadDoctors();
  }

  void setSpecialization(int? id) {
    state = state.copyWith(selectedSpecialization: id);
    loadDoctors();
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query.isNotEmpty ? query : null);
    loadDoctors();
  }
}

final specializationsProvider = FutureProvider<List<Specialization>>((ref) async {
  return ref.read(doctorRepositoryProvider).getSpecializations();
});

final doctorDetailProvider = FutureProvider.family<Doctor?, int>((ref, id) async {
  return ref.read(doctorRepositoryProvider).getDoctor(id);
});
