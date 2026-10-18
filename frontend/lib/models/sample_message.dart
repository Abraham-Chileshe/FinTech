import 'analysis_result.dart';

class SampleMessage {
  final String id;
  final String title;
  final String sender;
  final String text;
  final RiskBand expectedRisk;
  final String category; // e.g., "Mobile Money Scam", "Bank Impersonation", "Legitimate Receipt", "OTP Phishing"
  final String notes;

  const SampleMessage({
    required this.id,
    required this.title,
    required this.sender,
    required this.text,
    required this.expectedRisk,
    required this.category,
    required this.notes,
  });
}
