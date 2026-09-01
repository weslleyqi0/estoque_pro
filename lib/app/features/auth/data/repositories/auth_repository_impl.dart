import 'dart:async';
import 'package:estoque_pro/app/core/services/local_storage_service.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/auth/domain/entities/auth_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../service/auth_service.dart';
import '../service/biometric_service.dart';

class AuthRepositoryImpl extends AuthRepository {
  static const String _biometricEnabledKey = 'is_biometric_enabled';

  final AuthService _authService;
  final BiometricService _biometricService;
  final LocalStorageService _localStorageService;

  bool _isBiometricEnabled = false;
  bool _isBiometricAuthenticated = false;
  DateTime? _backgroundTimestamp;
  AuthUserEntity? _previousUser;

  AuthRepositoryImpl(
    this._authService,
    this._biometricService,
    this._localStorageService,
  ) {
    _isBiometricEnabled = _localStorageService.getBool(_biometricEnabledKey, defaultValue: false);
    _previousUser = _authService.currentUser;

    if (_authService.currentUser != null) {
      _isBiometricAuthenticated = !_isBiometricEnabled;
    }

    _authService.authStateChanges.listen((user) {
      if (user == null) {
        setBiometricAuthenticated(false);
      } else if (_previousUser == null) {
        setBiometricAuthenticated(true);
      }
      _previousUser = user;
      notifyListeners();
    });
  }

  @override
  Stream<AuthUserEntity?> get authStateChanges => _authService.authStateChanges;

  @override
  AuthUserEntity? get currentUser => _authService.currentUser;

  @override
  bool get isBiometricEnabled => _isBiometricEnabled;

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    _isBiometricEnabled = enabled;
    await _localStorageService.setBool(_biometricEnabledKey, enabled);
    if (!enabled) {
      setBiometricAuthenticated(true);
    }
    notifyListeners();
  }

  @override
  bool get isBiometricAuthenticated => !_isBiometricEnabled || _isBiometricAuthenticated;

  @override
  void setBiometricAuthenticated(bool isAuthenticated) {
    if (_isBiometricAuthenticated != isAuthenticated) {
      _isBiometricAuthenticated = isAuthenticated;
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> signIn(String email, String password) async {
    final result = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (result.isSuccess) {
      setBiometricAuthenticated(true);
      return const Result.success(null);
    }
    return Result.failure(result.error!);
  }

  @override
  Future<Result<void>> signOut() async {
    final result = await _authService.signOut();
    if (result.isSuccess) {
      setBiometricAuthenticated(false);
      return const Result.success(null);
    }
    return Result.failure(result.error!);
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
    if (_isBiometricEnabled && isBiometricAuthenticated) {
      _backgroundTimestamp ??= DateTime.now();
    }
  }

  @override
  void appReturnedToForeground() {
    if (_isBiometricEnabled && _backgroundTimestamp != null) {
      final difference = DateTime.now().difference(_backgroundTimestamp!);
      if (difference.inMinutes >= 2) {
        setBiometricAuthenticated(false);
      }
      _backgroundTimestamp = null;
    } else {
      _backgroundTimestamp = null;
    }
  }
}
