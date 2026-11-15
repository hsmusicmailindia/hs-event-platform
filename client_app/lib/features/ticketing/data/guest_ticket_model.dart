class GuestTicketModel {
  final String id;
  final String bookingId;
  final String guestName;
  final String phone;
  final String qrPayloadHash;
  final bool isVoided;
  final DateTime createdAt;

  const GuestTicketModel({
    required this.id,
    required this.bookingId,
    required this.guestName,
    required this.phone,
    required this.qrPayloadHash,
    required this.isVoided,
    required this.createdAt,
  });

  factory GuestTicketModel.fromJson(Map<String, dynamic> json) {
    return GuestTicketModel(
      id: json['id'] as String,
      bookingId: (json['booking_id'] ?? '') as String,
      guestName: (json['guest_name'] ?? 'Attendee') as String,
      phone: (json['phone'] ?? '') as String,
      qrPayloadHash: (json['qr_payload_hash'] ?? '') as String,
      isVoided: (json['is_voided'] as bool?) ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }
}