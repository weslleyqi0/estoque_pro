import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/cart_item.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/discount_type.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/finalize_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/save_sale_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSaveSaleUseCase extends Mock implements SaveSaleUseCase {}

void main() {
  late MockSaveSaleUseCase mockSaveSaleUseCase;
  late FinalizeSaleUseCase finalizeSaleUseCase;

  const testProduct = ProductEntity(
    id: 'prod_1',
    name: 'Camisa Polo',
    imgUrl: 'https://example.com/polo.jpg',
    description: 'Camisa Polo Teste',
    price: 50.0,
    stock: 10,
    minStock: 2,
    categories: [],
  );

  final cartItems = [
    const CartItem(product: testProduct, quantity: 2),
  ];

  setUpAll(() {
    registerFallbackValue(
      SaleEntity(
        id: '',
        saleNumber: '#123',
        items: const [],
        subtotal: 100.0,
        total: 100.0,
        paymentMethod: PaymentMethod.dinheiro,
        userId: 'user_1',
        userName: 'Vendedor',
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockSaveSaleUseCase = MockSaveSaleUseCase();
    finalizeSaleUseCase = FinalizeSaleUseCase(mockSaveSaleUseCase);
    when(() => mockSaveSaleUseCase.execute(sale: any(named: 'sale'), isUpdate: any(named: 'isUpdate')))
        .thenAnswer((_) async {});
  });

  test('finalize sale with cash succeeds without customer', () async {
    await finalizeSaleUseCase.execute(
      items: cartItems,
      saleNumber: '#1001',
      editingSaleId: null,
      discountType: DiscountType.valueAmount,
      discountValue: 0.0,
      subtotal: 100.0,
      total: 100.0,
      paymentMethod: PaymentMethod.dinheiro,
      amountPaid: 100.0,
      change: 0.0,
      userId: 'u1',
      userName: 'Vendedor 1',
      availableProducts: [testProduct],
    );

    verify(() => mockSaveSaleUseCase.execute(sale: any(named: 'sale'), isUpdate: false)).called(1);
  });

  test('finalize sale with fiado throws exception if customer is missing', () async {
    expect(
      () => finalizeSaleUseCase.execute(
        items: cartItems,
        saleNumber: '#1002',
        editingSaleId: null,
        discountType: DiscountType.valueAmount,
        discountValue: 0.0,
        subtotal: 100.0,
        total: 100.0,
        paymentMethod: PaymentMethod.fiado,
        amountPaid: 0.0,
        change: 0.0,
        customerId: null,
        customerName: null,
        userId: 'u1',
        userName: 'Vendedor 1',
        availableProducts: [testProduct],
      ),
      throwsA(isA<Exception>().having(
        (e) => e.toString(),
        'message',
        contains('Para vendas no fiado, é obrigatório selecionar um cliente'),
      )),
    );
  });

  test('finalize sale with fiado succeeds when customer is provided', () async {
    await finalizeSaleUseCase.execute(
      items: cartItems,
      saleNumber: '#1003',
      editingSaleId: null,
      discountType: DiscountType.valueAmount,
      discountValue: 0.0,
      subtotal: 100.0,
      total: 100.0,
      paymentMethod: PaymentMethod.fiado,
      amountPaid: 0.0,
      change: 0.0,
      customerId: 'cust_99',
      customerName: 'Cliente Confiável',
      userId: 'u1',
      userName: 'Vendedor 1',
      availableProducts: [testProduct],
    );

    verify(
      () => mockSaveSaleUseCase.execute(
        sale: any(
          named: 'sale',
          that: isA<SaleEntity>()
              .having((s) => s.paymentMethod, 'paymentMethod', PaymentMethod.fiado)
              .having((s) => s.customerId, 'customerId', 'cust_99')
              .having((s) => s.customerName, 'customerName', 'Cliente Confiável'),
        ),
        isUpdate: false,
      ),
    ).called(1);
  });
}
