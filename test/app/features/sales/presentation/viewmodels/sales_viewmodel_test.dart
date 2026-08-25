import 'dart:async';

import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/discount_type.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSalesRepository extends Mock implements SalesRepository {}

class MockDeliveriesRepository extends Mock implements DeliveriesRepository {}

void main() {
  late MockSalesRepository mockSalesRepository;
  late MockDeliveriesRepository mockDeliveriesRepository;
  late StreamController<List<SaleEntity>> salesController;
  late StreamController<List<DeliveryEntity>> deliveriesController;
  late SalesViewModel viewModel;

  final now = DateTime.now();

  final sale1 = SaleEntity(
    id: 's1',
    saleNumber: '#1001',
    items: const [
      SaleItemEntity(
        productId: 'p1',
        productName: 'Camisa Polo',
        productImgUrl: '',
        unitPrice: 50.0,
        quantity: 2,
      ),
    ],
    subtotal: 100.0,
    discountType: DiscountType.valueAmount,
    discountValue: 0.0,
    total: 100.0,
    paymentMethod: PaymentMethod.pix,
    customerId: 'c1',
    customerName: 'João Santos',
    userId: 'u1',
    userName: 'Vendedor 1',
    status: SaleStatus.completed,
    createdAt: now,
  );

  final delivery1 = DeliveryEntity(
    id: 'd1',
    saleId: 's1',
    saleNumber: '#1001',
    customerId: 'c1',
    customerName: 'João Santos',
    customerPhone: '11999999999',
    customerAddress: 'Rua Principal, 123',
    items: const [],
    subtotal: 100.0,
    totalAmount: 100.0,
    paymentMethod: PaymentMethod.pix,
    status: DeliveryStatus.pending,
    scheduledAt: now.add(const Duration(hours: 2)),
    userId: 'u1',
    userName: 'Vendedor 1',
    createdAt: now,
  );

  setUp(() {
    mockSalesRepository = MockSalesRepository();
    mockDeliveriesRepository = MockDeliveriesRepository();
    salesController = StreamController<List<SaleEntity>>.broadcast();
    deliveriesController = StreamController<List<DeliveryEntity>>.broadcast();

    when(() => mockSalesRepository.watchAll()).thenAnswer((_) => salesController.stream);
    when(() => mockDeliveriesRepository.watchAll(limit: any(named: 'limit')))
        .thenAnswer((_) => deliveriesController.stream);

    viewModel = SalesViewModel(mockSalesRepository, mockDeliveriesRepository);
  });

  tearDown(() {
    salesController.close();
    deliveriesController.close();
    viewModel.dispose();
  });

  test('listenAll updates sales and deliveries, and getDeliveryForSale returns matching delivery', () async {
    viewModel.listenAll();
    expect(viewModel.state, SalesLoadState.loading);

    salesController.add([sale1]);
    deliveriesController.add([delivery1]);
    await Future.delayed(Duration.zero);

    expect(viewModel.state, SalesLoadState.success);
    expect(viewModel.sales.length, 1);

    final deliveryFoundById = viewModel.getDeliveryForSale('s1');
    expect(deliveryFoundById, isNotNull);
    expect(deliveryFoundById?.id, 'd1');
    expect(deliveryFoundById?.status, DeliveryStatus.pending);

    final deliveryFoundByNumber = viewModel.getDeliveryForSale('unknown', '#1001');
    expect(deliveryFoundByNumber, isNotNull);
    expect(deliveryFoundByNumber?.id, 'd1');
  });

  test('getDeliveryForSale returns null when sale has no delivery', () async {
    viewModel.listenAll();
    salesController.add([sale1]);
    deliveriesController.add([]);
    await Future.delayed(Duration.zero);

    expect(viewModel.getDeliveryForSale('s1'), isNull);
    expect(viewModel.getDeliveryForSale('s1', '#1001'), isNull);
  });
}
