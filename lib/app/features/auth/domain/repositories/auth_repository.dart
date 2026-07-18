import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class AuthRepository extends ChangeNotifier {
  Stream<User?> get authStateChanges;
  User? get currentUser;

  bool get isBiometricAuthenticated;
  void setBiometricAuthenticated(bool isAuthenticated);

  Future<void> signIn(String email, String password);
  Future<void> signOut();

  Future<bool> isBiometricAvailable();
  Future<bool> authenticateWithBiometrics();

  DateTime? get backgroundTimestamp;
  set backgroundTimestamp(DateTime? value);
  void appWentToBackground();
  void appReturnedToForeground();
}
