import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class AutoDetectToggleCard extends StatelessWidget {
  final bool isDark;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const AutoDetectToggleCard({
    super.key,
    required this.isDark,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final cardBorder = isDark ? AppTheme.surfaceBorder : AppTheme.surfaceBorderLight;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEnabled
              ? (isDark ? AppTheme.primaryGreen.withValues(alpha: 0.45) : const Color(0xFF86EFAC))
              : cardBorder,
          width: isEnabled ? 1.2 : 1.0,
        ),
        boxShadow: [
          if (isEnabled)
            BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: isDark ? 0.12 : 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onToggle(!isEnabled),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? AppTheme.primaryGreen.withValues(alpha: isDark ? 0.22 : 0.12)
                        : (isDark ? const Color(0xFF132E20) : const Color(0xFFE8F6EF)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isEnabled
                          ? Icons.radar_rounded
                          : Icons.shield_outlined,
                      color: isEnabled
                          ? AppTheme.primaryGreen
                          : (isDark ? AppTheme.textMuted : AppTheme.textDarkMuted),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Automatically detect and flag fraud',
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isEnabled
                            ? 'Active • Real-time SMS scan and instant scam alerts'
                            : 'Disabled • Tap to enable background SMS protection',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isEnabled
                              ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
                              : (isDark ? AppTheme.textMuted : AppTheme.textDarkMuted),
                          fontWeight: isEnabled ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch.adaptive(
                  value: isEnabled,
                  activeThumbColor: AppTheme.primaryGreen,
                  activeTrackColor: AppTheme.primaryGreen.withValues(alpha: 0.38),
                  inactiveThumbColor: isDark ? AppTheme.textSubtle : AppTheme.textDarkSubtle,
                  inactiveTrackColor: isDark ? AppTheme.surfaceBorder : AppTheme.surfaceBorderLight,
                  onChanged: onToggle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
