import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late BiometricViewModel viewModel;

  setUp(() async {
    mockAuthRepository = MockAuthRepository();

    // Stub ChangeNotifier and properties to prevent Mocktail errors
    when(() => mockAuthRepository.addListener(any())).thenAnswer((_) {});
    when(() => mockAuthRepository.removeListener(any())).thenAnswer((_) {});
    when(() => mockAuthRepository.isBiometricEnabled).thenReturn(true);

    await getIt.reset();
    getIt.registerLazySingleton<AuthRepository>(() => mockAuthRepository);

    viewModel = BiometricViewModel(getIt<AuthRepository>());
  });

  group('BiometricViewModel Tests', () {
    test('isBiometricEnabled returns value from repository', () {
      when(() => mockAuthRepository.isBiometricEnabled).thenReturn(true);
      expect(viewModel.isBiometricEnabled, isTrue);

      when(() => mockAuthRepository.isBiometricEnabled).thenReturn(false);
      expect(viewModel.isBiometricEnabled, isFalse);
    });

    test('setBiometricEnabled delegates to repository', () async {
      when(() => mockAuthRepository.setBiometricEnabled(any())).thenAnswer((_) async {});

      await viewModel.setBiometricEnabled(true);
      verify(() => mockAuthRepository.setBiometricEnabled(true)).called(1);

      await viewModel.setBiometricEnabled(false);
      verify(() => mockAuthRepository.setBiometricEnabled(false)).called(1);
    });

    test('isAvailable returns correct state from repository', () async {
      when(() => mockAuthRepository.isBiometricAvailable()).thenAnswer((_) async => true);
      expect(await viewModel.isAvailable(), isTrue);

      when(() => mockAuthRepository.isBiometricAvailable()).thenAnswer((_) async => false);
      expect(await viewModel.isAvailable(), isFalse);
    });

    test('authenticateCommand success updates isBiometricAuthenticated to true', () async {
      when(() => mockAuthRepository.authenticateWithBiometrics()).thenAnswer((_) async => true);

      await viewModel.authenticateCommand.execute();

      verify(() => mockAuthRepository.authenticateWithBiometrics()).called(1);
      expect(viewModel.authenticateCommand.isSuccess, isTrue);
      expect(viewModel.authenticateCommand.value, isTrue);
    });

    test('authenticateCommand failure keeps isBiometricAuthenticated as false', () async {
      when(() => mockAuthRepository.authenticateWithBiometrics()).thenAnswer((_) async => false);

      await viewModel.authenticateCommand.execute();

      verify(() => mockAuthRepository.authenticateWithBiometrics()).called(1);
      expect(viewModel.authenticateCommand.isSuccess, isTrue);
      expect(viewModel.authenticateCommand.value, isFalse);
    });

    test('authenticateCommand error sets command to failure state', () async {
      final exception = Exception('biometric failed');
      when(() => mockAuthRepository.authenticateWithBiometrics()).thenThrow(exception);

      await viewModel.authenticateCommand.execute();

      expect(viewModel.authenticateCommand.isFailure, isTrue);
      expect(viewModel.authenticateCommand.error, equals(exception));
    });

    test('app lifecycle transition to paused calls appWentToBackground on repository', () {
      when(() => mockAuthRepository.appWentToBackground()).thenAnswer((_) {});

      viewModel.didChangeAppLifecycleState(AppLifecycleState.paused);

      verify(() => mockAuthRepository.appWentToBackground()).called(1);
    });

    test('app lifecycle transition to resumed calls appReturnedToForeground on repository', () {
      when(() => mockAuthRepository.appReturnedToForeground()).thenAnswer((_) {});

      viewModel.didChangeAppLifecycleState(AppLifecycleState.resumed);

      verify(() => mockAuthRepository.appReturnedToForeground()).called(1);
    });

    test('checkAvailability when biometric is disabled sets isBiometricAuthenticated to true directly', () async {
      when(() => mockAuthRepository.isBiometricEnabled).thenReturn(false);
      when(() => mockAuthRepository.setBiometricAuthenticated(any())).thenAnswer((_) {});

      await viewModel.checkAvailability();

      verify(() => mockAuthRepository.setBiometricAuthenticated(true)).called(1);
      verifyNever(() => mockAuthRepository.isBiometricAvailable());
      verifyNever(() => mockAuthRepository.authenticateWithBiometrics());
    });

    test('checkAvailability when biometric is unavailable sets isBiometricAuthenticated to true', () async {
      when(() => mockAuthRepository.isBiometricEnabled).thenReturn(true);
      when(() => mockAuthRepository.isBiometricAvailable()).thenAnswer((_) async => false);
      when(() => mockAuthRepository.setBiometricAuthenticated(any())).thenAnswer((_) {});

      await viewModel.checkAvailability();

      verify(() => mockAuthRepository.setBiometricAuthenticated(true)).called(1);
      verifyNever(() => mockAuthRepository.authenticateWithBiometrics());
    });

    test('checkAvailability when biometric is available triggers authenticateWithBiometrics', () async {
      when(() => mockAuthRepository.isBiometricEnabled).thenReturn(true);
      when(() => mockAuthRepository.isBiometricAvailable()).thenAnswer((_) async => true);
      when(() => mockAuthRepository.authenticateWithBiometrics()).thenAnswer((_) async => true);

      await viewModel.checkAvailability();

      verify(() => mockAuthRepository.authenticateWithBiometrics()).called(1);
    });

    test('usePassword executes signOut on AuthRepository', () async {
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

      await viewModel.usePassword();

      verify(() => mockAuthRepository.signOut()).called(1);
    });
  });
}
