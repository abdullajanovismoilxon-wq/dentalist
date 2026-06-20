import 'doctor.dart';
import 'clinic.dart';
import 'specialization.dart';

class SearchResults {
  final List<Doctor> doctors;
  final List<Clinic> clinics;
  final List<Specialization> specializations;

  SearchResults({
    required this.doctors,
    required this.clinics,
    this.specializations = const [],
  });

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    return SearchResults(
      doctors: (json['doctors'] as List?)?.map((e) => Doctor.fromJson(e)).toList() ?? [],
      clinics: (json['clinics'] as List?)?.map((e) => Clinic.fromJson(e)).toList() ?? [],
      specializations: (json['specializations'] as List?)?.map((e) => Specialization.fromJson(e)).toList() ?? [],
    );
  }
}
