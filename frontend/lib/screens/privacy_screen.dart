import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  late final ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final scrolled = _scrollController.hasClients && _scrollController.offset > 8;
      if (scrolled != _isScrolled) {
        setState(() {
          _isScrolled = scrolled;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // FIXED TOP NAV: Pinned at top even when scrolling
              _buildFixedTopNav(isDesktop, isDark),

              // SCROLLABLE BODY CONTENT
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Connected banner subtitle
                      _buildTopBannerSubtitle(isDesktop, isDark),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 24 : 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 18),

                            // 1. TRUST TRANSPARENCY CARD
                            _buildTrustBanner(isDark),

                            const SizedBox(height: 18),

                            // 2. SECURITY POLICIES
                            _buildSecurityCard(
                              isDark: isDark,
                              icon: Icons.vpn_lock_rounded,
                              iconColor: const Color(0xFF00C853),
                              title: '1. Ephemeral Processing & Zero Retention',
                              content:
                                  'Munda AI Fraud Shield processes SMS messages on-demand to perform heuristic and AI evaluations. The application does not store, log, or sell submitted text. Users are explicitly cautioned NEVER to enter secret personal identification numbers (PINs), banking passwords, or one-time passwords (OTPs).',
                            ),
                            const SizedBox(height: 12),

                            _buildSecurityCard(
                              isDark: isDark,
                              icon: Icons.cloud_sync_outlined,
                              iconColor: AppTheme.absaCoral,
                              title: '2. Artificial Intelligence Integration',
                              content:
                                  'When AI-assisted analysis is active, the submitted SMS string is transmitted over encrypted server-side channels (TLS 1.3) from the backend to the Google Gemini API. The message is tagged strictly as untrusted data within sandboxed delimiters to defend against prompt injection attacks.',
                            ),
                            const SizedBox(height: 12),

                            _buildSecurityCard(
                              isDark: isDark,
                              icon: Icons.gavel_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              title: '3. Meaning of Risk Bands & Limitations',
                              content:
                                  'Assessments provided by Munda AI Fraud Shield are purely indicative indicators designed to assist consumers in identifying known scam patterns. A "Low Concern" rating does NOT verify, guarantee, or certify that a message or sender is legitimate. Fraudsters continually adapt phrasing.',
                            ),
                            const SizedBox(height: 12),

                            _buildSecurityCard(
                              isDark: isDark,
                              icon: Icons.business_outlined,
                              iconColor: isDark ? const Color(0xFFA694A0) : AppTheme.textDarkMuted,
                              title: '4. Independence & Prototype Status',
                              content:
                                  'Munda AI Fraud Shield is an independent fintech prototype created for demonstration and evaluation in Zambia. It is not an official ABSA product, nor does it have direct live API integration with the Bank of Zambia, Airtel, MTN, or ZANACO.',
                            ),

                            const SizedBox(height: 20),

                            // 3. GOLDEN RULES BOX
                            _buildSafetyAdviceBox(isDark),

                            const SizedBox(height: 56),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FIXED TOP NAV (Remains pinned at the top while scrolling)
  Widget _buildFixedTopNav(bool isDesktop, bool isDark) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF8B0B24) : const Color(0xFFDC0032),
        boxShadow: _isScrolled
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
            'Security & Privacy',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  'Active',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CONNECTED SUBTITLE BANNER
  Widget _buildTopBannerSubtitle(bool isDesktop, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF8B0B24),
                  Color(0xFF6B091E),
                  Color(0xFF330510),
                ]
              : const [
                  Color(0xFFDC0032),
                  Color(0xFFBA002A),
                  Color(0xFF88001E),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 24 : 16,
        4,
        isDesktop ? 24 : 16,
        18,
      ),
      child: Text(
        'Zero credential retention, ephemeral scanning, and AI security safeguards.',
        style: GoogleFonts.inter(
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.88),
          height: 1.35,
        ),
      ),
    );
  }

  // 1. TRUST BANNER
  Widget _buildTrustBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppTheme.surfaceBorder : AppTheme.surfaceBorderLight,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF28101A) : const Color(0xFFFDE8EC),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.verified_user_rounded, color: AppTheme.absaRed, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trust & Transparency',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We believe digital financial protection must respect user privacy. Here is how your message data is processed and protected.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: isDark ? const Color(0xFFA694A0) : AppTheme.textDarkMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. SECURITY CARD
  Widget _buildSecurityCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.surfaceBorder : AppTheme.surfaceBorderLight,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFFA694A0) : const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // 3. GOLDEN RULES ADVICE BOX
  Widget _buildSafetyAdviceBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E0A12) : const Color(0xFFFFF1F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.absaRed.withValues(alpha: 0.3) : const Color(0xFFFECDD3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_outlined, color: AppTheme.absaRed, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Golden Rules of Digital Safety in Zambia:',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.absaCoral : AppTheme.absaRed,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '• Never share your 4-digit mobile money PIN or bank OTP with anyone calling or texting you.\n• Always check official balances inside your Airtel Money, MTN MoMo, or banking app directly.\n• Beware of urgent threats claiming your account will close in 24 hours.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? const Color(0xFFE2D6DE) : const Color(0xFF334155),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
