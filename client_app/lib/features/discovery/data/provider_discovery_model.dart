class ProviderDiscoveryModel {
  final String id;
  final String businessName;
  final String city;
  final int basePricePaisa;
  final double rating;
  final double? distanceMeters;
  final bool isVerified;

  const ProviderDiscoveryModel({
    required this.id,
    required this.businessName,
    required this.city,
    required this.basePricePaisa,
    required this.rating,
    this.distanceMeters,
    required this.isVerified,
  });

  factory ProviderDiscoveryModel.fromJson(Map<String, dynamic> json) {
    return ProviderDiscoveryModel(
      id: json['id'] as String,
      businessName: (json['business_name'] ?? 'Unknown Provider') as String,
      city: (json['city'] ?? '') as String,
      basePricePaisa: (json['base_price'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
      isVerified: (json['is_verified'] as bool?) ?? false,
    );
  }

  String get formattedPrice {
    final rupees = basePricePaisa / 100;
    return '₹${rupees.toStringAsFixed(rupees.truncateToDouble() == rupees ? 0 : 2)}';
  }

  String get formattedDistance {
    if (distanceMeters == null) return 'Distance unavailable';
    if (distanceMeters! < 100) return 'Nearby';
    if (distanceMeters! < 1000) return '${distanceMeters!.round()} m away';
    return '${(distanceMeters! / 1000).toStringAsFixed(1)} km away';
  }
}