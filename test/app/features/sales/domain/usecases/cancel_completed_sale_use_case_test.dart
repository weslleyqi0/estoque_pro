import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_history_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/cancel_completed_sale_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSalesRepository extends Mock implements SalesRepository {}

class MockDeliveriesRepository extends Mock implements DeliveriesRepository {}

void main() {
  late MockSalesRepository mockSalesRepository;
  late MockDeliveriesRepository mockDeliveriesRepository;
  late CancelCompletedSaleUseCase useCase;

  final adminUser = const UserEntity(
    uid: 'admin1',
    name: 'Admin',
    email: 'admin@test.com',
    role: UserRole.admin,
    isActive: true,
    permissions: {UserPermission.cancelCompletedSales},
  );

  final sellerWithoutPerm = const UserEntity(
    uid: 'seller1',
    name: 'Seller',
    email: 'seller@test.com',
    role: UserRole.seller,
    isActive: true,
    permissions: {},
  );

  final sampleSale = SaleEntity(
    id: 'sale-123',
    saleNumber: '#1001',
    items: const [
      SaleItemEntity(
        productId: 'prod1',
        productName: 'Camisa',
        productImgUrl: '',
        unitPrice: 50.0,
        quantity: 2,
      ),
    ],
    subtotal: 100.0,
    total: 100.0,
    paymentMethod: PaymentMethod.dinheiro,
    userId: 'seller1',
    userName: 'Seller',
    status: SaleStatus.completed,
    createdAt: DateTime(2026, 9, 1),
  );

  setUpAll(() {
    registerFallbackValue(sampleSale);
    registerFallbackValue(
      SaleEditHistoryEntity(
        id: 'h1',
        sequenceNumber: 1,
        userId: 'u1',
        userName: 'User',
        timestamp: DateTime.now(),
        reason: 'Reason',
        addedItems: const [],
        removedItems: const [],
      ),
    );
  });

  setUp(() {
    mockSalesRepository = MockSalesRepository();
    mockDeliveriesRepository = MockDeliveriesRepository();
    useCase = CancelCompletedSaleUseCase(
      mockSalesRepository,
      mockDeliveriesRepository,
    );
  });

  test('returns PermissionFailure when user does not have permission', () async {
    final result = await useCase.call(
      sale: sampleSale,
      currentUser: sellerWithoutPerm,
    );

    expect(result.isFailure, isTrue);
    expect(result.error, isA<PermissionFailure>());
    verifyZeroInteractions(mockSalesRepository);
    verifyZeroInteractions(mockDeliveriesRepository);
  });

  test('returns BusinessRuleFailure when sale is already cancelled', () async {
    final cancelled = sampleSale.copyWith(status: SaleStatus.cancelled);
    final result = await useCase.call(
      sale: cancelled,
      currentUser: adminUser,
    );

    expect(result.isFailure, isTrue);
    expect(result.error, isA<BusinessRuleFailure>());
    verifyZeroInteractions(mockSalesRepository);
  });

  test('cancels sale and automatically cancels linked delivery when present', () async {
    when(
      () => mockSalesRepository.updateSaleWithStockAndHistory(
        sale: any(named: 'sale'),
        stockDeltas: any(named: 'stockDeltas'),
        editHistoryEntry: any(named: 'editHistoryEntry'),
      ),
    ).thenAnswer((_) async => const Result.success(null));

    when(
      () => mockDeliveriesRepository.cancelDeliveryForSale('sale-123', '#1001'),
    ).thenAnswer((_) async => const Result.success(null));

    final result = await useCase.call(
      sale: sampleSale,
      currentUser: adminUser,
      reason: 'Cliente desistiu',
    );

    expect(result.isSuccess, isTrue);
    final cancelledSale = result.value!;
    expect(cancelledSale.status, SaleStatus.cancelled);

    // Verifica se a venda foi atualizada no repositório de vendas
    verify(
      () => mockSalesRepository.updateSaleWithStockAndHistory(
        sale: any(named: 'sale'),
        stockDeltas: {'prod1': -2},
        editHistoryEntry: any(named: 'editHistoryEntry'),
      ),
    ).called(1);

    // Verifica se a entrega vinculada foi cancelada
    verify(
      () => mockDeliveriesRepository.cancelDeliveryForSale('sale-123', '#1001'),
    ).called(1);
  });
}
