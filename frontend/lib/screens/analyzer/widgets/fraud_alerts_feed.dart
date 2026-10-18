import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/synthetic_samples.dart';
import '../../../models/analysis_result.dart';
import '../../../models/sample_message.dart';
import '../../../theme/app_theme.dart';
import '../models/sample_display_meta.dart';

class FraudAlertsFeed extends StatefulWidget {
  final bool isDark;
  final ValueChanged<SampleMessage> onSelectSample;

  const FraudAlertsFeed({
    super.key,
    required this.isDark,
    required this.onSelectSample,
  });

  @override
  State<FraudAlertsFeed> createState() => _FraudAlertsFeedState();
}

class _FraudAlertsFeedState extends State<FraudAlertsFeed> {
  String _selectedCategory = 'All';
  final Set<String> _expandedDates = {'27 September, Sun'};

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final categories = ['All', 'High Risk', 'Suspicious', 'Low Concern'];

    final filteredSamples = SyntheticSamples.samples.where((s) {
      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'High Risk') return s.expectedRisk == RiskBand.high;
      if (_selectedCategory == 'Suspicious') return s.expectedRisk == RiskBand.suspicious;
      if (_selectedCategory == 'Low Concern') return s.expectedRisk == RiskBand.low;
      return true;
    }).toList();

    // Group samples by date group preserving order
    final Map<String, List<SampleMessage>> grouped = {};
    for (final sample in filteredSamples) {
      final meta = SampleDisplayMeta.forSample(sample);
      grouped.putIfAbsent(meta.dateGroup, () => []).add(sample);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Fraud Alerts',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
            ),
            Text(
              'Tap alert to test',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? AppTheme.textMuted : AppTheme.textDarkMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = cat;
                      if (cat != 'All') {
                        _expandedDates.addAll(grouped.keys);
                      }
                    });
                  },
                  backgroundColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF1EBF0),
                  selectedColor: AppTheme.absaRed.withValues(alpha: 0.18),
                  checkmarkColor: AppTheme.absaRed,
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.absaRed
                        : (isDark ? AppTheme.surfaceBorder : AppTheme.surfaceBorderLight),
                  ),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.absaRed
                        : (isDark ? AppTheme.textMuted : AppTheme.textDarkMuted),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 10),

        // Date groups and collapsible alert items
        ...grouped.entries.expand((entry) {
          final dateHeader = entry.key;
          final samplesInGroup = entry.value;
          final isExpanded = _expandedDates.contains(dateHeader);

          return [
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 4),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedDates.remove(dateHeader);
                    } else {
                      _expandedDates.add(dateHeader);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            dateHeader,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF26121B) : const Color(0xFFF1E6EB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${samplesInGroup.length}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFA694A0) : AppTheme.textDarkMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isDark ? const Color(0xFFA694A0) : AppTheme.textDarkMuted,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isExpanded)
              ...samplesInGroup.map((sample) => _buildMessageRow(sample, isDark)),
          ];
        }),
      ],
    );
  }

  Widget _buildMessageRow(SampleMessage sample, bool isDark) {
    final meta = SampleDisplayMeta.forSample(sample);
    final riskColor = meta.riskColor;

    return InkWell(
      onTap: () => widget.onSelectSample(sample),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
        child: Row(
          children: [
            // Left alert icon emblem
            SampleDisplayMeta.buildIcon(
              context: context,
              iconType: meta.iconType,
              isDark: isDark,
            ),
            const SizedBox(width: 14),

            // Alert Title & SMS text preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meta.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta.displaySubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: isDark ? const Color(0xFFA694A0) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Trailing amount (RED for alerts) & risk status pill
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  meta.amount,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: riskColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: riskColor.withValues(alpha: isDark ? 0.4 : 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    meta.amountSubtitle,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: riskColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
