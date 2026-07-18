import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/auth/data/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  final _authService = getIt<AuthService>();

  User? _currentUser = getIt<AuthService>().currentUser;
  User? get currentUser => _currentUser;

  bool _isBiometricAuthenticated = false;
  bool get isBiometricAuthenticated => _isBiometricAuthenticated;

  late final Command1<bool, (String, String)> loginCommand;
  late final Command0<bool> logoutCommand;

  AuthViewModel() {
    loginCommand = Command1((credentials) async {
      try {
        await _authService.signInWithEmailAndPassword(
          email: credentials.$1,
          password: credentials.$2,
        );
        _isBiometricAuthenticated = true;
        notifyListeners();
        return const Success(true);
      } on FirebaseAuthException catch (e) {
        return Failure(Exception(e.message ?? 'Ocorreu um erro desconhecido'));
      } catch (e) {
        return Failure(Exception(e.toString()));
      }
    });

    logoutCommand = Command0(() async {
      try {
        await _authService.signOut();
        _isBiometricAuthenticated = false;
        notifyListeners();
        return const Success(true);
      } catch (e) {
        return Failure(Exception(e.toString()));
      }
    });

    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      if (user == null) {
        _isBiometricAuthenticated = false;
      }
      notifyListeners();
    });

    if (_currentUser != null) {
      _isBiometricAuthenticated = false;
    }
  }

  void setBiometricAuthenticated(bool value) {
    _isBiometricAuthenticated = value;
    notifyListeners();
  }
}
