class Clinic {
  final int id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String? phone;
  final bool? is247;
  final String? image;
  final double? latitude;
  final double? longitude;
  final String? formattedAddress;
  final double? rating;
  final int? reviewCount;
  final int? doctorsCount;
  final Map<String, dynamic>? ratingBreakdown;
  final List<dynamic> gallery;
  final double? distanceKm;
  final String? workStart;
  final String? workEnd;
  final bool isActive;

  Clinic({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.phone,
    this.is247,
    this.image,
    this.latitude,
    this.longitude,
    this.formattedAddress,
    this.rating,
    this.reviewCount,
    this.doctorsCount,
    this.ratingBreakdown,
    this.gallery = const [],
    this.distanceKm,
    this.workStart,
    this.workEnd,
    this.isActive = true,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      address: json['address'],
      city: json['city'],
      phone: json['phone'],
      is247: json['is_24_7'] ?? json['is_open_24_7'],
      image: json['image'] ?? json['avatar'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      formattedAddress: json['formatted_address'],
      rating: (json['avg_rating'] ?? json['rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'],
      doctorsCount: json['doctors_count'],
      ratingBreakdown: json['rating_breakdown'],
      gallery: json['gallery'] ?? [],
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      isActive: json['is_active'] ?? true,
    );
  }

  List<String> get galleryImages {
    return gallery.map((e) {
      if (e is String) return e;
      if (e is Map) return e['image']?.toString() ?? '';
      return '';
    }).where((s) => s.isNotEmpty).toList();
  }
}
