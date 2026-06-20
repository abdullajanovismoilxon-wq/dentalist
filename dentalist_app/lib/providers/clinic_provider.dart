import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clinic.dart';
import '../models/clinic_service.dart';
import '../models/gallery_image.dart';
import '../models/working_hours.dart';
import '../repositories/clinic_repository.dart';
import 'api_service_provider.dart';

final clinicRepositoryProvider = Provider<ClinicRepository>((ref) {
  return ClinicRepository(ref.read(apiServiceProvider));
});

class ClinicListState {
  final bool isLoading;
  final List<Clinic> clinics;
  final String? error;
  final String? searchQuery;
  final double? latitude;
  final double? longitude;

  const ClinicListState({
    this.isLoading = false,
    this.clinics = const [],
    this.error,
    this.searchQuery,
    this.latitude,
    this.longitude,
  });

  ClinicListState copyWith({
    bool? isLoading,
    List<Clinic>? clinics,
    String? error,
    String? searchQuery,
    double? latitude,
    double? longitude,
  }) {
    return ClinicListState(
      isLoading: isLoading ?? this.isLoading,
      clinics: clinics ?? this.clinics,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

final clinicListProvider = StateNotifierProvider<ClinicListNotifier, ClinicListState>((ref) {
  return ClinicListNotifier(ref.read(clinicRepositoryProvider));
});

class ClinicListNotifier extends StateNotifier<ClinicListState> {
  final ClinicRepository _repository;

  ClinicListNotifier(this._repository) : super(const ClinicListState());

  Future<void> loadClinics() async {
    state = state.copyWith(isLoading: true, error: null);
    final clinics = await _repository.getClinics(
      search: state.searchQuery,
      latitude: state.latitude,
      longitude: state.longitude,
    );
    state = state.copyWith(isLoading: false, clinics: clinics);
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query.isNotEmpty ? query : null);
    loadClinics();
  }

  void setLocation(double lat, double lng) {
    state = state.copyWith(latitude: lat, longitude: lng);
    loadClinics();
  }
}

final clinicDetailProvider = FutureProvider.family<Clinic?, int>((ref, id) async {
  return ref.read(clinicRepositoryProvider).getClinic(id);
});

final clinicServicesProvider = FutureProvider.family<List<ClinicService>, int>((ref, id) async {
  return ref.read(clinicRepositoryProvider).getServices(id);
});

final clinicGalleryProvider = FutureProvider.family<List<GalleryImage>, int>((ref, id) async {
  return ref.read(clinicRepositoryProvider).getGallery(id);
});

final clinicWorkingHoursProvider = FutureProvider.family<List<WorkingHours>, int>((ref, id) async {
  return ref.read(clinicRepositoryProvider).getWorkingHours(id);
});
