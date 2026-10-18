import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/auth_service.dart';
import '../../../services/theme_service.dart';
import '../../../theme/app_theme.dart';
import '../../analyzer_screen.dart';
import '../../history_screen.dart';

class HomeFixedTopNav extends StatelessWidget {
  final bool isDesktop;
  final bool isDark;
  final bool isScrolled;
  final TextEditingController searchController;

  const HomeFixedTopNav({
    super.key,
    required this.isDesktop,
    required this.isDark,
    required this.isScrolled,
    required this.searchController,
  });

  void _showAccountMenu(BuildContext context) {
    final user = AuthService().currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161017) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2D1520) : const Color(0xFFFDE8EC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: AppTheme.absaCoral, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Chileshe Mwamba',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                          Text(
                            user?.phoneNumber ?? '+260 97X XXX XXX',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark ? AppTheme.textMuted : AppTheme.textDarkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: isDark ? const Color(0xFF2E1C28) : const Color(0xFFEAE2E8)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.absaRed.withValues(alpha: 0.15) : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: AppTheme.absaRed,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    isDark ? 'Light Mode' : 'Dark Mode',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.textDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    isDark ? 'Switch to bright appearance' : 'Switch to dark appearance',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFA694A0) : AppTheme.textDarkMuted,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Switch(
                    value: !isDark,
                    activeThumbColor: AppTheme.absaRed,
                    onChanged: (val) {
                      ThemeService().toggleTheme();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
        children: [
          // Avatar button (opens profile dropdown menu with theme switch)
          GestureDetector(
            onTap: () => _showAccountMenu(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF351520) : Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: isDark ? const Color(0xFFE5BFC7) : Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Search Pill with CURVED BORDER and clean pill styling
          Expanded(
            child: Container(
              height: 44,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF220B13) : Colors.black.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF5E1726) : Colors.white.withValues(alpha: 0.35),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: 'Scan SMS, phone number or URL...',
                  hintStyle: GoogleFonts.inter(
                    color: isDark ? const Color(0xFFB58E97) : Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                  suffixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? const Color(0xFFDCA5B0) : Colors.white,
                    size: 21,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark ? AppTheme.absaCoral : Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (query) {
                  if (query.trim().isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AnalyzerScreen(initialMessage: query)),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Quick Fraud Shield icon
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
            tooltip: 'SMS Scanner',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyzerScreen()));
            },
          ),

          // Notification bell outline
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 23),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
            },
          ),
        ],
      ),
    );
  }
}
