import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/assistant_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'analyzer_screen.dart';

enum MessageSender { user, assistant }

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final bool isSecurityTopic;
  final String? source;
  final List<String> suggestedFollowups;
  final bool isThinking;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.isSecurityTopic = true,
    this.source,
    this.suggestedFollowups = const [],
    this.isThinking = false,
  });

  ChatMessage copyWith({
    String? text,
    bool? isSecurityTopic,
    String? source,
    List<String>? suggestedFollowups,
    bool? isThinking,
  }) {
    return ChatMessage(
      id: id,
      sender: sender,
      text: text ?? this.text,
      timestamp: timestamp,
      isSecurityTopic: isSecurityTopic ?? this.isSecurityTopic,
      source: source ?? this.source,
      suggestedFollowups: suggestedFollowups ?? this.suggestedFollowups,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isThinking = false;
  bool _isSoundEnabled = true;
  late final List<ChatMessage> _messages;

  late AnimationController _orbPulseController;
  late Animation<double> _orbPulseAnimation;

  @override
  void initState() {
    super.initState();

    _orbPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _orbPulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _orbPulseController, curve: Curves.easeInOut),
    );

    final user = AuthService().currentUser;
    final userName = user?.name.split(' ').first ?? 'Chileshe';

    // Seed initial greeting message
    _messages = [
      ChatMessage(
        id: 'welcome_1',
        sender: MessageSender.assistant,
        text:
            'Msalani $userName! 👋 I am your Munda AI Security Assistant, connected to Google Gemini.\n\nI am strictly specialized in mobile financial fraud prevention in Zambia (Airtel Money, MTN MoMo, ZANACO, ABSA, ZRA, ZESCO) and explaining security alerts caught on your account.\n\nHow can I help protect you today?',
        timestamp: DateTime.now(),
        isSecurityTopic: true,
        source: 'gemini_ai',
        suggestedFollowups: const [
          'Tell me more about the Money alert',
          'What is the ZANACO OTP theft alert?',
          'What to do if a caller threatens police arrest?',
          'How does the fake reversal scam work?',
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _orbPulseController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || _isThinking) return;

    _textController.clear();

    final userMsgId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final thinkingMsgId = 'thinking_${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _messages.add(
        ChatMessage(
          id: userMsgId,
          sender: MessageSender.user,
          text: trimmed,
          timestamp: DateTime.now(),
        ),
      );

      // Add temporary thinking placeholder bubble
      _messages.add(
        ChatMessage(
          id: thinkingMsgId,
          sender: MessageSender.assistant,
          text: '',
          timestamp: DateTime.now(),
          isThinking: true,
        ),
      );
      _isThinking = true;
    });

    _scrollToBottom();

    try {
      final response = await AssistantService.ask(query: trimmed);

      if (mounted) {
        setState(() {
          // Replace thinking bubble with real response
          final index = _messages.indexWhere((m) => m.id == thinkingMsgId);
          if (index != -1) {
            _messages[index] = ChatMessage(
              id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
              sender: MessageSender.assistant,
              text: response.answer,
              timestamp: DateTime.now(),
              isSecurityTopic: response.isSecurityTopic,
              source: response.source,
              suggestedFollowups: response.suggestedFollowups,
              isThinking: false,
            );
          }
          _isThinking = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final index = _messages.indexWhere((m) => m.id == thinkingMsgId);
          if (index != -1) {
            _messages[index] = ChatMessage(
              id: 'error_${DateTime.now().millisecondsSinceEpoch}',
              sender: MessageSender.assistant,
              text:
                  "I was unable to consult the security engine. Please verify your connection or try asking about specific alerts like 'Tell me more about the Money alert'.",
              timestamp: DateTime.now(),
              isSecurityTopic: true,
              source: 'offline_core',
              isThinking: false,
            );
          }
          _isThinking = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _clearChat() {
    final user = AuthService().currentUser;
    final userName = user?.name.split(' ').first ?? 'Chileshe';

    setState(() {
      _messages.clear();
      _messages.add(
        ChatMessage(
          id: 'welcome_cleared',
          sender: MessageSender.assistant,
          text:
              'Chat cleared! 🧹 Ask me about any mobile money alert or scam prevention tactic in Zambia, $userName.',
          timestamp: DateTime.now(),
          isSecurityTopic: true,
          source: 'gemini_ai',
          suggestedFollowups: const [
            'Tell me more about the Money alert',
            'What is the ZANACO OTP theft alert?',
            'How do scammers steal PINs on phone calls?',
          ],
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Chat history reset'),
        backgroundColor: const Color(0xFF380712),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _simulateVoiceInput() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.mic_rounded, color: AppTheme.absaCoral, size: 20),
            const SizedBox(width: 10),
            Text(
              'Listening... (Asking "Tell me more about the Money alert")',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF32050E),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _sendMessage('Tell me more about the Money alert');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF12060A) : const Color(0xFFF9F5F7);
    final Color topBarColor = isDark ? const Color(0xFF1E0B12) : Colors.white;
    final Color inputBarColor = isDark ? const Color(0xFF1E0B12) : Colors.white;
    final Color primaryTextColor = isDark ? Colors.white : const Color(0xFF1E1015);
    final Color secondaryTextColor = isDark ? const Color(0xFFD6BAC5) : const Color(0xFF6B5861);
    final Color borderColor = isDark ? const Color(0xFF38141F) : const Color(0xFFEEDAE2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: topBarColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to Munda Shield',
        ),
        title: Row(
          children: [
            // Avatar with pulsing green online dot
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFFF4D6D),
                        Color(0xFFDC0032),
                        Color(0xFF8B0B24),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.absaRed.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF88),
                      shape: BoxShape.circle,
                      border: Border.all(color: topBarColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Assistant',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Gemini AI • Active Guardrails',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF10B981),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              size: 20,
              color: _isSoundEnabled ? AppTheme.absaRed : secondaryTextColor,
            ),
            tooltip: _isSoundEnabled ? 'Audio alerts on' : 'Audio muted',
            onPressed: () {
              setState(() {
                _isSoundEnabled = !_isSoundEnabled;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: secondaryTextColor, size: 21),
            tooltip: 'Clear conversation',
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // Subtle Security Scope Header Pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF18070E) : const Color(0xFFF7EFF3),
              border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, size: 14, color: AppTheme.absaRed),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Specialized in Zambian Mobile Money & Alert Explanations',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFE2C4D0) : const Color(0xFF6B4856),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Chat Messages Stream
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                if (message.sender == MessageSender.user) {
                  return _buildUserBubble(message, isDark);
                } else {
                  return _buildAssistantBubble(message, isDark);
                }
              },
            ),
          ),

          // Bottom Chat Input Bar with Quick Horizontal Chips & Action Buttons
          Container(
            decoration: BoxDecoration(
              color: inputBarColor,
              border: Border(top: BorderSide(color: borderColor, width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Horizontal quick prompt suggestions bar (above input)
                  if (!_isThinking && _messages.isNotEmpty)
                    _buildQuickPromptsBar(isDark),

                  // Text Input Row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Voice mic button
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: InkWell(
                            onTap: _simulateVoiceInput,
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? const Color(0xFF280E17) : const Color(0xFFF6EBF0),
                              ),
                              child: const Icon(
                                Icons.mic_rounded,
                                color: AppTheme.absaRed,
                                size: 21,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Text input field
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF240E16) : const Color(0xFFF7EFF3),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark ? const Color(0xFF3E1624) : const Color(0xFFE8D4DD),
                              ),
                            ),
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (val) => _sendMessage(val),
                              style: GoogleFonts.inter(
                                fontSize: 14.5,
                                color: primaryTextColor,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Ask about an alert or scam tactic...',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  color: secondaryTextColor,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                                border: InputBorder.none,
                              ),
                              onChanged: (_) {
                                setState(() {}); // Refresh to toggle send/mic state
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Send button with pulse animation when thinking
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: _isThinking
                              ? ScaleTransition(
                                  scale: _orbPulseAnimation,
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF8B0B24),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: () => _sendMessage(_textController.text),
                                  borderRadius: BorderRadius.circular(22),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFDC0032),
                                          Color(0xFF9E0827),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.absaRed.withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.arrow_upward_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // User Message Bubble (Right-Aligned)
  Widget _buildUserBubble(ChatMessage message, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 48),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFDC0032), // Signature Absa Red
                    Color(0xFFB30026), // Crimson
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.absaRed.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Assistant Message Bubble (Left-Aligned)
  Widget _buildAssistantBubble(ChatMessage message, bool isDark) {
    if (message.isThinking) {
      return _buildThinkingBubble(isDark);
    }

    final Color bubbleBg = isDark ? const Color(0xFF1E0A12) : Colors.white;
    final Color bubbleBorder = isDark ? const Color(0xFF381420) : const Color(0xFFEEDAE2);
    final Color textColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF2D1822);
    final Color subTextColor = isDark ? const Color(0xFFB898A6) : const Color(0xFF7A646E);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Assistant Avatar Icon
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFDC0032), Color(0xFF8B0B24)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.absaRed.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
            ),
          ),

          // Message Card
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bubbleBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: bubbleBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scope Pill Tag & Engine Tag
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: message.isSecurityTopic
                              ? const Color(0xFF00FF88).withValues(alpha: 0.15)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              message.isSecurityTopic ? Icons.verified_user_rounded : Icons.security_rounded,
                              size: 11,
                              color: message.isSecurityTopic ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              message.isSecurityTopic ? 'Fraud Guidance' : 'Operational Guardrail',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: message.isSecurityTopic ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        message.source == 'gemini_ai' ? 'Gemini 1.5' : 'Munda Core',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: subTextColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Message Body Text
                  SelectableText(
                    message.text,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      color: textColor,
                      height: 1.5,
                    ),
                  ),

                  // Quick Action button: Open SMS Scam Scanner if relevant
                  if (message.text.toLowerCase().contains('scanner') ||
                      message.text.toLowerCase().contains('scan') ||
                      message.text.toLowerCase().contains('sms') ||
                      message.text.toLowerCase().contains('alert')) ...[
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AnalyzerScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.absaRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.absaRed.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shield_rounded, size: 15, color: AppTheme.absaRed),
                            const SizedBox(width: 6),
                            Text(
                              'Open SMS Scam Scanner',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.absaRed,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.absaRed),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Inline Follow-up Chips
                  if (message.suggestedFollowups.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Divider(height: 1, color: bubbleBorder),
                    const SizedBox(height: 10),
                    Text(
                      'Suggested follow-ups:',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: message.suggestedFollowups.map((followup) {
                        return ActionChip(
                          backgroundColor: isDark ? const Color(0xFF2D101C) : const Color(0xFFF6ECF1),
                          side: BorderSide(
                            color: isDark ? const Color(0xFF4C1B2E) : const Color(0xFFE4CFDA),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          label: Text(
                            followup,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFFF3E5EB) : const Color(0xFF3E1D2A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () => _sendMessage(followup),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Thinking / Waiting Indicator Bubble
  Widget _buildThinkingBubble(bool isDark) {
    final Color bubbleBg = isDark ? const Color(0xFF1E0A12) : Colors.white;
    final Color bubbleBorder = isDark ? const Color(0xFF381420) : const Color(0xFFEEDAE2);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF8B0B24),
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: bubbleBorder, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _orbPulseAnimation,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.absaRed,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Gemini AI analyzing fraud patterns...',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: isDark ? const Color(0xFFB898A6) : const Color(0xFF7A646E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick Horizontal Prompt Chips above Input Field
  Widget _buildQuickPromptsBar(bool isDark) {
    final prompts = [
      'Tell me more about the Money alert',
      'What is the ZANACO OTP alert?',
      'How does a fake reversal work?',
      'What if threatened with police?',
      'How to report scam to ZICTA (7070)?',
    ];

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: prompts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return ActionChip(
            backgroundColor: isDark ? const Color(0xFF260D17) : const Color(0xFFF3E7ED),
            side: BorderSide(
              color: isDark ? const Color(0xFF421727) : const Color(0xFFE2CAD6),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            label: Text(
              prompt,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFEEDAE2) : const Color(0xFF4C2132),
              ),
            ),
            onPressed: () => _sendMessage(prompt),
          );
        },
      ),
    );
  }
}
