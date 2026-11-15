class ProviderModel {
  final String id;
  final String businessName;
  final String? category;
  final String? city;
  final int basePricePaisa;
  final double rating;
  final int reviewCount;
  final String? heroImageUrl;
  final String? bio;

  const ProviderModel({
    required this.id,
    required this.businessName,
    this.category,
    this.city,
    required this.basePricePaisa,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.heroImageUrl,
    this.bio,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] as String,
      businessName: json['business_name'] as String? ?? 'Verified Provider',
      category: json['category'] as String? ?? 'Entertainment',
      city: json['city'] as String? ?? 'Prayagraj',
      basePricePaisa: (json['base_price'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      heroImageUrl: json['hero_image_url'] as String?,
      bio: json['bio'] as String?,
    );
  }

  String get formattedPrice {
    final rupees = (basePricePaisa / 100).toStringAsFixed(0);
    return 'Starts at ₹$rupees';
  }
}