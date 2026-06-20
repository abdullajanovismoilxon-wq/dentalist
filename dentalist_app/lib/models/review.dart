class Review {
  final int id;
  final int? doctor;
  final int? user;
  final String? userName;
  final double rating;
  final String? comment;
  final DateTime? createdAt;

  Review({
    required this.id,
    this.doctor,
    this.user,
    this.userName,
    this.rating = 0,
    this.comment,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      doctor: json['doctor'],
      user: json['user'],
      userName: json['user_name'] ?? json['user__full_name'],
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
