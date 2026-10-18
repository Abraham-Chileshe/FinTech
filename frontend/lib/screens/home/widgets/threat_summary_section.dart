import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/synthetic_samples.dart';
import '../../../models/sample_message.dart';
import '../../../theme/app_theme.dart';
import '../../history_screen.dart';

class ThreatSummarySection extends StatelessWidget {
  final bool isDark;
  final ValueChanged<SampleMessage> onSelectSample;

  const ThreatSummarySection({
    super.key,
    required this.isDark,
    required this.onSelectSample,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Threat Intelligence & Incidents',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
              child: Text(
                'View Log',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.absaCoral,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Absa Threat Alert Card: High Risk Incident
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF19121A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2E1C28) : const Color(0xFFE9E0E6),
              width: 1,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                final sample = SyntheticSamples.samples[2]; // OTP theft
                onSelectSample(sample);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: AppTheme.absaCoral,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Critical Alert: OTP Code Theft Detected',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppTheme.textDark,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Fake SMS & phone call impersonating bank verification',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: isDark ? const Color(0xFFA694A0) : AppTheme.textDarkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? const Color(0xFF8E7D8A) : AppTheme.textDarkSubtle,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Live Security Protection Metrics Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF140F16) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF261522) : const Color(0xFFE9E0E6),
              width: 1,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                title: 'SMS Scanned',
                value: '1 280',
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
              Container(
                width: 1,
                height: 32,
                color: isDark ? const Color(0xFF2B1826) : const Color(0xFFEAE2E8),
              ),
              _buildMetricItem(
                title: 'Threats Blocked',
                value: '14',
                color: AppTheme.absaCoral,
              ),
              Container(
                width: 1,
                height: 32,
                color: isDark ? const Color(0xFF2B1826) : const Color(0xFFEAE2E8),
              ),
              _buildMetricItem(
                title: 'SIM Shield',
                value: '100% OK',
                color: const Color(0xFF00C853),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w400,
            color: isDark ? const Color(0xFFA694A0) : AppTheme.textDarkMuted,
          ),
        ),
      ],
    );
  }
}
