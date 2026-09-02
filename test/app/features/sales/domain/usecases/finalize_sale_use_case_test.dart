import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
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
class MockDeliveriesRepository extends Mock implements DeliveriesRepository {}

void main() {
  late MockSaveSaleUseCase mockSaveSaleUseCase;
  late MockDeliveriesRepository mockDeliveriesRepository;
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
    registerFallbackValue(
      DeliveryEntity(
        id: '',
        saleId: 'sale_1',
        saleNumber: '#123',
        customerId: 'cust_1',
        customerName: 'Cliente',
        customerAddress: 'Rua 1',
        items: const [],
        subtotal: 100.0,
        totalAmount: 100.0,
        paymentMethod: PaymentMethod.dinheiro,
        scheduledAt: DateTime.now(),
        userId: 'user_1',
        userName: 'Vendedor',
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockSaveSaleUseCase = MockSaveSaleUseCase();
    mockDeliveriesRepository = MockDeliveriesRepository();
    finalizeSaleUseCase = FinalizeSaleUseCase(mockSaveSaleUseCase);
    when(
      () => mockSaveSaleUseCase.call(
        sale: any(named: 'sale'),
        isUpdate: any(named: 'isUpdate'),
        delivery: any(named: 'delivery'),
      ),
    ).thenAnswer((invocation) async {
      final sale = invocation.namedArguments[#sale] as SaleEntity;
      return Result.success(sale);
    });
    when(() => mockDeliveriesRepository.save(any())).thenAnswer((_) async => const Result.success(null));
  });

  test('finalize sale with cash succeeds without customer', () async {
    final result = await finalizeSaleUseCase(
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

    expect(result.isSuccess, isTrue);
    verify(
      () => mockSaveSaleUseCase(
        sale: any(named: 'sale'),
        isUpdate: false,
        delivery: null,
      ),
    ).called(1);
    verifyNever(() => mockDeliveriesRepository.save(any()));
  });

  test('finalize sale with fiado returns BusinessRuleFailure if customer is missing', () async {
    final result = await finalizeSaleUseCase(
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
    );

    expect(result.isFailure, isTrue);
    expect(result.error, isA<BusinessRuleFailure>());
    expect(result.error?.message, contains('Para vendas no fiado, é obrigatório selecionar um cliente'));
  });

  test('finalize sale with fiado succeeds when customer is provided', () async {
    final result = await finalizeSaleUseCase(
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

    expect(result.isSuccess, isTrue);
    verify(
      () => mockSaveSaleUseCase(
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

  test('finalize sale with delivery returns BusinessRuleFailure if customer is missing', () async {
    final result = await finalizeSaleUseCase(
      items: cartItems,
      saleNumber: '#1004',
      editingSaleId: null,
      discountType: DiscountType.valueAmount,
      discountValue: 0.0,
      subtotal: 100.0,
      total: 100.0,
      paymentMethod: PaymentMethod.dinheiro,
      amountPaid: 100.0,
      change: 0.0,
      customerId: null,
      customerName: null,
      userId: 'u1',
      userName: 'Vendedor 1',
      availableProducts: [testProduct],
      isDelivery: true,
      deliveryAddress: 'Rua das Flores, 123',
    );

    expect(result.isFailure, isTrue);
    expect(result.error, isA<BusinessRuleFailure>());
    expect(result.error?.message, contains('Para entregas, é obrigatório selecionar um cliente'));
  });

  test('finalize sale with delivery and empty address defaults to A combinar', () async {
    final result = await finalizeSaleUseCase(
      items: cartItems,
      saleNumber: '#1005',
      editingSaleId: null,
      discountType: DiscountType.valueAmount,
      discountValue: 0.0,
      subtotal: 100.0,
      total: 100.0,
      paymentMethod: PaymentMethod.dinheiro,
      amountPaid: 100.0,
      change: 0.0,
      customerId: 'c1',
      customerName: 'Cliente 1',
      userId: 'u1',
      userName: 'Vendedor 1',
      availableProducts: [testProduct],
      isDelivery: true,
      deliveryAddress: '',
    );

    expect(result.isSuccess, isTrue);
    verify(
      () => mockSaveSaleUseCase(
        sale: any(named: 'sale'),
        isUpdate: false,
        delivery: any(
          named: 'delivery',
          that: isA<DeliveryEntity>()
              .having((d) => d.customerAddress, 'customerAddress', 'A combinar'),
        ),
      ),
    ).called(1);
  });

  test('finalize sale with delivery creates sale and saves delivery', () async {
    final scheduledDate = DateTime.now().add(const Duration(hours: 2));

    final result = await finalizeSaleUseCase(
      items: cartItems,
      saleNumber: '#1006',
      editingSaleId: null,
      discountType: DiscountType.valueAmount,
      discountValue: 0.0,
      subtotal: 100.0,
      total: 100.0,
      paymentMethod: PaymentMethod.dinheiro,
      amountPaid: 100.0,
      change: 0.0,
      customerId: 'cust_1',
      customerName: 'Cliente Entregas',
      customerPhone: '11999999999',
      userId: 'u1',
      userName: 'Vendedor 1',
      availableProducts: [testProduct],
      isDelivery: true,
      deliveryScheduledAt: scheduledDate,
      deliveryAddress: 'Av. Paulista, 1000',
      deliveryNotes: 'Apto 101',
    );

    expect(result.isSuccess, isTrue);
    verify(
      () => mockSaveSaleUseCase(
        sale: any(named: 'sale'),
        isUpdate: false,
        delivery: any(
          named: 'delivery',
          that: isA<DeliveryEntity>()
              .having((d) => d.saleNumber, 'saleNumber', '#1006')
              .having((d) => d.customerId, 'customerId', 'cust_1')
              .having((d) => d.customerName, 'customerName', 'Cliente Entregas')
              .having((d) => d.customerPhone, 'customerPhone', '11999999999')
              .having((d) => d.customerAddress, 'customerAddress', 'Av. Paulista, 1000')
              .having((d) => d.observations, 'observations', 'Apto 101'),
        ),
      ),
    ).called(1);
  });

  test('finalize sale returns BusinessRuleFailure when stock is insufficient', () async {
    final result = await finalizeSaleUseCase(
      items: [
        const CartItem(product: testProduct, quantity: 20),
      ],
      saleNumber: '#1007',
      editingSaleId: null,
      discountType: DiscountType.valueAmount,
      discountValue: 0.0,
      subtotal: 1000.0,
      total: 1000.0,
      paymentMethod: PaymentMethod.dinheiro,
      amountPaid: 1000.0,
      change: 0.0,
      userId: 'u1',
      userName: 'Vendedor 1',
      availableProducts: [testProduct],
    );

    expect(result.isFailure, isTrue);
    expect(result.error, isA<BusinessRuleFailure>());
    expect(result.error?.message, contains('Estoque insuficiente'));
  });
}
