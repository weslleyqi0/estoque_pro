import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_history_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/edit_sale_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSalesRepository extends Mock implements SalesRepository {}
class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late MockSalesRepository mockSalesRepository;
  late MockProductsRepository mockProductsRepository;
  late EditSaleUseCase editSaleUseCase;

  const testUser = UserEntity(
    uid: 'u1',
    name: 'Admin',
    email: 'admin@test.com',
    role: UserRole.admin,
    isActive: true,
    permissions: {UserPermission.editSales},
  );

  const unauthorizedUser = UserEntity(
    uid: 'u2',
    name: 'Vendedor',
    email: 'vendedor@test.com',
    role: UserRole.seller,
    isActive: true,
    permissions: {},
  );

  const testProduct = ProductEntity(
    id: 'prod_1',
    name: 'Camisa Polo',
    imgUrl: '',
    description: '',
    price: 50.0,
    stock: 5,
    minStock: 1,
    categories: [],
  );

  final originalSale = SaleEntity(
    id: 's1',
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

  setUpAll(() {
    registerFallbackValue(originalSale);
    registerFallbackValue(
      SaleEditHistoryEntity(
        id: '1',
        sequenceNumber: 1,
        userId: 'u1',
        userName: 'Admin',
        timestamp: DateTime.now(),
        reason: 'Teste',
        addedItems: const [],
        removedItems: const [],
      ),
    );
  });

  setUp(() {
    mockSalesRepository = MockSalesRepository();
    mockProductsRepository = MockProductsRepository();
    editSaleUseCase = EditSaleUseCase(mockSalesRepository, mockProductsRepository);

    when(() => mockProductsRepository.getAll()).thenAnswer((_) async => [testProduct]);
    when(() => mockSalesRepository.updateSale(any())).thenAnswer((_) async {});
    when(
      () => mockSalesRepository.updateSaleWithStockAndHistory(
        sale: any(named: 'sale'),
        stockDeltas: any(named: 'stockDeltas'),
        editHistoryEntry: any(named: 'editHistoryEntry'),
        currentProductStocks: any(named: 'currentProductStocks'),
      ),
    ).thenAnswer((_) async {});
  });

  test('returns PermissionFailure when user does not have permission', () async {
    final result = await editSaleUseCase.call(
      originalSale: originalSale,
      updatedItems: originalSale.items,
      reason: 'Ajuste',
      currentUser: unauthorizedUser,
    );

    expect(result.isFailure, isTrue);
    expect(result.error, isA<PermissionFailure>());
    expect(result.error?.message, contains('não possui permissão'));
  });

  test('returns BusinessRuleFailure when updated items list is empty', () async {
    final result = await editSaleUseCase.call(
      originalSale: originalSale,
      updatedItems: [],
      reason: 'Ajuste',
      currentUser: testUser,
    );

    expect(result.isFailure, isTrue);
    expect(result.error, isA<BusinessRuleFailure>());
    expect(result.error?.message, contains('pelo menos um item'));
  });

  test('returns BusinessRuleFailure when requested delta exceeds available stock', () async {
    final result = await editSaleUseCase.call(
      originalSale: originalSale,
      updatedItems: [
        const SaleItemEntity(
          productId: 'prod_1',
          productName: 'Camisa Polo',
          productImgUrl: '',
          unitPrice: 50.0,
          quantity: 10, // original: 2, delta: +8, stock: 5 -> fails
        ),
      ],
      reason: 'Adição de itens',
      currentUser: testUser,
    );

    expect(result.isFailure, isTrue);
    expect(result.error, isA<BusinessRuleFailure>());
    expect(result.error?.message, contains('Estoque insuficiente'));
  });

  test('edits sale successfully when stock is available', () async {
    final result = await editSaleUseCase.call(
      originalSale: originalSale,
      updatedItems: [
        const SaleItemEntity(
          productId: 'prod_1',
          productName: 'Camisa Polo',
          productImgUrl: '',
          unitPrice: 50.0,
          quantity: 3, // delta: +1, stock: 5 -> ok
        ),
      ],
      reason: 'Cliente pediu mais uma',
      currentUser: testUser,
    );

    expect(result.isSuccess, isTrue);
    expect(result.value?.items.first.quantity, equals(3));
    expect(result.value?.status, equals(SaleStatus.edited));
  });
}
