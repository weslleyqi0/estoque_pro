import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../service/auth_service.dart';
import '../service/biometric_service.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthService _authService;
  final BiometricService _biometricService;

  bool _isBiometricAuthenticated = false;
  DateTime? _backgroundTimestamp;
  User? _previousUser;

  AuthRepositoryImpl(this._authService, this._biometricService) {
    _previousUser = _authService.currentUser;

    _authService.authStateChanges.listen((user) {
      if (user == null) {
        setBiometricAuthenticated(false);
      } else if (_previousUser == null) {
        setBiometricAuthenticated(true);
      }
      _previousUser = user;
      notifyListeners();
    });

    if (_authService.currentUser != null) {
      _isBiometricAuthenticated = false;
    }
  }

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  @override
  User? get currentUser => _authService.currentUser;

  @override
  bool get isBiometricAuthenticated => _isBiometricAuthenticated;

  @override
  void setBiometricAuthenticated(bool isAuthenticated) {
    if (_isBiometricAuthenticated != isAuthenticated) {
      _isBiometricAuthenticated = isAuthenticated;
      notifyListeners();
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    setBiometricAuthenticated(true);
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
    setBiometricAuthenticated(false);
  }

  @override
  Future<bool> isBiometricAvailable() => _biometricService.isBiometricAvailable();

  @override
  Future<bool> authenticateWithBiometrics() async {
    final authenticated = await _biometricService.authenticateWithBiometrics();
    setBiometricAuthenticated(authenticated);
    return authenticated;
  }

  @override
  DateTime? get backgroundTimestamp => _backgroundTimestamp;

  @override
  set backgroundTimestamp(DateTime? value) {
    _backgroundTimestamp = value;
  }

  @override
  void appWentToBackground() {
    if (isBiometricAuthenticated) {
      _backgroundTimestamp ??= DateTime.now();
    }
  }

  @override
  void appReturnedToForeground() {
    if (_backgroundTimestamp != null) {
      final difference = DateTime.now().difference(_backgroundTimestamp!);
      if (difference.inMinutes >= 2) {
        setBiometricAuthenticated(false);
      }
      _backgroundTimestamp = null;
    }
  }
}
