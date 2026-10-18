import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sample_message.dart';
import '../services/fraud_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import 'analyzer/widgets/analyzer_top_nav.dart';
import 'analyzer/widgets/auto_detect_toggle_card.dart';
import 'analyzer/widgets/fraud_alerts_feed.dart';
import 'analyzer/widgets/sms_input_card.dart';
import 'result_screen.dart';

class AnalyzerScreen extends StatefulWidget {
  final String? initialMessage;

  const AnalyzerScreen({super.key, this.initialMessage});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> {
  late final TextEditingController _controller;
  late final ScrollController _scrollController;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isScrolled = false;
  bool _autoDetectEnabled = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMessage ?? '');
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
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        _controller.text = data.text!;
        _errorMessage = null;
      });
    }
  }

  void _loadSample(SampleMessage sample) {
    setState(() {
      _controller.text = sample.text;
      _errorMessage = null;
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loaded scenario: "${sample.title}"'),
        backgroundColor: const Color(0xFF0A2415),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _analyzeMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please paste or type an SMS message to analyse.';
      });
      return;
    }

    if (text.length > 1000) {
      setState(() {
        _errorMessage = 'Message exceeds maximum length of 1000 characters.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await FraudService.analyzeMessage(
        message: text,
        demoMode: true,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Scan error: ${e.toString().replaceAll("Exception: ", "")}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onToggleAutoDetect(bool val) {
    setState(() {
      _autoDetectEnabled = val;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              val ? Icons.shield_rounded : Icons.shield_outlined,
              color: val ? const Color(0xFF4ADE80) : Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                val
                    ? 'Automatic fraud detection active. Incoming SMS will be scanned.'
                    : 'Automatic fraud detection paused.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0A2415),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // FIXED TOP NAV (Remains pinned at the top while scrolling)
              AnalyzerFixedTopNav(
                isDesktop: isDesktop,
                isDark: isDark,
                isScrolled: _isScrolled,
              ),

              // SCROLLABLE BODY CONTENT
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Connected banner subtitle
                      AnalyzerTopBannerSubtitle(
                        isDesktop: isDesktop,
                        isDark: isDark,
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 24 : 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),

                            // FOCUSED INPUT CARD
                            SmsInputCard(
                              controller: _controller,
                              isDark: isDark,
                              onPaste: _handlePaste,
                              onClear: () {
                                setState(() {
                                  _controller.clear();
                                  _errorMessage = null;
                                });
                              },
                              onChanged: (_) => setState(() {}),
                            ),

                            const SizedBox(height: 16),

                            // PRIMARY ACTION BUTTON
                            SmsAnalyzeActionButton(
                              isLoading: _isLoading,
                              onAnalyze: _analyzeMessage,
                            ),

                            if (_errorMessage != null) ...[
                              const SizedBox(height: 14),
                              SmsErrorBanner(message: _errorMessage!),
                            ],

                            const SizedBox(height: 16),

                            // AUTOMATIC DETECTION & FLAGGING TOGGLE
                            AutoDetectToggleCard(
                              isDark: isDark,
                              isEnabled: _autoDetectEnabled,
                              onToggle: _onToggleAutoDetect,
                            ),

                            const SizedBox(height: 24),

                            // BANKING-STYLE SMS FEED SECTION (Grouped by Date)
                            FraudAlertsFeed(
                              isDark: isDark,
                              onSelectSample: _loadSample,
                            ),

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
}
