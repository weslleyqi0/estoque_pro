import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/auth/domain/entities/auth_user_entity.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';

class AuthViewModel extends BaseViewModel {
  final AuthRepository _authRepository;
  final AuthorizationService _authorizationService;

  AuthUserEntity? get authenticatedUser => _authRepository.currentUser;
  bool get isBiometricAuthenticated => _authRepository.isBiometricAuthenticated;

  UserEntity? get currentUser => _authorizationService.currentUser;
  bool get isAuthenticated => _authorizationService.isAuthenticated;

  late final Command1<bool, ({String email, String password})> loginCommand;
  late final Command0<bool> logoutCommand;

  AuthViewModel(
    this._authRepository,
    this._authorizationService,
  ) {
    _authRepository.addListener(notifyListeners);
    _authorizationService.addListener(notifyListeners);

    loginCommand = Command1((credentials) async {
      final result = await _authRepository.signIn(
        credentials.email,
        credentials.password,
      );
      if (result.isFailure) {
        return Failure(result.error!);
      }
      return const Success(true);
    });

    logoutCommand = Command0(() async {
      final result = await _authRepository.signOut();
      if (result.isFailure) {
        return Failure(result.error!);
      }
      return const Success(true);
    });
  }

  void setBiometricAuthenticated(bool value) {
    _authRepository.setBiometricAuthenticated(value);
  }

  @override
  void dispose() {
    _authRepository.removeListener(notifyListeners);
    _authorizationService.removeListener(notifyListeners);
    super.dispose();
  }
}
