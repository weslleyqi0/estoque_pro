import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/core/router/auth_redirect_policy.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}
class MockBuildContext extends Mock implements BuildContext {}
class MockGoRouterState extends Mock implements GoRouterState {}

void main() {
  late MockAuthViewModel mockAuthViewModel;
  late MockBuildContext mockContext;
  late MockGoRouterState mockState;
  late AuthRedirectPolicy policy;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    mockContext = MockBuildContext();
    mockState = MockGoRouterState();
    policy = const AuthRedirectPolicy();
  });

  void mockRoute(String path) {
    when(() => mockState.uri).thenReturn(Uri.parse(path));
  }

  const activeAdmin = UserEntity(
    uid: 'admin-1',
    name: 'Admin',
    email: 'admin@test.com',
    role: UserRole.admin,
    permissions: {},
    isActive: true,
  );

  const activeSeller = UserEntity(
    uid: 'seller-1',
    name: 'Seller',
    email: 'seller@test.com',
    role: UserRole.seller,
    permissions: {UserPermission.deliveries},
    isActive: true,
  );

  const inactiveUser = UserEntity(
    uid: 'inactive-1',
    name: 'Inactive',
    email: 'inactive@test.com',
    role: UserRole.seller,
    permissions: {},
    isActive: false,
  );

  group('AuthRedirectPolicy', () {
    test('unauthenticated user is redirected to login unless already on login page', () {
      when(() => mockAuthViewModel.isAuthenticated).thenReturn(false);
      when(() => mockAuthViewModel.isBiometricAuthenticated).thenReturn(false);
      when(() => mockAuthViewModel.currentUser).thenReturn(null);

      mockRoute('/home');
      expect(policy.resolveRedirect(mockContext, mockState, mockAuthViewModel), equals(AppRoutes.login));

      mockRoute('/login');
      expect(policy.resolveRedirect(mockContext, mockState, mockAuthViewModel), isNull);
    });

    test('user on splash page is not redirected so splash can complete its initialization', () {
      when(() => mockAuthViewModel.isAuthenticated).thenReturn(false);
      mockRoute(AppRoutes.splash);
      expect(policy.resolveRedirect(mockContext, mockState, mockAuthViewModel), isNull);

      when(() => mockAuthViewModel.isAuthenticated).thenReturn(true);
      expect(policy.resolveRedirect(mockContext, mockState, mockAuthViewModel), isNull);
    });

    test('inactive user is redirected to inactive page', () {
      when(() => mockAuthViewModel.isAuthenticated).thenReturn(true);
      when(() => mockAuthViewModel.isBiometricAuthenticated).thenReturn(true);
      when(() => mockAuthViewModel.currentUser).thenReturn(inactiveUser);

      mockRoute('/home');
      expect(policy.resolveRedirect(mockContext, mockState, mockAuthViewModel), equals(AppRoutes.inactive));

      mockRoute('/inactive');
      expect(policy.resolveRedirect(mockContext, mockState, mockAuthViewModel), isNull);
    });

    test('authenticated user on login page is redirected to biometric if not biometric authenticated', () {
      when(() => mockAuthViewModel.isAuthenticated).thenReturn(true);
      when(() => mockAuthViewModel.isBiometricAuthenticated).thenReturn(false);
      when(() => mockAuthViewModel.currentUser).thenReturn(activeAdmin);

      mockRoute('/login');
      expect(policy.resolveRedirect(mockContext, mockState, mockAuthViewModel), equals(AppRoutes.biometric));
    });

    test('authenticated user on login page is redirected to home if biometric authenticated', () {
      when(() => mockAuthViewModel.isAuthenticated).thenReturn(true);
      when(() => mockAuthViewModel.isBiometricAuthenticated).thenReturn(true);
      when(() => mockAuthViewModel.currentUser).thenReturn(activeAdmin);

      mockRoute('/login');
      expect(policy.resolveRedirect(mockContext, mockState, mockAuthViewModel), equals(AppRoutes.home));
    });

    test('biometric unauthenticated user navigating elsewhere is redirected to biometric', () {
      when(() => mockAuthViewModel.isAuthenticated).thenReturn(true);
      when(() => mockAuthViewModel.isBiometricAuthenticated).thenReturn(false);
      when(() => mockAuthViewModel.currentUser).thenReturn(activeAdmin);

      mockRoute('/home');
      expect(policy.resolveRedirect(mockContext, mockState, mockAuthViewModel), equals(AppRoutes.biometric));

      mockRoute('/biometric');
      expect(policy.resolveRedirect(mockContext, mockState, mockAuthViewModel), isNull);
    });

    test('seller trying to access users route is redirected to unauthorized', () {
      when(() => mockAuthViewModel.isAuthenticated).thenReturn(true);
      when(() => mockAuthViewModel.isBiometricAuthenticated).thenReturn(true);
      when(() => mockAuthViewModel.currentUser).thenReturn(activeSeller);

      mockRoute('/users');
      expect(policy.resolveRedirect(mockContext, mockState, mockAuthViewModel), equals(AppRoutes.unauthorized));
    });

    test('seller without specific route permission is redirected to unauthorized', () {
      when(() => mockAuthViewModel.isAuthenticated).thenReturn(true);
      when(() => mockAuthViewModel.isBiometricAuthenticated).thenReturn(true);
      when(() => mockAuthViewModel.currentUser).thenReturn(activeSeller);

      // activeSeller only has UserPermission.deliveries, not manageSuppliers
      mockRoute('/suppliers/form');
      expect(policy.resolveRedirect(mockContext, mockState, mockAuthViewModel), equals(AppRoutes.unauthorized));

      // has UserPermission.deliveries
      mockRoute('/deliveries');
      expect(policy.resolveRedirect(mockContext, mockState, mockAuthViewModel), isNull);
    });

    test('admin has access to protected routes without explicit permission assignment', () {
      when(() => mockAuthViewModel.isAuthenticated).thenReturn(true);
      when(() => mockAuthViewModel.isBiometricAuthenticated).thenReturn(true);
      when(() => mockAuthViewModel.currentUser).thenReturn(activeAdmin);

      mockRoute('/suppliers/form');
      expect(policy.resolveRedirect(mockContext, mockState, mockAuthViewModel), isNull);
    });
  });
}
