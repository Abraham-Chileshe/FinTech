import 'package:flutter/foundation.dart';

class UserAccount {
  final String name;
  final String phoneNumber;
  final String pin;

  const UserAccount({
    required this.name,
    required this.phoneNumber,
    required this.pin,
  });
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    // Seed with a default demo user so judges or developers can quickly sign in or re-register
    _currentUser = const UserAccount(
      name: 'Chileshe Mwamba',
      phoneNumber: '+260 977 123456',
      pin: '1234',
    );
    _isRegistered = true;
    _isAuthenticated = false; // Must enter PIN first!
  }

  UserAccount? _currentUser;
  bool _isRegistered = true;
  bool _isAuthenticated = false;

  UserAccount? get currentUser => _currentUser;
  bool get isRegistered => _isRegistered;
  bool get isAuthenticated => _isAuthenticated;

  void register({
    required String name,
    required String phoneNumber,
    required String pin,
  }) {
    _currentUser = UserAccount(
      name: name.trim(),
      phoneNumber: phoneNumber.trim(),
      pin: pin.trim(),
    );
    _isRegistered = true;
    _isAuthenticated = true;
    notifyListeners();
  }

  bool verifyPin(String enteredPin) {
    if (_currentUser == null) return false;
    final isValid = _currentUser!.pin == enteredPin.trim();
    if (isValid) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return isValid;
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  void resetDemo() {
    _currentUser = const UserAccount(
      name: 'Chileshe Mwamba',
      phoneNumber: '+260 977 123456',
      pin: '1234',
    );
    _isRegistered = true;
    _isAuthenticated = false;
    notifyListeners();
  }

  void resetToNewUser() {
    _currentUser = null;
    _isRegistered = false;
    _isAuthenticated = false;
    notifyListeners();
  }
}
