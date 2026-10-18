import 'package:flutter/material.dart';

enum RiskBand {
  high,
  suspicious,
  low;

  String get displayName {
    switch (this) {
      case RiskBand.high:
        return 'High Risk';
      case RiskBand.suspicious:
        return 'Suspicious';
      case RiskBand.low:
        return 'Low Concern';
    }
  }

  Color get color {
    switch (this) {
      case RiskBand.high:
        return const Color(0xFFDC2626); // Crimson
      case RiskBand.suspicious:
        return const Color(0xFFD97706); // Amber
      case RiskBand.low:
        return const Color(0xFF0D9488); // Teal/Emerald
    }
  }

  Color get backgroundColor {
    switch (this) {
      case RiskBand.high:
        return const Color(0xFFFEF2F2);
      case RiskBand.suspicious:
        return const Color(0xFFFFFBEB);
      case RiskBand.low:
        return const Color(0xFFF0FDF4);
    }
  }

  IconData get icon {
    switch (this) {
      case RiskBand.high:
        return Icons.gpp_bad_rounded;
      case RiskBand.suspicious:
        return Icons.warning_amber_rounded;
      case RiskBand.low:
        return Icons.verified_user_outlined;
    }
  }
}

class AnalysisResult {
  final bool success;
  final RiskBand riskBand;
  final int riskScore;
  final String summary;
  final List<String> reasons;
  final List<String> recommendedActions;
  final String analysisMethod;
  final String disclaimer;
  final String originalMessage;
  final DateTime analyzedAt;
  final bool piiRedacted;
  final int redactedCount;
  final List<String> detectedPiiTypes;

  AnalysisResult({
    required this.success,
    required this.riskBand,
    required this.riskScore,
    required this.summary,
    required this.reasons,
    required this.recommendedActions,
    required this.analysisMethod,
    required this.disclaimer,
    required this.originalMessage,
    this.piiRedacted = false,
    this.redactedCount = 0,
    this.detectedPiiTypes = const [],
    DateTime? analyzedAt,
  }) : analyzedAt = analyzedAt ?? DateTime.now();

  factory AnalysisResult.fromJson(Map<String, dynamic> json, String originalMessage) {
    RiskBand band;
    final bandStr = (json['risk_band'] ?? 'suspicious').toString().toLowerCase();
    if (bandStr.contains('high')) {
      band = RiskBand.high;
    } else if (bandStr.contains('low')) {
      band = RiskBand.low;
    } else {
      band = RiskBand.suspicious;
    }

    final privacy = json['privacy_protection'] as Map<String, dynamic>?;
    final piiRedacted = privacy?['pii_redacted'] == true;
    final redactedCount = (privacy?['redacted_elements_count'] is num)
        ? (privacy!['redacted_elements_count'] as num).toInt()
        : 0;
    final piiTypes = (privacy?['detected_types'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return AnalysisResult(
      success: json['success'] ?? true,
      riskBand: band,
      riskScore: (json['risk_score'] is num) ? (json['risk_score'] as num).toInt() : 50,
      summary: json['summary'] ?? 'Message analysis completed.',
      reasons: (json['reasons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      recommendedActions: (json['recommended_actions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      analysisMethod: json['analysis_method'] ?? 'rules_and_ai',
      disclaimer: json['disclaimer'] ??
          'This is an indicative assessment, not a guarantee. Low Concern does not verify message legitimacy.',
      originalMessage: originalMessage,
      piiRedacted: piiRedacted,
      redactedCount: redactedCount,
      detectedPiiTypes: piiTypes,
      analyzedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'risk_band': riskBand.name,
      'risk_score': riskScore,
      'summary': summary,
      'reasons': reasons,
      'recommended_actions': recommendedActions,
      'analysis_method': analysisMethod,
      'disclaimer': disclaimer,
      'original_message': originalMessage,
      'pii_redacted': piiRedacted,
      'redacted_count': redactedCount,
      'detected_pii_types': detectedPiiTypes,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }
}
