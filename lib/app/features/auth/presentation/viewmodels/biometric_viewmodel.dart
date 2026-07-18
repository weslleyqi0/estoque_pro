import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/auth/data/service/biometric_service.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter/widgets.dart';

class BiometricViewModel extends ChangeNotifier with WidgetsBindingObserver {
  final _biometricService = getIt<BiometricService>();
  final _authViewModel = getIt<AuthViewModel>();

  DateTime? _backgroundTimestamp;

  @visibleForTesting
  DateTime? get backgroundTimestamp => _backgroundTimestamp;

  @visibleForTesting
  set backgroundTimestamp(DateTime? value) => _backgroundTimestamp = value;

  late final Command0<bool> authenticateCommand;

  BiometricViewModel() {
    WidgetsBinding.instance.addObserver(this);
    authenticateCommand = Command0(
      () => Result.guard(() async {
        final authenticated = await _biometricService.authenticateWithBiometrics();
        _authViewModel.setBiometricAuthenticated(authenticated);
        return authenticated;
      }),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_authViewModel.isBiometricAuthenticated) {
        _backgroundTimestamp ??= DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTimestamp != null) {
        final difference = DateTime.now().difference(_backgroundTimestamp!);
        if (difference.inMinutes >= 2) {
          _authViewModel.setBiometricAuthenticated(false);
        }
        _backgroundTimestamp = null;
      }
    }
  }

  Future<bool> isAvailable() => _biometricService.isBiometricAvailable();

  Future<void> checkAvailability() async {
    final available = await isAvailable();
    if (!available) {
      _authViewModel.setBiometricAuthenticated(true);
    } else {
      await authenticateCommand.execute();
    }
  }

  Future<void> usePassword() async {
    await _authViewModel.logoutCommand.execute();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
