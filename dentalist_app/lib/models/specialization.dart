class Specialization {
  final int id;
  final String name;
  final String? nameRu;
  final String? description;

  Specialization({
    required this.id,
    required this.name,
    this.nameRu,
    this.description,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameRu: json['name_ru'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ru': nameRu,
      'description': description,
    };
  }
}
