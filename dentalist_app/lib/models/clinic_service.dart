class ClinicService {
  final int id;
  final String name;
  final String? nameRu;
  final String? description;
  final double price;
  final int? duration;
  final int? clinic;

  ClinicService({
    required this.id,
    required this.name,
    this.nameRu,
    this.description,
    required this.price,
    this.duration,
    this.clinic,
  });

  factory ClinicService.fromJson(Map<String, dynamic> json) {
    return ClinicService(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameRu: json['name_ru'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      duration: json['duration'],
      clinic: json['clinic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ru': nameRu,
      'description': description,
      'price': price,
      'duration': duration,
      'clinic': clinic,
    };
  }
}
