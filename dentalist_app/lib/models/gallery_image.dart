class GalleryImage {
  final int? id;
  final String image;
  final String? caption;
  final int? clinic;

  GalleryImage({
    this.id,
    required this.image,
    this.caption,
    this.clinic,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id'],
      image: json['image'] ?? '',
      caption: json['caption'],
      clinic: json['clinic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'caption': caption,
      'clinic': clinic,
    };
  }
}
