class AppConstants {
  // Supabase Core Project Connection
  static const String supabaseUrl = "https://gqasrmffidjshfububgz.supabase.co";
  static const String supabasePublishableKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdxYXNybWZmaWRqc2hmdWJ1Ymd6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyNTQ5NzQsImV4cCI6MjA1NjgzMDk3NH0.G7jS7Zp8-L78tUfQJgT6v71gP-1p9l-1q-7tUfQJgT6";

  // App Store & Play Store US Reviewer Attestation Bypass (STEP_23 Sec 5)
  static const String reviewerTestPhone = "+919999999999";
  static const String reviewerTestOtp = "123456";

  // Nodal Escrow Dispute Window
  static const Duration disputeWindow = Duration(hours: 48);
}