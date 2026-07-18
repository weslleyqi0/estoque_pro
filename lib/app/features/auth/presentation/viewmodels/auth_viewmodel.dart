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
        final message = switch (e.code) {
          'user-not-found' || 'wrong-password' || 'invalid-credential' => 'E-mail ou senha incorretos.',
          'invalid-email' => 'O formato do e-mail é inválido.',
          'user-disabled' => 'Esta conta de usuário foi desativada.',
          'too-many-requests' => 'Muitas tentativas bloqueadas. Tente novamente mais tarde.',
          'network-request-failed' => 'Falha na conexão de rede. Verifique sua conexão com a internet.',
          _ => e.message ?? 'Ocorreu um erro ao realizar o login.',
        };
        return Failure(Exception(message));
      } catch (e) {
        return Failure(Exception('Erro inesperado!'));
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
