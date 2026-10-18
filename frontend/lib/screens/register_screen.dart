import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'pin_login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Chileshe Mwamba');
  final _phoneController = TextEditingController(text: '+260 977 123456');
  final _pinController = TextEditingController(text: '1234');
  final _confirmPinController = TextEditingController(text: '1234');
  bool _obscurePin = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    setState(() {
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name.');
      return;
    }
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Please enter your mobile phone number.');
      return;
    }
    if (pin.length != 4 || int.tryParse(pin) == null) {
      setState(() => _errorMessage = 'Security PIN must be exactly 4 numerical digits.');
      return;
    }
    if (pin != confirmPin) {
      setState(() => _errorMessage = 'PINs do not match. Please verify both entries.');
      return;
    }

    // Register user in AuthService
    AuthService().register(
      name: name,
      phoneNumber: phone,
      pin: pin,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.verified_user_rounded, color: AppTheme.absaRed),
            SizedBox(width: 10),
            Text('Account created securely! Welcome to Munda AI.'),
          ],
        ),
        backgroundColor: const Color(0xFF0A0F1D),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 24,
              vertical: 28,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    // Header Title
                    Text(
                      'Create Shield Account',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Setup your profile & 4-digit security PIN',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Full Name Field
                    _buildFieldLabel('Full Name'),
                    TextField(
                      controller: _nameController,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                      decoration: _inputDecoration(
                        hint: 'e.g. Chileshe Mwamba',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Mobile Phone Number Field
                    _buildFieldLabel('Mobile Phone Number (Zambia)'),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                      decoration: _inputDecoration(
                        hint: '+260 97X XXX XXX',
                        prefixIcon: Icons.phone_android_rounded,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4-Digit Security PIN
                    _buildFieldLabel('4-Digit Security PIN'),
                    TextField(
                      controller: _pinController,
                      obscureText: _obscurePin,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 8,
                      ),
                      decoration: _inputDecoration(
                        hint: '••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePin ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF94A3B8),
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePin = !_obscurePin),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 13, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Do not use your Airtel Money, MTN MoMo, or bank PIN.',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: const Color(0xFFFBBF24),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Confirm 4-Digit Security PIN Field
                    _buildFieldLabel('Confirm 4-Digit Security PIN'),
                    TextField(
                      controller: _confirmPinController,
                      obscureText: _obscurePin,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 8,
                      ),
                      decoration: _inputDecoration(
                        hint: '••••',
                        prefixIcon: Icons.lock_reset_rounded,
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B0A0A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFF334B)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Color(0xFFFF334B), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: const Color(0xFFFF8080),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Submit Button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF88).withValues(alpha: 0.3),
                            blurRadius: 18,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E676),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _handleRegister,
                        child: Text(
                          'Create Account & Enter Shield',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Already registered link
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const PinLoginScreen()),
                            );
                          },
                          child: Text(
                            'Sign In with PIN',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.absaCoral,
                            ),
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
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFCBD5E1),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: AppTheme.surfaceDark,
      hintText: hint,
      counterText: '',
      hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSubtle),
      prefixIcon: Icon(prefixIcon, size: 20, color: AppTheme.textSubtle),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.surfaceBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.surfaceBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.absaRed, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
