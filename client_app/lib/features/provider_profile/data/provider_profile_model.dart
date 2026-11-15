class ServiceInventoryTier {
  final String id;
  final String ticketTierName;
  final int pricePaisa;
  final int totalCapacity;
  final int bookedCapacity;
  final int heldCapacity;
  final String eventDate;

  const ServiceInventoryTier({
    required this.id,
    required this.ticketTierName,
    required this.pricePaisa,
    required this.totalCapacity,
    required this.bookedCapacity,
    required this.heldCapacity,
    required this.eventDate,
  });

  factory ServiceInventoryTier.fromJson(Map<String, dynamic> json) {
    return ServiceInventoryTier(
      id: json['id'] as String,
      ticketTierName: (json['ticket_tier_name'] ?? 'General') as String,
      pricePaisa: (json['price_paisa'] as num?)?.toInt() ?? 0,
      totalCapacity: (json['total_capacity'] as num?)?.toInt() ?? 0,
      bookedCapacity: (json['booked_capacity'] as num?)?.toInt() ?? 0,
      heldCapacity: (json['held_capacity'] as num?)?.toInt() ?? 0,
      eventDate: (json['event_date'] ?? '') as String,
    );
  }

  int get availableCapacity => totalCapacity - bookedCapacity - heldCapacity;

  String get formattedPrice {
    final rupees = pricePaisa / 100;
    return '₹${rupees.toStringAsFixed(rupees.truncateToDouble() == rupees ? 0 : 2)}';
  }
}

class ProviderDetailModel {
  final String id;
  final String businessName;
  final String city;
  final int basePricePaisa;
  final double rating;
  final bool isVerified;
  final String bio;
  final List<ServiceInventoryTier> inventoryTiers;

  const ProviderDetailModel({
    required this.id,
    required this.businessName,
    required this.city,
    required this.basePricePaisa,
    required this.rating,
    required this.isVerified,
    required this.bio,
    this.inventoryTiers = const [],
  });

  factory ProviderDetailModel.fromJson(Map<String, dynamic> json, {List<ServiceInventoryTier> tiers = const []}) {
    return ProviderDetailModel(
      id: json['id'] as String,
      businessName: (json['business_name'] ?? 'Provider Profile') as String,
      city: (json['city'] ?? '') as String,
      basePricePaisa: (json['base_price'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isVerified: (json['is_verified'] as bool?) ?? false,
      bio: (json['bio'] ?? 'Dedicated service provider on HS MUSIC Event Ecosystem.') as String,
      inventoryTiers: tiers,
    );
  }

  String get formattedPrice {
    final rupees = basePricePaisa / 100;
    return '₹${rupees.toStringAsFixed(rupees.truncateToDouble() == rupees ? 0 : 2)}';
  }
}