import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  final _authRepository = getIt<AuthRepository>();

  User? get currentUser => _authRepository.currentUser;
  bool get isBiometricAuthenticated => _authRepository.isBiometricAuthenticated;

  late final Command1<bool, ({String email, String password})> loginCommand;
  late final Command0<bool> logoutCommand;

  AuthViewModel() {
    _authRepository.addListener(notifyListeners);

    loginCommand = Command1((credentials) async {
      try {
        await _authRepository.signIn(
          credentials.email,
          credentials.password,
        );
        return const Success(true);
      } on FirebaseAuthException catch (e) {
        return Failure(Exception(e.message ?? 'Ocorreu um erro desconhecido'));
      } catch (e) {
        return Failure(Exception(e.toString()));
      }
    });

    logoutCommand = Command0(() async {
      try {
        await _authRepository.signOut();
        return const Success(true);
      } catch (e) {
        return Failure(Exception(e.toString()));
      }
    });
  }

  void setBiometricAuthenticated(bool value) {
    _authRepository.setBiometricAuthenticated(value);
  }

  @override
  void dispose() {
    _authRepository.removeListener(notifyListeners);
    super.dispose();
  }
}
