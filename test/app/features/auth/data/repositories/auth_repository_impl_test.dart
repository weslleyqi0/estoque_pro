import 'dart:async';
import 'package:estoque_pro/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:estoque_pro/app/features/auth/data/service/auth_service.dart';
import 'package:estoque_pro/app/features/auth/data/service/biometric_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}
class MockBiometricService extends Mock implements BiometricService {}
class MockUser extends Mock implements User {}

void main() {
  late MockAuthService mockAuthService;
  late MockBiometricService mockBiometricService;
  late StreamController<User?> authStateController;

  setUp(() {
    mockAuthService = MockAuthService();
    mockBiometricService = MockBiometricService();
    authStateController = StreamController<User?>.broadcast();
    
    when(() => mockAuthService.authStateChanges).thenAnswer((_) => authStateController.stream);
    when(() => mockAuthService.currentUser).thenReturn(null);
  });

  tearDown(() {
    authStateController.close();
  });

  group('AuthRepositoryImpl Background Timeout Tests', () {
    test('appWentToBackground sets timestamp if biometric authenticated', () {
      final authRepository = AuthRepositoryImpl(mockAuthService, mockBiometricService);
      authRepository.setBiometricAuthenticated(true);
      expect(authRepository.backgroundTimestamp, isNull);

      authRepository.appWentToBackground();

      expect(authRepository.backgroundTimestamp, isNotNull);
    });

    test('appWentToBackground does not set timestamp if not biometric authenticated', () {
      final authRepository = AuthRepositoryImpl(mockAuthService, mockBiometricService);
      authRepository.setBiometricAuthenticated(false);
      expect(authRepository.backgroundTimestamp, isNull);

      authRepository.appWentToBackground();

      expect(authRepository.backgroundTimestamp, isNull);
    });

    test('appReturnedToForeground locks session if 2 minutes or more passed in background', () {
      final authRepository = AuthRepositoryImpl(mockAuthService, mockBiometricService);
      authRepository.setBiometricAuthenticated(true);
      authRepository.backgroundTimestamp = DateTime.now().subtract(const Duration(minutes: 2));

      authRepository.appReturnedToForeground();

      expect(authRepository.isBiometricAuthenticated, isFalse);
      expect(authRepository.backgroundTimestamp, isNull);
    });

    test('appReturnedToForeground keeps session unlocked if less than 2 minutes passed', () {
      final authRepository = AuthRepositoryImpl(mockAuthService, mockBiometricService);
      authRepository.setBiometricAuthenticated(true);
      authRepository.backgroundTimestamp = DateTime.now().subtract(const Duration(minutes: 1, seconds: 59));

      authRepository.appReturnedToForeground();

      expect(authRepository.isBiometricAuthenticated, isTrue);
      expect(authRepository.backgroundTimestamp, isNull);
    });
  });

  group('AuthRepositoryImpl Biometric Authentication State Transitions', () {
    test('when constructed with no user, isBiometricAuthenticated starts as false', () {
      final authRepository = AuthRepositoryImpl(mockAuthService, mockBiometricService);
      expect(authRepository.isBiometricAuthenticated, isFalse);
    });

    test('when constructed with existing user, isBiometricAuthenticated starts as false', () {
      when(() => mockAuthService.currentUser).thenReturn(MockUser());
      final authRepository = AuthRepositoryImpl(mockAuthService, mockBiometricService);
      expect(authRepository.isBiometricAuthenticated, isFalse);
    });

    test('transition from logged out to logged in sets isBiometricAuthenticated to true', () async {
      final authRepository = AuthRepositoryImpl(mockAuthService, mockBiometricService);
      expect(authRepository.isBiometricAuthenticated, isFalse);

      // Trigger log in
      authStateController.add(MockUser());
      await Future.delayed(Duration.zero);

      expect(authRepository.isBiometricAuthenticated, isTrue);
    });

    test('transition from logged in to logged out sets isBiometricAuthenticated to false', () async {
      when(() => mockAuthService.currentUser).thenReturn(MockUser());
      final authRepository = AuthRepositoryImpl(mockAuthService, mockBiometricService);
      authRepository.setBiometricAuthenticated(true);

      // Trigger log out
      authStateController.add(null);
      await Future.delayed(Duration.zero);

      expect(authRepository.isBiometricAuthenticated, isFalse);
    });
  });
}
