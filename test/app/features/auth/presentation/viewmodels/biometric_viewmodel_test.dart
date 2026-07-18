import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/features/auth/data/service/biometric_service.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBiometricService extends Mock implements BiometricService {}
class MockAuthViewModel extends Mock implements AuthViewModel {}
class MockCommand0<Output extends Object> extends Mock implements Command0<Output> {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late MockBiometricService mockBiometricService;
  late MockAuthViewModel mockAuthViewModel;
  late BiometricViewModel viewModel;

  setUp(() async {
    mockBiometricService = MockBiometricService();
    mockAuthViewModel = MockAuthViewModel();
    
    await getIt.reset();
    getIt.registerLazySingleton<BiometricService>(() => mockBiometricService);
    getIt.registerLazySingleton<AuthViewModel>(() => mockAuthViewModel);

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
      when(() => mockAuthViewModel.setBiometricAuthenticated(any())).thenAnswer((_) {});

      await viewModel.authenticateCommand.execute();

      verify(() => mockAuthViewModel.setBiometricAuthenticated(true)).called(1);
      expect(viewModel.authenticateCommand.isSuccess, isTrue);
      expect(viewModel.authenticateCommand.value, isTrue);
    });

    test('authenticateCommand failure keeps isBiometricAuthenticated as false', () async {
      when(() => mockBiometricService.authenticateWithBiometrics()).thenAnswer((_) async => false);
      when(() => mockAuthViewModel.setBiometricAuthenticated(any())).thenAnswer((_) {});

      await viewModel.authenticateCommand.execute();

      verify(() => mockAuthViewModel.setBiometricAuthenticated(false)).called(1);
      expect(viewModel.authenticateCommand.isSuccess, isTrue);
      expect(viewModel.authenticateCommand.value, isFalse);
    });

    test('authenticateCommand error sets command to failure state', () async {
      final exception = Exception('biometric failed');
      when(() => mockBiometricService.authenticateWithBiometrics()).thenThrow(exception);

      await viewModel.authenticateCommand.execute();

      expect(viewModel.authenticateCommand.isFailure, isTrue);
      expect(viewModel.authenticateCommand.error, equals(exception));
    });

    test('app lifecycle transition to paused sets backgroundTimestamp if authenticated', () {
      when(() => mockAuthViewModel.isBiometricAuthenticated).thenReturn(true);
      expect(viewModel.backgroundTimestamp, isNull);

      viewModel.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(viewModel.backgroundTimestamp, isNotNull);
    });

    test('app lifecycle transition to paused does not set backgroundTimestamp if not authenticated', () {
      when(() => mockAuthViewModel.isBiometricAuthenticated).thenReturn(false);
      expect(viewModel.backgroundTimestamp, isNull);

      viewModel.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(viewModel.backgroundTimestamp, isNull);
    });

    test('app lifecycle transition to resumed locks app if 2 minutes or more passed in background', () {
      when(() => mockAuthViewModel.isBiometricAuthenticated).thenReturn(true);
      when(() => mockAuthViewModel.setBiometricAuthenticated(any())).thenAnswer((_) {});
      
      // Simulate app paused 2 minutes ago
      viewModel.backgroundTimestamp = DateTime.now().subtract(const Duration(minutes: 2));

      viewModel.didChangeAppLifecycleState(AppLifecycleState.resumed);

      verify(() => mockAuthViewModel.setBiometricAuthenticated(false)).called(1);
      expect(viewModel.backgroundTimestamp, isNull);
    });

    test('app lifecycle transition to resumed keeps app unlocked if less than 2 minutes passed in background', () {
      when(() => mockAuthViewModel.isBiometricAuthenticated).thenReturn(true);
      
      // Simulate app paused 1 minute and 59 seconds ago
      viewModel.backgroundTimestamp = DateTime.now().subtract(const Duration(minutes: 1, seconds: 59));

      viewModel.didChangeAppLifecycleState(AppLifecycleState.resumed);

      verifyNever(() => mockAuthViewModel.setBiometricAuthenticated(any()));
      expect(viewModel.backgroundTimestamp, isNull);
    });

    test('checkAvailability when biometric is unavailable sets isBiometricAuthenticated to true', () async {
      when(() => mockBiometricService.isBiometricAvailable()).thenAnswer((_) async => false);
      when(() => mockAuthViewModel.setBiometricAuthenticated(any())).thenAnswer((_) {});

      await viewModel.checkAvailability();

      verify(() => mockAuthViewModel.setBiometricAuthenticated(true)).called(1);
      verifyNever(() => mockBiometricService.authenticateWithBiometrics());
    });

    test('checkAvailability when biometric is available triggers authenticateWithBiometrics', () async {
      when(() => mockBiometricService.isBiometricAvailable()).thenAnswer((_) async => true);
      when(() => mockBiometricService.authenticateWithBiometrics()).thenAnswer((_) async => true);
      when(() => mockAuthViewModel.setBiometricAuthenticated(any())).thenAnswer((_) {});

      await viewModel.checkAvailability();

      verify(() => mockAuthViewModel.setBiometricAuthenticated(true)).called(1);
      verify(() => mockBiometricService.authenticateWithBiometrics()).called(1);
    });

    test('usePassword executes logoutCommand on AuthViewModel', () async {
      final mockLogoutCommand = MockCommand0<bool>();
      when(() => mockAuthViewModel.logoutCommand).thenReturn(mockLogoutCommand);
      when(() => mockLogoutCommand.execute()).thenAnswer((_) async {});

      await viewModel.usePassword();

      verify(() => mockAuthViewModel.logoutCommand).called(1);
      verify(() => mockLogoutCommand.execute()).called(1);
    });
  });
}
