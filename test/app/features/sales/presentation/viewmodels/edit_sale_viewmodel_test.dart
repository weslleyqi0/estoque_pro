import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/get_products_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/cancel_completed_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/edit_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/edit_sale_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEditSaleUseCase extends Mock implements EditSaleUseCase {}
class MockCancelCompletedSaleUseCase extends Mock implements CancelCompletedSaleUseCase {}
class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

void main() {
  late MockEditSaleUseCase mockEditSaleUseCase;
  late MockCancelCompletedSaleUseCase mockCancelCompletedSaleUseCase;
  late MockGetProductsUseCase mockGetProductsUseCase;
  late EditSaleViewModel viewModel;

  const testUser = UserEntity(
    uid: 'u1',
    name: 'Admin',
    email: 'admin@test.com',
    role: UserRole.admin,
    isActive: true,
    permissions: {UserPermission.editSales, UserPermission.cancelCompletedSales},
  );

  final sampleSale = SaleEntity(
    id: 'sale-1',
    saleNumber: '#101',
    items: const [
      SaleItemEntity(
        productId: 'prod_1',
        productName: 'Camisa Polo',
        productImgUrl: '',
        unitPrice: 50.0,
        quantity: 2,
      ),
    ],
    subtotal: 100.0,
    total: 100.0,
    paymentMethod: PaymentMethod.dinheiro,
    userId: 'u1',
    userName: 'Admin',
    status: SaleStatus.completed,
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockEditSaleUseCase = MockEditSaleUseCase();
    mockCancelCompletedSaleUseCase = MockCancelCompletedSaleUseCase();
    mockGetProductsUseCase = MockGetProductsUseCase();
    viewModel = EditSaleViewModel(
      mockEditSaleUseCase,
      mockCancelCompletedSaleUseCase,
      mockGetProductsUseCase,
    );
    viewModel.initWithSale(sampleSale);
  });

  test('saveEditCommand executes and updates command state to success', () async {
    when(
      () => mockEditSaleUseCase.call(
        originalSale: any(named: 'originalSale'),
        updatedItems: any(named: 'updatedItems'),
        reason: any(named: 'reason'),
        comment: any(named: 'comment'),
        customerId: any(named: 'customerId'),
        customerName: any(named: 'customerName'),
        currentUser: any(named: 'currentUser'),
      ),
    ).thenAnswer((_) async => Result.success(sampleSale.copyWith(status: SaleStatus.edited)));

    await viewModel.saveEditCommand.execute(testUser);

    expect(viewModel.saveEditCommand.isSuccess, isTrue);
    expect(viewModel.isSaving, isFalse);
    expect(viewModel.errorMessage, isNull);
  });

  test('saveEditCommand exposes error and errorMessage on failure', () async {
    when(
      () => mockEditSaleUseCase.call(
        originalSale: any(named: 'originalSale'),
        updatedItems: any(named: 'updatedItems'),
        reason: any(named: 'reason'),
        comment: any(named: 'comment'),
        customerId: any(named: 'customerId'),
        customerName: any(named: 'customerName'),
        currentUser: any(named: 'currentUser'),
      ),
    ).thenAnswer(
      (_) async => Result.failure(
        const BusinessRuleFailure(message: 'Estoque insuficiente para a alteração.'),
      ),
    );

    await viewModel.saveEditCommand.execute(testUser);

    expect(viewModel.saveEditCommand.isFailure, isTrue);
    expect(viewModel.errorMessage, equals('Estoque insuficiente para a alteração.'));
  });

  test('cancelSaleCommand executes and updates command state to success', () async {
    when(
      () => mockCancelCompletedSaleUseCase.call(
        sale: any(named: 'sale'),
        reason: any(named: 'reason'),
        comment: any(named: 'comment'),
        currentUser: any(named: 'currentUser'),
      ),
    ).thenAnswer((_) async => Result.success(sampleSale.copyWith(status: SaleStatus.cancelled)));

    await viewModel.cancelSaleCommand.execute((
      currentUser: testUser,
      reason: 'Cliente desistiu',
      comment: 'Devolução total',
    ));

    expect(viewModel.cancelSaleCommand.isSuccess, isTrue);
    expect(viewModel.isSaving, isFalse);
  });
}
