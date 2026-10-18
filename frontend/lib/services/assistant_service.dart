import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/synthetic_samples.dart';
import 'fraud_service.dart';

class AssistantResponse {
  final String query;
  final String answer;
  final bool isSecurityTopic;
  final List<String> suggestedFollowups;
  final String source;

  const AssistantResponse({
    required this.query,
    required this.answer,
    required this.isSecurityTopic,
    required this.suggestedFollowups,
    required this.source,
  });

  factory AssistantResponse.fromJson(Map<String, dynamic> json, String defaultQuery) {
    return AssistantResponse(
      query: json['query'] ?? defaultQuery,
      answer: json['answer'] ?? 'I have reviewed your security inquiry.',
      isSecurityTopic: json['is_security_topic'] ?? true,
      suggestedFollowups: (json['suggested_followups'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      source: json['source'] ?? 'api',
    );
  }
}

class AssistantService {
  static const String _defaultApiUrl = 'http://127.0.0.1:8000/api/v1/assistant/chat';

  /// Collect active alerts caught in the app to feed into assistant context
  static List<String> getActiveAlertsContext() {
    final alerts = <String>[];

    // 1. Synthetic sample alerts from dashboard
    for (final sample in SyntheticSamples.samples) {
      if (sample.category.toLowerCase().contains('high') ||
          sample.category.toLowerCase().contains('critical') ||
          sample.category.toLowerCase().contains('phishing') ||
          sample.category.toLowerCase().contains('reversal')) {
        alerts.add('${sample.title}: ${sample.text}');
      }
    }

    // 2. Recent session scan history
    for (final scan in FraudService.history.take(3)) {
      alerts.add('Recent Scan [${scan.riskBand.displayName}]: ${scan.summary}');
    }

    return alerts;
  }

  /// Send inquiry to the backend Gemini AI Assistant with fallback
  static Future<AssistantResponse> ask({
    required String query,
    String? customApiUrl,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      throw ArgumentError('Inquiry cannot be empty.');
    }

    final contextAlerts = getActiveAlertsContext();
    final candidateUrls = [
      customApiUrl ?? _defaultApiUrl,
      'http://localhost:8000/api/v1/assistant/chat',
    ];

    for (final endpoint in candidateUrls) {
      try {
        final url = Uri.parse(endpoint);
        final response = await http
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'query': trimmedQuery,
                'context_alerts': contextAlerts,
              }),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return AssistantResponse.fromJson(data, trimmedQuery);
        }
      } catch (_) {
        // Try next loopback address before offline fallback
      }
    }

    return _localOfflineAnswer(trimmedQuery);
  }

  /// Offline local intelligence fallback adhering to topic guardrails
  static AssistantResponse _localOfflineAnswer(String query) {
    final lower = query.toLowerCase();

    // Guardrail: Off-topic rejection
    final offTopicWords = [
      'weather', 'recipe', 'cook', 'bake', 'poem', 'song', 'joke', 'football',
      'premier league', 'chelsea', 'arsenal', 'manchester', 'coding', 'python',
      'javascript', 'math', 'president',
    ];

    for (final word in offTopicWords) {
      if (lower.contains(word) && !lower.contains('fraud') && !lower.contains('scam') && !lower.contains('alert')) {
        return AssistantResponse(
          query: query,
          answer:
              "I am Munda Fraud Shield's AI Security Specialist. I am strictly specialized in mobile financial fraud prevention, scam analysis, and explaining security alerts in Zambia. How can I assist you with your transaction or message safety?",
          isSecurityTopic: false,
          suggestedFollowups: const [
            'Tell me more about the Money alert',
            'How does the fake reversal scam work?',
            'Why should I never share my OTP?',
          ],
          source: 'guardrail_fallback',
        );
      }
    }

    // 1. Explaining the Money alert / Airtel MoMo alert / Fake reversal
    if (lower.contains('money alert') || lower.contains('airtel') || lower.contains('reversal') || lower.contains('refund')) {
      return AssistantResponse(
        query: query,
        answer:
            "The Money Alert flags a notorious fake Mobile Money reversal scam in Zambia. A scammer sends an SMS mimicking a legitimate payment (e.g. K850 sent to you by mistake), then calls or texts aggressively threatening police arrest unless you 'refund' them immediately. In reality, no money entered your account. Always verify your real balance directly on USSD (*115# for Airtel or *303# for MTN). Never send funds back directly.",
        isSecurityTopic: true,
        suggestedFollowups: const [
          'What if the caller threatens me with police?',
          'How do legitimate bank reversals work?',
        ],
        source: 'local_engine',
      );
    }

    // 2. OTP / PIN theft alert
    if (lower.contains('otp') || lower.contains('pin') || lower.contains('code') || lower.contains('password')) {
      return AssistantResponse(
        query: query,
        answer:
            "The OTP/PIN Theft Alert warns against messages requesting authentication codes. Fraudsters impersonate bank staff or telecom customer service claiming to fix an account suspension or upgrade your SIM. Legitimate institutions like ZANACO, ABSA, Airtel, or MTN will NEVER ask for your PIN or OTP.",
        isSecurityTopic: true,
        suggestedFollowups: const [
          'What if I already disclosed my PIN?',
          'How does SIM-swap fraud happen?',
        ],
        source: 'local_engine',
      );
    }

    // 3. Bank suspension / Phishing links (ZANACO, ABSA)
    if (lower.contains('zanaco') || lower.contains('suspension') || lower.contains('block') || lower.contains('link')) {
      return AssistantResponse(
        query: query,
        answer:
            "The Urgent Suspension Alert flags phishing messages that threaten immediate account closure unless you click a link. Clicking takes you to a fraudulent website designed to steal your bank login credentials. Always access your bank using official apps or verified helplines.",
        isSecurityTopic: true,
        suggestedFollowups: const [
          'How do I spot fake bank URLs?',
          'Open SMS Scam Scanner',
        ],
        source: 'local_engine',
      );
    }

    // Default Security Guidance
    return AssistantResponse(
      query: query,
      answer:
          "Munda AI Fraud Shield actively inspects SMS messages for coercive urgency, fake transaction receipts, and unverified sender links. You can paste any suspicious SMS into the Scanner tab for an immediate risk assessment.",
      isSecurityTopic: true,
      suggestedFollowups: const [
        'Tell me more about the Money alert',
        'How do I report fraud to ZICTA (7070)?',
      ],
      source: 'local_engine',
    );
  }
}
