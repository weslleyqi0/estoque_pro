import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/widgets.dart';

class BiometricViewModel extends ChangeNotifier with WidgetsBindingObserver {
  final AuthRepository _authRepository;

  @visibleForTesting
  DateTime? get backgroundTimestamp => _authRepository.backgroundTimestamp;

  @visibleForTesting
  set backgroundTimestamp(DateTime? value) => _authRepository.backgroundTimestamp = value;

  late final Command0<bool> authenticateCommand;

  bool get isBiometricEnabled => _authRepository.isBiometricEnabled;

  BiometricViewModel(this._authRepository) {
    WidgetsBinding.instance.addObserver(this);
    _authRepository.addListener(notifyListeners);

    authenticateCommand = Command0(
      () => Result.guard(() async {
        return await _authRepository.authenticateWithBiometrics();
      }),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _authRepository.appWentToBackground();
    } else if (state == AppLifecycleState.resumed) {
      _authRepository.appReturnedToForeground();
    }
  }

  Future<bool> isAvailable() => _authRepository.isBiometricAvailable();

  Future<void> setBiometricEnabled(bool enabled) async {
    await _authRepository.setBiometricEnabled(enabled);
  }

  Future<void> checkAvailability() async {
    if (!_authRepository.isBiometricEnabled) {
      _authRepository.setBiometricAuthenticated(true);
      return;
    }

    final available = await isAvailable();
    if (!available) {
      _authRepository.setBiometricAuthenticated(true);
    } else {
      await authenticateCommand.execute();
    }
  }

  Future<void> usePassword() async {
    await _authRepository.signOut();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authRepository.removeListener(notifyListeners);
    super.dispose();
  }
}
