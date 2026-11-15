enum ScanVerificationResult {
  granted,
  alreadyUsed,
  invalidHash,
}

class GateScanRecord {
  final String ticketHash;
  final String guestName;
  final DateTime scannedAt;
  final ScanVerificationResult result;

  const GateScanRecord({
    required this.ticketHash,
    required this.guestName,
    required this.scannedAt,
    required this.result,
  });
}