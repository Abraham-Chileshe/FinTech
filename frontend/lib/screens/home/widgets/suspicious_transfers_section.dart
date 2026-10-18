import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/synthetic_samples.dart';
import '../../../models/sample_message.dart';
import '../../../theme/app_theme.dart';
import '../../analyzer_screen.dart';

class SuspiciousTransfersSection extends StatelessWidget {
  final bool isDark;
  final ValueChanged<SampleMessage> onSelectSample;

  const SuspiciousTransfersSection({
    super.key,
    required this.isDark,
    required this.onSelectSample,
  });

  @override
  Widget build(BuildContext context) {
    final threatSamples = [
      {
        'title': 'ABSA-Alerts\nAccount Block',
        'initials': 'AB',
        'badge': '!',
        'sample': SyntheticSamples.samples[0],
      },
      {
        'title': 'Airtel MoMo\nFake Refund',
        'initials': 'AM',
        'badge': '!',
        'sample': SyntheticSamples.samples[1],
      },
      {
        'title': 'ZANACO\nOTP Theft',
        'initials': 'ZA',
        'badge': '!',
        'sample': SyntheticSamples.samples[2],
      },
      {
        'title': 'MTN MoMo\nFake Prize',
        'initials': 'MT',
        'badge': '!',
        'sample': SyntheticSamples.samples[3],
      },
      {
        'title': 'FNB Notice\nPIN Phishing',
        'initials': 'FN',
        'badge': '!',
        'sample': SyntheticSamples.samples[4],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Suspicious SMS & Threats',
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
                  MaterialPageRoute(builder: (context) => const AnalyzerScreen()),
                );
              },
              child: Text(
                'All (${threatSamples.length})',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Signature Green "Scan SMS" circle button (matches "Новый перевод" circle in screenshot)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AnalyzerScreen()),
                  );
                },
                child: SizedBox(
                  width: 76,
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.35),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scan\nSMS',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryGreen,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Threat Scenario Contacts with alert badges (matches contact avatars with orange badges in screenshot)
              ...threatSamples.map((item) {
                final sample = item['sample'] as SampleMessage;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onSelectSample(sample),
                    child: SizedBox(
                      width: 78,
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.avatarDark : AppTheme.avatarLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    item['initials'] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFFDCE3EA) : const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accentOrange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      item['badge'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['title'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isDark ? AppTheme.textMuted : AppTheme.textDarkMuted,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
