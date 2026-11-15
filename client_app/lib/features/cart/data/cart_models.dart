class CartItemModel {
  final String providerId;
  final String businessName;
  final String serviceTierId;
  final String tierName;
  final int pricePaisa;

  const CartItemModel({
    required this.providerId,
    required this.businessName,
    required this.serviceTierId,
    required this.tierName,
    required this.pricePaisa,
  });

  String get formattedPrice {
    final rupees = pricePaisa / 100;
    return '₹${rupees.toStringAsFixed(rupees.truncateToDouble() == rupees ? 0 : 2)}';
  }
}

class AuthoritativeQuoteModel {
  final int baseQuotePaisa;
  final int gstPaisa;
  final int platformFeePaisa;
  final int totalAmountPaisa;

  const AuthoritativeQuoteModel({
    required this.baseQuotePaisa,
    required this.gstPaisa,
    required this.platformFeePaisa,
    required this.totalAmountPaisa,
  });

  factory AuthoritativeQuoteModel.fromJson(Map<String, dynamic> json) {
    return AuthoritativeQuoteModel(
      baseQuotePaisa: (json['base_quote_paisa'] as num?)?.toInt() ?? 0,
      gstPaisa: (json['gst_paisa'] as num?)?.toInt() ?? 0,
      platformFeePaisa: (json['platform_fee_paisa'] as num?)?.toInt() ?? 0,
      totalAmountPaisa: (json['total_amount_paisa'] as num?)?.toInt() ?? 0,
    );
  }

  String formatPaisa(int paisa) {
    final rupees = paisa / 100;
    return '₹${rupees.toStringAsFixed(rupees.truncateToDouble() == rupees ? 0 : 2)}';
  }
}