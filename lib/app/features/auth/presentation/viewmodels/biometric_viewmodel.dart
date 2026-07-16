import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/auth/data/service/biometric_service.dart';
import 'package:flutter/foundation.dart';

class BiometricViewModel extends ChangeNotifier {
  final BiometricService _biometricService = getIt<BiometricService>();

  bool _isBiometricAuthenticated = false;
  bool get isBiometricAuthenticated => _isBiometricAuthenticated;

  late final Command0<bool> authenticateCommand;

  BiometricViewModel() {
    authenticateCommand = Command0(() async {
      try {
        final authenticated = await _biometricService.authenticateWithBiometrics();
        setBiometricAuthenticated(authenticated);
        return Result.success(authenticated);
      } catch (error) {
        return Result.failure(error);
      }
    });
  }

  Future<bool> isAvailable() => _biometricService.isBiometricAvailable();

  void setBiometricAuthenticated(bool value) {
    if (_isBiometricAuthenticated != value) {
      _isBiometricAuthenticated = value;
      notifyListeners();
    }
  }
}
