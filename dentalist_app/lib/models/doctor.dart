import 'specialization.dart';

class Doctor {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? image;
  final String? description;
  final int? experience;
  final String? category;
  final double? rating;
  final int? reviewCount;
  final int? clinic;
  final String? clinicName;
  final String? clinicAddress;
  final List<Specialization> specializations;
  final bool isActive;
  final String? workStart;
  final String? workEnd;
  final String? gender;
  final String? patientType;
  final double? consultationPrice;
  final double? distanceKm;
  final double? clinicLatitude;
  final double? clinicLongitude;
  final Map<String, Map<String, dynamic>>? ratingBreakdown;

  Doctor({
    required this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.image,
    this.description,
    this.experience,
    this.category,
    this.rating,
    this.reviewCount,
    this.clinic,
    this.clinicName,
    this.clinicAddress,
    this.specializations = const [],
    this.isActive = true,
    this.workStart,
    this.workEnd,
    this.gender,
    this.patientType,
    this.consultationPrice,
    this.distanceKm,
    this.clinicLatitude,
    this.clinicLongitude,
    this.ratingBreakdown,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    List<Specialization> specs = [];
    if (json['specializations'] != null) {
      if (json['specializations'] is List) {
        specs = (json['specializations'] as List).map((e) => Specialization.fromJson(e)).toList();
      } else if (json['specializations'] is Map) {
        specs = [Specialization.fromJson(json['specializations'])];
      }
    } else if (json['specialization'] != null) {
      if (json['specialization'] is Map) {
        specs = [Specialization.fromJson(json['specialization'])];
      }
    }

    String? firstName = json['first_name'];
    String? lastName = json['last_name'];
    if (firstName == null && json['full_name'] != null) {
      final parts = json['full_name'].toString().split(' ');
      firstName = parts.isNotEmpty ? parts[0] : null;
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;
    }
    if (firstName == null && json['user'] is Map) {
      firstName = json['user']['first_name'];
      lastName = json['user']['last_name'];
    }

    double? price;
    if (json['consultation_price'] != null) {
      price = double.tryParse(json['consultation_price'].toString());
    }

    return Doctor(
      id: json['id'] ?? 0,
      firstName: firstName,
      lastName: lastName,
      phone: json['phone'] ?? json['user']?['phone'],
      image: json['image'],
      description: json['description'] ?? json['bio'],
      experience: json['experience_years'] ?? json['experience'],
      category: json['category'],
      rating: (json['avg_rating'] ?? json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      clinic: json['clinic'],
      clinicName: json['clinic_name'],
      clinicAddress: json['clinic_address'],
      specializations: specs,
      isActive: json['is_active'] ?? true,
      workStart: json['work_start'],
      workEnd: json['work_end'],
      gender: json['gender'],
      patientType: json['patient_type'],
      consultationPrice: price,
      distanceKm: json['distance_km'] != null ? double.tryParse(json['distance_km'].toString()) : null,
      clinicLatitude: json['clinic_latitude'] != null ? double.tryParse(json['clinic_latitude'].toString()) ?? (json['clinic']?['latitude'] != null ? double.tryParse(json['clinic']['latitude'].toString()) : null) : null,
      clinicLongitude: json['clinic_longitude'] != null ? double.tryParse(json['clinic_longitude'].toString()) ?? (json['clinic']?['longitude'] != null ? double.tryParse(json['clinic']['longitude'].toString()) : null) : null,
      ratingBreakdown: json['rating_breakdown'] is Map ? (json['rating_breakdown'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{})).cast<String, Map<String, dynamic>>() : null,
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? 'Shifokor';
  }

  String get specializationLabel {
    if (specializations.isNotEmpty) {
      return specializations.map((s) => s.nameRu ?? s.name).join(', ');
    }
    return '';
  }

  bool get isFemale => gender == 'female';

  bool get acceptsChildren => patientType == 'children' || patientType == 'both';

  bool get acceptsAdults => patientType == 'adults' || patientType == 'both' || patientType == null;

  bool get acceptsElderly => patientType == 'elderly' || patientType == 'both';
}
