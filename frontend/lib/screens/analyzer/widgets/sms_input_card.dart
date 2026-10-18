import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class SmsInputCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onPaste;
  final VoidCallback onClear;
  final ValueChanged<String>? onChanged;

  const SmsInputCard({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onPaste,
    required this.onClear,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final cardBorder = isDark ? AppTheme.surfaceBorder : AppTheme.surfaceBorderLight;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SMS Message',
                style: GoogleFonts.outfit(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.absaCoral,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.paste_rounded, size: 15),
                    label: const Text('Paste', style: TextStyle(fontWeight: FontWeight.w600)),
                    onPressed: onPaste,
                  ),
                  if (controller.text.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        visualDensity: VisualDensity.compact,
                        foregroundColor: const Color(0xFFFF4D4D),
                      ),
                      icon: const Icon(Icons.clear_rounded, size: 15),
                      label: const Text('Clear'),
                      onPressed: onClear,
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Message Input Field
          TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 1000,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? AppTheme.textLight : AppTheme.textDark,
              height: 1.45,
            ),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF0C090D) : const Color(0xFFFBF8FA),
              hintText: 'Paste message text here to analyse...',
              hintStyle: GoogleFonts.inter(
                fontSize: 13.5,
                color: isDark ? const Color(0xFF756370) : AppTheme.textDarkSubtle,
              ),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.absaRed, width: 1.5),
              ),
              counterStyle: GoogleFonts.inter(
                fontSize: 11,
                color: isDark ? AppTheme.textMuted : AppTheme.textDarkMuted,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: isDark ? const Color(0xFFA694A0) : AppTheme.textDarkSubtle,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Private & ephemeral. Never paste PINs or passwords.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: isDark ? const Color(0xFFA694A0) : AppTheme.textDarkSubtle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SmsAnalyzeActionButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onAnalyze;

  const SmsAnalyzeActionButton({
    super.key,
    required this.isLoading,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFDC0032), // Signature Absa Passionate Red
            Color(0xFFBA002A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.absaRed.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isLoading ? null : onAnalyze,
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Analyzing message signals...',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_rounded, size: 20, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Analyse Message',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class SmsErrorBanner extends StatelessWidget {
  final String message;

  const SmsErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF26040C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF334B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFFF334B), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFFFF8080),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
