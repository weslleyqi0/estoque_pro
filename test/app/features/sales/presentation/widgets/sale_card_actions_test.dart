import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/delete_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_card/sale_card_actions.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthorizationService extends Mock implements AuthorizationService {}
class MockGetSalesUseCase extends Mock implements GetSalesUseCase {}
class MockDeleteSaleUseCase extends Mock implements DeleteSaleUseCase {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockAuthorizationService mockAuthService;
  late MockGetSalesUseCase mockGetSalesUseCase;
  late MockDeleteSaleUseCase mockDeleteSaleUseCase;
  late AuthViewModel authViewModel;
  late SalesViewModel salesViewModel;

  const adminUser = UserEntity(
    uid: 'u_admin',
    name: 'Admin',
    email: 'admin@test.com',
    role: UserRole.admin,
    isActive: true,
    permissions: {},
  );

  const sellerWithoutPerm = UserEntity(
    uid: 'u_other',
    name: 'Outro Vendedor',
    email: 'outro@test.com',
    role: UserRole.seller,
    isActive: true,
    permissions: {},
  );

  final cancelledSale = SaleEntity(
    id: 's_cancelled_1',
    saleNumber: '#1099',
    items: const [
      SaleItemEntity(
        productId: 'p1',
        productName: 'Produto Teste',
        productImgUrl: '',
        unitPrice: 50.0,
        quantity: 1,
      ),
    ],
    subtotal: 50.0,
    total: 50.0,
    paymentMethod: PaymentMethod.dinheiro,
    userId: 'u_seller_original',
    userName: 'Vendedor Original',
    status: SaleStatus.cancelled,
    createdAt: DateTime(2026, 8, 20),
  );

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockAuthService = MockAuthorizationService();
    mockGetSalesUseCase = MockGetSalesUseCase();
    mockDeleteSaleUseCase = MockDeleteSaleUseCase();

    when(() => mockAuthRepo.currentUser).thenReturn(null);
    when(() => mockAuthRepo.authStateChanges).thenAnswer((_) => const Stream.empty());

    salesViewModel = SalesViewModel(mockGetSalesUseCase, mockDeleteSaleUseCase);
  });

  Widget buildTestWidget({required UserEntity currentUser, required SaleEntity sale}) {
    when(() => mockAuthService.currentUser).thenReturn(currentUser);
    authViewModel = AuthViewModel(mockAuthRepo, mockAuthService);

    return MaterialApp(
      home: Scaffold(
        body: SaleCardActions(
          sale: sale,
          authViewModel: authViewModel,
          salesViewModel: salesViewModel,
        ),
      ),
    );
  }

  testWidgets('shows delete button when sale is cancelled and user is admin', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      currentUser: adminUser,
      sale: cancelledSale,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Excluir'), findsOneWidget);
    expect(find.byIcon(AppIcons.delete), findsOneWidget);
  });

  testWidgets('does NOT show delete button when sale is cancelled and seller has no permission on other sale', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      currentUser: sellerWithoutPerm,
      sale: cancelledSale,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Excluir'), findsNothing);
  });

  testWidgets('clicking Excluir prompts confirmation and executes deleteSaleCommand', (tester) async {
    when(() => mockDeleteSaleUseCase(cancelledSale.id))
        .thenAnswer((_) async => const Result.success(true));

    await tester.pumpWidget(buildTestWidget(
      currentUser: adminUser,
      sale: cancelledSale,
    ));
    await tester.pumpAndSettle();

    final deleteButton = find.text('Excluir');
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Dialog should appear
    expect(find.text('Excluir Venda Cancelada'), findsOneWidget);
    expect(find.text('Sim, Excluir'), findsOneWidget);

    await tester.tap(find.text('Sim, Excluir'));
    await tester.pumpAndSettle();

    verify(() => mockDeleteSaleUseCase(cancelledSale.id)).called(1);
  });
}
