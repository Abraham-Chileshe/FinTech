import 'package:flutter/material.dart';
import 'screens/pin_login_screen.dart';
import 'screens/register_screen.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MundaFraudShieldApp());
}

class MundaFraudShieldApp extends StatelessWidget {
  const MundaFraudShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final themeService = ThemeService();

    return AnimatedBuilder(
      animation: themeService,
      builder: (context, _) {
        return MaterialApp(
          title: 'Munda AI Fraud Shield',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode,
          home: auth.isRegistered ? const PinLoginScreen() : const RegisterScreen(),
        );
      },
    );
  }
}
