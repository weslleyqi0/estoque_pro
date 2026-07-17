import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/features/auth/data/service/biometric_service.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBiometricService extends Mock implements BiometricService {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late MockBiometricService mockBiometricService;
  late BiometricViewModel viewModel;

  setUp(() async {
    mockBiometricService = MockBiometricService();
    // We register the dependency manually for tests.
    // Ensure getIt is clean before registering.
    await getIt.reset();
    getIt.registerLazySingleton<BiometricService>(() => mockBiometricService);

    viewModel = BiometricViewModel();
  });

  group('BiometricViewModel Tests', () {
    test('isAvailable returns correct state from service', () async {

      when(() => mockBiometricService.isBiometricAvailable()).thenAnswer((_) async => true);
      expect(await viewModel.isAvailable(), isTrue);

      when(() => mockBiometricService.isBiometricAvailable()).thenAnswer((_) async => false);
      expect(await viewModel.isAvailable(), isFalse);
    });

    test('authenticateCommand success updates isBiometricAuthenticated to true', () async {

      when(() => mockBiometricService.authenticateWithBiometrics()).thenAnswer((_) async => true);

      await viewModel.authenticateCommand.execute();

      expect(viewModel.isBiometricAuthenticated, isTrue);
      expect(viewModel.authenticateCommand.isSuccess, isTrue);
      expect(viewModel.authenticateCommand.value, isTrue);
    });

    test('authenticateCommand failure keeps isBiometricAuthenticated as false', () async {

      when(() => mockBiometricService.authenticateWithBiometrics()).thenAnswer((_) async => false);

      await viewModel.authenticateCommand.execute();

      expect(viewModel.isBiometricAuthenticated, isFalse);
      expect(viewModel.authenticateCommand.isSuccess, isTrue);
      expect(viewModel.authenticateCommand.value, isFalse);
    });

    test('authenticateCommand error sets command to failure state', () async {
      final exception = Exception('biometric failed');

      when(() => mockBiometricService.authenticateWithBiometrics()).thenThrow(exception);

      await viewModel.authenticateCommand.execute();

      expect(viewModel.isBiometricAuthenticated, isFalse);
      expect(viewModel.authenticateCommand.isFailure, isTrue);
      expect(viewModel.authenticateCommand.error, equals(exception));
    });

    test('setBiometricAuthenticated updates authenticated status and notifies listeners', () {
      var listenerCalled = false;

      viewModel.addListener(() {
        listenerCalled = true;
      });

      viewModel.setBiometricAuthenticated(true);

      expect(viewModel.isBiometricAuthenticated, isTrue);
      expect(listenerCalled, isTrue);
    });

    test('app lifecycle transition to paused sets backgroundTimestamp if authenticated', () {
      viewModel.setBiometricAuthenticated(true);
      expect(viewModel.backgroundTimestamp, isNull);

      viewModel.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(viewModel.backgroundTimestamp, isNotNull);
    });

    test('app lifecycle transition to paused does not set backgroundTimestamp if not authenticated', () {
      viewModel.setBiometricAuthenticated(false);
      expect(viewModel.backgroundTimestamp, isNull);

      viewModel.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(viewModel.backgroundTimestamp, isNull);
    });

    test('app lifecycle transition to resumed locks app if 2 minutes or more passed in background', () {
      viewModel.setBiometricAuthenticated(true);
      
      // Simulate app paused 2 minutes ago
      viewModel.backgroundTimestamp = DateTime.now().subtract(const Duration(minutes: 2));

      viewModel.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(viewModel.isBiometricAuthenticated, isFalse);
      expect(viewModel.backgroundTimestamp, isNull);
    });

    test('app lifecycle transition to resumed keeps app unlocked if less than 2 minutes passed in background', () {
      viewModel.setBiometricAuthenticated(true);
      
      // Simulate app paused 1 minute and 59 seconds ago
      viewModel.backgroundTimestamp = DateTime.now().subtract(const Duration(minutes: 1, seconds: 59));

      viewModel.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(viewModel.isBiometricAuthenticated, isTrue);
      expect(viewModel.backgroundTimestamp, isNull);
    });

    test('checkAvailability when biometric is unavailable sets isBiometricAuthenticated to true', () async {
      when(() => mockBiometricService.isBiometricAvailable()).thenAnswer((_) async => false);

      await viewModel.checkAvailability();

      expect(viewModel.isBiometricAuthenticated, isTrue);
      verifyNever(() => mockBiometricService.authenticateWithBiometrics());
    });

    test('checkAvailability when biometric is available triggers authenticateWithBiometrics', () async {
      when(() => mockBiometricService.isBiometricAvailable()).thenAnswer((_) async => true);
      when(() => mockBiometricService.authenticateWithBiometrics()).thenAnswer((_) async => true);

      await viewModel.checkAvailability();

      expect(viewModel.isBiometricAuthenticated, isTrue);
      verify(() => mockBiometricService.authenticateWithBiometrics()).called(1);
    });
  });
}
