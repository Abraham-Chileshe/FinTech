import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';

class FraudService {
  static const String _defaultApiUrl = 'http://127.0.0.1:8000/api/v1/analyze-sms';
  static final List<AnalysisResult> _sessionHistory = [];

  static List<AnalysisResult> get history => List.unmodifiable(_sessionHistory);

  static void clearHistory() {
    _sessionHistory.clear();
  }

  static Future<AnalysisResult> analyzeMessage({
    required String message,
    String? customBaseUrl,
    bool demoMode = false,
  }) async {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      throw ArgumentError('Message cannot be empty.');
    }

    final url = Uri.parse(customBaseUrl ?? _defaultApiUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final body = jsonEncode({
      'message': trimmedMessage,
      'locale': 'en-ZM',
      'demo_mode': demoMode,
    });

    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final result = AnalysisResult.fromJson(data, trimmedMessage);
        _sessionHistory.insert(0, result);
        return result;
      } else {
        // If the server returns 422 or 500, fallback to local deterministic rule assessment
        final localResult = _localDeterministicAssessment(
          trimmedMessage,
          note: 'Server returned HTTP ${response.statusCode}. Evaluated using offline rules.',
        );
        _sessionHistory.insert(0, localResult);
        return localResult;
      }
    } on TimeoutException {
      final localResult = _localDeterministicAssessment(
        trimmedMessage,
        note: 'Backend connection timed out. Fallback to offline rule engine applied.',
      );
      _sessionHistory.insert(0, localResult);
      return localResult;
    } catch (e) {
      // Backend not yet running or network error -> use local deterministic rules
      final localResult = _localDeterministicAssessment(
        trimmedMessage,
        note: 'Backend unavailable. Analyzed using local deterministic rules engine.',
      );
      _sessionHistory.insert(0, localResult);
      return localResult;
    }
  }

  /// Client-side deterministic assessment mirroring Layer A rules
  static AnalysisResult _localDeterministicAssessment(String text, {required String note}) {
    final lower = text.toLowerCase();
    final reasons = <String>[];
    final actions = <String>[];
    int score = 15; // baseline low concern

    // 1. PIN / OTP / Password solicitation
    final asksForPin = lower.contains('pin') ||
        lower.contains('otp') ||
        lower.contains('password') ||
        lower.contains('verification code') ||
        lower.contains('secret code');

    final isGivingAdvice = lower.contains('never ask') ||
        lower.contains('never share') ||
        lower.contains('do not share') ||
        lower.contains('keep it secret');

    if (asksForPin && !isGivingAdvice) {
      score += 55;
      reasons.add('Solicits or references confidential authentication credentials (PIN/OTP/Password).');
      actions.add('NEVER disclose your PIN, password, or OTP to anyone, even bank staff.');
    }

    // 2. High urgency / account blocking threats
    final hasUrgency = lower.contains('blocked') ||
        lower.contains('suspended') ||
        lower.contains('restricted') ||
        lower.contains('immediately') ||
        lower.contains('within 24 hours') ||
        lower.contains('police') ||
        lower.contains('urgent action');

    if (hasUrgency) {
      score += 25;
      reasons.add('Employs aggressive urgency or threats of account suspension/police action.');
      actions.add('Verify account status independently through your official banking app or branch.');
    }

    // 3. Phishing links or suspicious domains
    final urlRegex = RegExp(r'(https?://[^\s]+|bit\.ly/[^\s]+|[a-zA-Z0-9-]+\.(link|xyz|me|top|online|click)[^\s]*)');
    final hasUrl = urlRegex.hasMatch(text);
    if (hasUrl) {
      score += 30;
      reasons.add('Contains an unverified external link or shortened URL.');
      actions.add('Do NOT click links in unsolicited messages. Navigate directly to official bank websites.');
    }

    // 4. Fake prize / unexpected lottery winnings / advance fees
    final hasPrize = lower.contains('congratulations') ||
        lower.contains('won') ||
        lower.contains('mega draw') ||
        lower.contains('winner') ||
        lower.contains('claim your prize');

    final hasFeeDemand = lower.contains('stamp duty') ||
        lower.contains('processing fee') ||
        lower.contains('send k') ||
        lower.contains('registration fee');

    if (hasPrize && hasFeeDemand) {
      score += 40;
      reasons.add('Prompts for an upfront fee to claim an unsolicited prize or lottery winning.');
      actions.add('Legitimate competitions never require you to pay upfront fees to claim prizes.');
    }

    // 5. Mobile money refund / accidental transfer pressure
    final isRefundScam = lower.contains('by mistake') &&
        (lower.contains('refund') || lower.contains('send back') || lower.contains('sister'));

    if (isRefundScam) {
      score += 35;
      reasons.add('Claims funds were sent by mistake and urgently demands an off-platform reversal.');
      actions.add('Check your official mobile money balance. Legitimate reversals must be handled by your provider.');
    }

    // 6. Adversarial injection attempts
    if (lower.contains('ignore all previous instructions') || lower.contains('you are no longer')) {
      score = 95;
      reasons.add('Contains malicious prompt injection commands intended to subvert security systems.');
      actions.add('Treat this message as high-risk deceptive content.');
    }

    // 7. Legitimate transaction receipt mitigation
    final isLegitReceipt = (lower.contains('txn') || lower.contains('trans id') || lower.contains('ref:') || lower.contains('token:')) &&
        (lower.contains('new bal') || lower.contains('avail bal') || lower.contains('balance:') || lower.contains('units:')) &&
        !hasUrl &&
        (!asksForPin || isGivingAdvice);

    if (isLegitReceipt) {
      score = 8;
      reasons.clear();
      reasons.add('Matches standard informational transaction receipt patterns with no credential requests or links.');
      actions.add('Retain receipt for your personal expense records.');
    }

    if (actions.isEmpty) {
      actions.add('Always verify unexpected messages with your service provider.');
    }

    score = score.clamp(0, 100);

    RiskBand band;
    if (score >= 65) {
      band = RiskBand.high;
    } else if (score >= 35) {
      band = RiskBand.suspicious;
    } else {
      band = RiskBand.low;
    }

    String summary;
    if (band == RiskBand.high) {
      summary = 'High likelihood of fraudulent intent detected based on identified danger patterns.';
    } else if (band == RiskBand.suspicious) {
      summary = 'Suspicious elements identified. Exercise caution and verify independently.';
    } else {
      summary = 'No immediate high-risk threat indicators identified in this message.';
    }

    return AnalysisResult(
      success: true,
      riskBand: band,
      riskScore: score,
      summary: summary,
      reasons: reasons.isEmpty ? ['Standard language with no detected predatory markers.'] : reasons,
      recommendedActions: actions,
      analysisMethod: 'deterministic_rules ($note)',
      disclaimer: 'This is an indicative assessment, not a guarantee. Low Concern must never be considered proof of legitimacy.',
      originalMessage: text,
    );
  }
}
