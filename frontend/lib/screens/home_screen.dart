import 'package:flutter/material.dart';
import '../models/sample_message.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import 'analyzer_screen.dart';
import 'home/widgets/home_top_nav.dart';
import 'home/widgets/promo_alert_banner.dart';
import 'home/widgets/suspicious_transfers_section.dart';
import 'home/widgets/threat_summary_section.dart';
import 'home/widgets/wallet_overview_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _balanceVisible = true;
  bool _promoVisible = true;
  final TextEditingController _searchController = TextEditingController();
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
    _searchController.dispose();
    super.dispose();
  }

  void _openAnalyzerWithSample(SampleMessage sample) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyzerScreen(initialMessage: sample.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // FIXED TOP NAV (Remains fixed at top when scrolling)
              HomeFixedTopNav(
                isDesktop: isDesktop,
                isDark: isDark,
                isScrolled: _isScrolled,
                searchController: _searchController,
              ),

              // SCROLLABLE BODY CONTENT
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. TOP ABSA BURGUNDY & RUBY HERO SECTION
                      WalletOverviewSection(
                        isDesktop: isDesktop,
                        isDark: isDark,
                        balanceVisible: _balanceVisible,
                        onToggleBalanceVisibility: () {
                          setState(() => _balanceVisible = !_balanceVisible);
                        },
                        onMoreOptions: () {},
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 24 : 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 18),

                            // 2. PROMO BANNER: Fraud Alert
                            if (_promoVisible) ...[
                              PromoAlertBanner(
                                isDark: isDark,
                                onDismiss: () {
                                  setState(() => _promoVisible = false);
                                },
                              ),
                              const SizedBox(height: 26),
                            ],

                            // 3. SUSPICIOUS SAMPLES / SCANS SECTION
                            SuspiciousTransfersSection(
                              isDark: isDark,
                              onSelectSample: _openAnalyzerWithSample,
                            ),

                            const SizedBox(height: 28),

                            // 4. FRAUD INCIDENTS & THREAT SUMMARY
                            ThreatSummarySection(
                              isDark: isDark,
                              onSelectSample: _openAnalyzerWithSample,
                            ),

                            const SizedBox(height: 48),
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
}
