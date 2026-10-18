import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../history_screen.dart';

class AnalyzerFixedTopNav extends StatelessWidget {
  final bool isDesktop;
  final bool isDark;
  final bool isScrolled;

  const AnalyzerFixedTopNav({
    super.key,
    required this.isDesktop,
    required this.isDark,
    required this.isScrolled,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF8B0B24) : const Color(0xFFDC0032),
        boxShadow: isScrolled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 24 : 16,
        topInset > 0 ? topInset + 10 : 16,
        isDesktop ? 24 : 16,
        14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
          ),
          Text(
            'SMS Fraud Shield',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.history_rounded, color: Colors.white, size: 22),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AnalyzerTopBannerSubtitle extends StatelessWidget {
  final bool isDesktop;
  final bool isDark;

  const AnalyzerTopBannerSubtitle({
    super.key,
    required this.isDesktop,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF8B0B24),
                  Color(0xFF6B091E),
                  Color(0xFF4A0514),
                  Color(0xFF22040B),
                ]
              : const [
                  Color(0xFFDC0032),
                  Color(0xFFBA002A),
                  Color(0xFF980022),
                  Color(0xFF7A001B),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 24 : 16,
        6,
        isDesktop ? 24 : 16,
        18,
      ),
      child: Text(
        'Check any text message for scams, fake MoMo reversals, and phishing links.',
        style: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.92),
          height: 1.35,
        ),
      ),
    );
  }
}
