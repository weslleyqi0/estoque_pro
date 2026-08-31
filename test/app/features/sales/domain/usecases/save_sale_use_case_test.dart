import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/save_sale_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSalesRepository extends Mock implements SalesRepository {}
class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late MockSalesRepository mockSalesRepository;
  late MockProductsRepository mockProductsRepository;
  late SaveSaleUseCase saveSaleUseCase;

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

  final testSale = SaleEntity(
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
    userName: 'Vendedor',
    status: SaleStatus.completed,
    createdAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(testSale);
  });

  setUp(() {
    mockSalesRepository = MockSalesRepository();
    mockProductsRepository = MockProductsRepository();
    saveSaleUseCase = SaveSaleUseCase(mockSalesRepository, mockProductsRepository);

    when(() => mockProductsRepository.getAll()).thenAnswer((_) async => const Result.success([testProduct]));
    when(() => mockSalesRepository.save(any(), productStocks: any(named: 'productStocks')))
        .thenAnswer((_) async => const Result.success(null));
    when(() => mockSalesRepository.updateSale(any(), productStocks: any(named: 'productStocks')))
        .thenAnswer((_) async => const Result.success(null));
  });

  test('returns BusinessRuleFailure when sale has no items', () async {
    final emptySale = testSale.copyWith(items: []);
    final result = await saveSaleUseCase.execute(sale: emptySale);

    expect(result.isFailure, isTrue);
    expect(result.error, isA<BusinessRuleFailure>());
    expect(result.error?.message, contains('não possui itens'));
  });

  test('returns BusinessRuleFailure when stock is insufficient for completed sale', () async {
    final excessiveSale = testSale.copyWith(
      items: [
        const SaleItemEntity(
          productId: 'prod_1',
          productName: 'Camisa Polo',
          productImgUrl: '',
          unitPrice: 50.0,
          quantity: 10,
        ),
      ],
    );

    final result = await saveSaleUseCase.execute(sale: excessiveSale);

    expect(result.isFailure, isTrue);
    expect(result.error, isA<BusinessRuleFailure>());
    expect(result.error?.message, contains('Estoque insuficiente'));
  });

  test('saves sale successfully when stock is available', () async {
    final result = await saveSaleUseCase.execute(sale: testSale);

    expect(result.isSuccess, isTrue);
    expect(result.value, equals(testSale));
    verify(() => mockSalesRepository.save(testSale, productStocks: {'prod_1': 5})).called(1);
  });
}
