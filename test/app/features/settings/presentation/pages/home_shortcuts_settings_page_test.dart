import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/core/services/local_storage_service.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/home/presentation/viewmodels/home_shortcuts_viewmodel.dart';
import 'package:estoque_pro/app/features/settings/presentation/pages/home_shortcuts_settings_page.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthorizationService extends Mock implements AuthorizationService {}
class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthorizationService mockAuthService;
  late MockLocalStorageService mockStorage;
  late AuthViewModel authViewModel;
  late HomeShortcutsViewModel shortcutsViewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuthService = MockAuthorizationService();
    mockStorage = MockLocalStorageService();

    when(() => mockStorage.getString('home_shortcuts_order')).thenReturn(null);
    when(() => mockStorage.remove(any())).thenAnswer((_) async {});
    when(() => mockStorage.setString(any(), any())).thenAnswer((_) async {});

    const currentUser = UserEntity(
      uid: '1',
      name: 'Admin Teste',
      email: 'admin@test.com',
      role: UserRole.owner,
      isActive: true,
      permissions: {},
    );
    when(() => mockAuthService.currentUser).thenReturn(currentUser);
    when(() => mockAuthRepository.currentUser).thenReturn(null);
    when(() => mockAuthRepository.authStateChanges).thenAnswer((_) => const Stream.empty());

    authViewModel = AuthViewModel(mockAuthRepository, mockAuthService);
    shortcutsViewModel = HomeShortcutsViewModel(mockStorage);
  });

  testWidgets('HomeShortcutsSettingsPage renders all shortcut items and allows resetting', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeShortcutsSettingsPage(
          viewModelFactory: () => shortcutsViewModel,
          authViewModel: authViewModel,
        ),
      ),
    );

    expect(find.text('Atalhos da Tela Inicial'), findsOneWidget);
    expect(find.text('Produtos'), findsOneWidget);
    expect(find.text('Vendas'), findsOneWidget);
    expect(find.text('Categorias'), findsOneWidget);
    expect(find.text('Entregas'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Usuários'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Usuários'), findsOneWidget);

    // Clica no botão de restaurar padrão
    await tester.tap(find.byTooltip('Restaurar Padrão'));
    await tester.pumpAndSettle();

    expect(find.text('Ordem padrão restaurada.'), findsOneWidget);
  });
}
