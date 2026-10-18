import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_shield_orb.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _enteredPin = '';
  String? _errorMessage;
  final int _pinLength = 4;

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < _pinLength) {
      final newPin = _enteredPin + digit;
      setState(() {
        _enteredPin = newPin;
        _errorMessage = null;
      });

      if (newPin.length == _pinLength) {
        _verifyPin(newPin);
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _verifyPin(String pinToVerify) {
    final auth = AuthService();
    final success = auth.verifyPin(pinToVerify);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Try again or check default demo PIN (1234).';
        _enteredPin = '';
      });
    }
  }

  void _simulateBiometricUnlock() {
    final auth = AuthService();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.face_retouching_natural_rounded, color: Color(0xFF00FF88)),
            SizedBox(width: 10),
            Text('Biometric authentication verified.'),
          ],
        ),
        backgroundColor: const Color(0xFF0A0F1D),
        duration: const Duration(milliseconds: 1200),
      ),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      auth.verifyPin(auth.currentUser?.pin ?? '1234');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top branding & title
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      const AiShieldOrb(size: 64),
                      const SizedBox(height: 18),
                      Text(
                        'Enter your 4-digit Security PIN',
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFCBD5E1),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // PIN Dots Indicator (similar to screenshot)
                      _buildPinDots(),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFF4D4D),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Keypad matching screenshot layout
                  _buildKeypad(),

                  const SizedBox(height: 16),

                  // Bottom actions
                  Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          // Switch to registration screen
                          AuthService().resetToNewUser();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          'Register New Account / Switch User',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Default Competition Demo PIN: 1234',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final isFilled = index < _enteredPin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppTheme.primaryGreen : const Color(0xFF1E2834),
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'bio', '0', 'del'];

    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Column(
        children: [
          for (int row = 0; row < 4; row++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int col = 0; col < 3; col++)
                    _buildKeypadButton(keys[row * 3 + col]),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String key) {
    if (key == 'bio') {
      return SizedBox(
        width: 58,
        height: 58,
        child: IconButton(
          tooltip: 'Biometric Unlock',
          icon: const Icon(Icons.face_rounded, size: 24, color: AppTheme.mintAccent),
          onPressed: _simulateBiometricUnlock,
        ),
      );
    }

    if (key == 'del') {
      return SizedBox(
        width: 58,
        height: 58,
        child: IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.backspace_outlined, size: 20, color: AppTheme.textMuted),
          onPressed: _onDeletePressed,
        ),
      );
    }

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
          onTap: () => _onDigitPressed(key),
          child: Center(
            child: Text(
              key,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
