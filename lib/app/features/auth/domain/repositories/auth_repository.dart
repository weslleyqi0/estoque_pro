import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/auth/domain/entities/auth_user_entity.dart';
import 'package:flutter/foundation.dart';

abstract class AuthRepository extends ChangeNotifier {
  Stream<AuthUserEntity?> get authStateChanges;
  AuthUserEntity? get currentUser;

  bool get isBiometricEnabled;
  Future<void> setBiometricEnabled(bool enabled);

  bool get isBiometricAuthenticated;
  void setBiometricAuthenticated(bool isAuthenticated);

  Future<Result<void>> signIn(String email, String password);
  Future<Result<void>> signOut();

  Future<bool> isBiometricAvailable();
  Future<bool> authenticateWithBiometrics();

  DateTime? get backgroundTimestamp;
  set backgroundTimestamp(DateTime? value);
  void appWentToBackground();
  void appReturnedToForeground();
}
