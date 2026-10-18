import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../analyzer_screen.dart';
import '../../privacy_screen.dart';

class WalletOverviewSection extends StatelessWidget {
  final bool isDesktop;
  final bool isDark;
  final bool balanceVisible;
  final VoidCallback onToggleBalanceVisibility;
  final VoidCallback onMoreOptions;

  const WalletOverviewSection({
    super.key,
    required this.isDesktop,
    required this.isDark,
    required this.balanceVisible,
    required this.onToggleBalanceVisibility,
    required this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF8B0B24), // Vibrant Absa Red-Burgundy
                  Color(0xFF6B091E), // Absa Rich Burgundy
                  Color(0xFF4A0514), // Deep Wine
                  Color(0xFF22040B),
                ]
              : const [
                  Color(0xFFDC0032), // Signature Absa Passionate Red
                  Color(0xFFBA002A),
                  Color(0xFF980022),
                  Color(0xFF7A001B),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 24 : 16,
        14,
        isDesktop ? 24 : 16,
        26,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "AI Shield & Threat Monitor" label
          Text(
            'AI Shield & Threat Monitor',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFFDCA5B0) : Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),

          // Protection Status Row
          Row(
            children: [
              Text(
                balanceVisible ? '99.4% Protected' : '••••••••',
                style: GoogleFonts.inter(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF88).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00FF88),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Active',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF00FF88),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  balanceVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: onToggleBalanceVisibility,
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 24),
                onPressed: onMoreOptions,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Horizontal Carousel
          SizedBox(
            height: 154,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // Two stacked action squares
                Column(
                  children: [
                    _buildSquareActionTile(
                      isDark: isDark,
                      iconWidget: Icon(
                        Icons.sms_rounded,
                        color: isDark ? const Color(0xFFE5BFC7) : Colors.white,
                        size: 22,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AnalyzerScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildSquareActionTile(
                      isDark: isDark,
                      iconWidget: Icon(
                        Icons.shield_outlined,
                        color: isDark ? const Color(0xFFE5BFC7) : Colors.white,
                        size: 22,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PrivacyScreen()),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(width: 10),

                // Card 1: Absa Passion Red Card
                _buildBankCard(
                  isDark: isDark,
                  balanceVisible: balanceVisible,
                  topWidget: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.absaRed, AppTheme.absaCrimson],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.absaRed.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.shield_rounded, color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                  chipNumber: 'SMS SHIELD',
                  amount: '0 Threats',
                  accountNumber: 'SIM •• 8440 Monitored',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AnalyzerScreen()),
                    );
                  },
                ),

                const SizedBox(width: 10),

                // Card 2: Absa Platinum Silver Card
                _buildBankCard(
                  isDark: isDark,
                  balanceVisible: balanceVisible,
                  topWidget: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFFE2E4E8) : const Color(0xFFECEEF2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.absaRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  chipNumber: 'ANTI-PHISHING',
                  amount: '3 Filtered',
                  accountNumber: 'Phishing links blocked',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AnalyzerScreen()),
                    );
                  },
                ),

                const SizedBox(width: 10),

                // Card 3: Absa Premier Gold card
                _buildBankCard(
                  isDark: isDark,
                  balanceVisible: balanceVisible,
                  topWidget: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.absaGold, Color(0xFFC78F1A)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                  chipNumber: 'MOMO SHIELD',
                  amount: '100% OK',
                  accountNumber: 'Airtel & MTN secured',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AnalyzerScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareActionTile({
    required bool isDark,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF220D16).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3F1724) : Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(child: iconWidget),
        ),
      ),
    );
  }

  Widget _buildBankCard({
    required bool isDark,
    required bool balanceVisible,
    required Widget topWidget,
    required String chipNumber,
    required String amount,
    required String accountNumber,
    VoidCallback? onTap,
  }) {
    return Container(
      width: 154,
      height: 154,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF220D16).withValues(alpha: 0.9) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF3D1623) : const Color(0xFFE8DFE5),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    topWidget,
                    if (chipNumber.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        chipNumber,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFFDCA5B0) : AppTheme.textDarkMuted,
                        ),
                      ),
                    ],
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      balanceVisible ? amount : '••••',
                      style: GoogleFonts.inter(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      accountNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                        color: isDark ? const Color(0xFFDCA5B0) : AppTheme.textDarkMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
