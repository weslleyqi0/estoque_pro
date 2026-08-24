import 'dart:async';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDeliveriesRepository extends Mock implements DeliveriesRepository {}

void main() {
  late MockDeliveriesRepository mockRepository;
  late DeliveriesViewModel viewModel;
  late StreamController<List<DeliveryEntity>> controller;

  final now = DateTime.now();

  final deliveryPending = DeliveryEntity(
    id: 'd1',
    saleId: 's1',
    saleNumber: '#101',
    customerId: 'c1',
    customerName: 'Ana Silva',
    customerPhone: '11911111111',
    customerAddress: 'Rua A, 1',
    items: const [
      SaleItemEntity(
        productId: 'p1',
        productName: 'Blusa',
        productImgUrl: '',
        unitPrice: 80.0,
        quantity: 1,
      ),
    ],
    subtotal: 80.0,
    totalAmount: 80.0,
    paymentMethod: PaymentMethod.dinheiro,
    status: DeliveryStatus.pending,
    scheduledAt: now.add(const Duration(hours: 2)),
    userId: 'u1',
    userName: 'Vendedor',
    createdAt: now,
  );

  final deliveryDelayed = DeliveryEntity(
    id: 'd2',
    saleId: 's2',
    saleNumber: '#102',
    customerId: 'c2',
    customerName: 'Bruno Costa',
    customerPhone: '11922222222',
    customerAddress: 'Rua B, 2',
    items: const [
      SaleItemEntity(
        productId: 'p2',
        productName: 'Calça Jeans',
        productImgUrl: '',
        unitPrice: 120.0,
        quantity: 1,
      ),
    ],
    subtotal: 120.0,
    totalAmount: 120.0,
    paymentMethod: PaymentMethod.pix,
    status: DeliveryStatus.pending,
    scheduledAt: now.subtract(const Duration(hours: 3)),
    userId: 'u1',
    userName: 'Vendedor',
    createdAt: now.subtract(const Duration(hours: 4)),
  );

  final deliveryCompleted = DeliveryEntity(
    id: 'd3',
    saleId: 's3',
    saleNumber: '#103',
    customerId: 'c3',
    customerName: 'Carlos Lima',
    customerPhone: '11933333333',
    customerAddress: 'Rua C, 3',
    items: const [],
    subtotal: 50.0,
    totalAmount: 50.0,
    paymentMethod: PaymentMethod.credito,
    status: DeliveryStatus.completed,
    scheduledAt: now.subtract(const Duration(days: 1)),
    deliveredAt: now.subtract(const Duration(days: 1)),
    userId: 'u1',
    userName: 'Vendedor',
    createdAt: now.subtract(const Duration(days: 1)),
  );

  setUpAll(() {
    registerFallbackValue(DeliveryStatus.pending);
  });

  setUp(() {
    mockRepository = MockDeliveriesRepository();
    controller = StreamController<List<DeliveryEntity>>.broadcast();
    when(() => mockRepository.watchAll(limit: any(named: 'limit')))
        .thenAnswer((_) => controller.stream);
    when(() => mockRepository.updateStatus(any(), any(), deliveredAt: any(named: 'deliveredAt')))
        .thenAnswer((_) async {});
    viewModel = DeliveriesViewModel(mockRepository);
  });

  tearDown(() {
    controller.close();
    viewModel.dispose();
  });

  test('listenAll updates deliveries and computes status counts correctly', () async {
    viewModel.listenAll();
    expect(viewModel.state, DeliveriesState.loading);

    controller.add([deliveryPending, deliveryDelayed, deliveryCompleted]);
    await Future.delayed(Duration.zero);

    expect(viewModel.state, DeliveriesState.loaded);
    expect(viewModel.deliveries.length, 3);
    expect(viewModel.pendingDeliveries.length, 1);
    expect(viewModel.delayedDeliveries.length, 1);
    expect(viewModel.completedDeliveries.length, 1);

    expect(viewModel.getTabCount(DeliveryFilterTab.all), 3);
    expect(viewModel.getTabCount(DeliveryFilterTab.pending), 1);
    expect(viewModel.getTabCount(DeliveryFilterTab.delayed), 1);
    expect(viewModel.getTabCount(DeliveryFilterTab.completed), 1);
  });

  test('filtering by tab and search query works', () async {
    viewModel.listenAll();
    controller.add([deliveryPending, deliveryDelayed, deliveryCompleted]);
    await Future.delayed(Duration.zero);

    viewModel.setSelectedTab(DeliveryFilterTab.pending);
    expect(viewModel.filteredDeliveries.length, 1);
    expect(viewModel.filteredDeliveries.first.id, 'd1');

    viewModel.setSelectedTab(DeliveryFilterTab.delayed);
    expect(viewModel.filteredDeliveries.length, 1);
    expect(viewModel.filteredDeliveries.first.id, 'd2');

    viewModel.setSelectedTab(DeliveryFilterTab.all);
    viewModel.setSearchQuery('Calça');
    expect(viewModel.filteredDeliveries.length, 1);
    expect(viewModel.filteredDeliveries.first.id, 'd2');

    viewModel.setSearchQuery('Carlos');
    expect(viewModel.filteredDeliveries.length, 1);
    expect(viewModel.filteredDeliveries.first.id, 'd3');
  });

  test('deliveries in all tab are ordered: delayed -> pending -> inProgress -> others (descending)', () async {
    final inProgress = deliveryPending.copyWith(
      id: 'd4',
      status: DeliveryStatus.inProgress,
      scheduledAt: now.add(const Duration(hours: 3)),
    );

    viewModel.listenAll();
    // Added in arbitrary order
    controller.add([deliveryCompleted, inProgress, deliveryPending, deliveryDelayed]);
    await Future.delayed(Duration.zero);

    viewModel.setSelectedTab(DeliveryFilterTab.all);
    final sorted = viewModel.filteredDeliveries;

    expect(sorted.length, 4);
    expect(sorted[0].id, 'd2'); // Atrasada
    expect(sorted[1].id, 'd1'); // Pendente
    expect(sorted[2].id, 'd4'); // Em andamento
    expect(sorted[3].id, 'd3'); // Finalizada (outras)
  });

  test('updateDeliveryStatus delegates to repository', () async {
    await viewModel.updateDeliveryStatus('d1', DeliveryStatus.inProgress);
    verify(() => mockRepository.updateStatus('d1', DeliveryStatus.inProgress, deliveredAt: null)).called(1);
  });
}
