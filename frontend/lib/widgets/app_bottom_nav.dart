import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'ai_shield_orb.dart';
import '../screens/analyzer_screen.dart';
import '../screens/assistant_screen.dart';
import '../screens/history_screen.dart';
import '../screens/privacy_screen.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabSelected;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onTabSelected,
  });

  void _handleNavigation(BuildContext context, int index) {
    if (onTabSelected != null) {
      onTabSelected!(index);
      return;
    }

    if (index == currentIndex) return;

    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AssistantScreen()),
      );
      return;
    }

    Widget targetScreen;
    switch (index) {
      case 1:
        targetScreen = const AnalyzerScreen();
        break;
      case 3:
        targetScreen = const PrivacyScreen();
        break;
      case 4:
        targetScreen = const HistoryScreen();
        break;
      default:
        return;
    }

    if (currentIndex != 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C090D) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF20131E) : const Color(0xFFEAE2E8),
            width: 1,
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
      ),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 12),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              icon: Icons.home_filled,
              label: 'Home',
              isActive: currentIndex == 0,
            ),
            _buildNavItem(
              context: context,
              index: 1,
              icon: Icons.sms_outlined,
              label: 'SMS Fraud',
              isActive: currentIndex == 1,
            ),
            // Center AI Assistant Swirl / Orb in Absa Red
            GestureDetector(
              onTap: () => _handleNavigation(context, 2),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const AiShieldOrb(size: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assistant',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: currentIndex == 2 ? FontWeight.w600 : FontWeight.w500,
                      color: currentIndex == 2
                          ? AppTheme.absaRed
                          : (isDark ? const Color(0xFF8E8292) : const Color(0xFF75626F)),
                    ),
                  ),
                ],
              ),
            ),
            _buildNavItem(
              context: context,
              index: 3,
              icon: Icons.shield_outlined,
              label: 'Security',
              isActive: currentIndex == 3,
            ),
            _buildNavItem(
              context: context,
              index: 4,
              icon: Icons.access_time_rounded,
              label: 'History',
              isActive: currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppTheme.absaRed;
    final inactiveColor = isDark ? const Color(0xFF8E8292) : const Color(0xFF75626F);

    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : inactiveColor,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
