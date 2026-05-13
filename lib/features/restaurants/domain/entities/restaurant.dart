class Restaurant {
  final String name;
  final String address;
  final double rating;
  final String description;
  final List<String> tags;
  final String? imageUrl;
  final String websiteUrl;

  Restaurant({
    required this.name,
    required this.address,
    required this.rating,
    required this.description,
    required this.tags,
    this.imageUrl,
    required this.websiteUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'] as String,
      address: json['address'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.0,
      description: json['description'] as String,
      tags: List<String>.from(json['tags'] as List),
      imageUrl: json['imageUrl'] as String?,
      websiteUrl: json['websiteUrl'] as String? ?? 'https://www.google.com/search?q=${Uri.encodeComponent(json['name'] as String)}',
    );
  }
}
