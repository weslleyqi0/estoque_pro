import 'dart:async';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/discount_type.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
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
    saleNumber: '001',
    customerId: 'c1',
    customerName: 'João Silva',
    customerAddress: 'Rua A, 123',
    items: const [
      SaleItemEntity(
        productId: 'p1',
        productName: 'Camisa',
        productImgUrl: '',
        unitPrice: 50.0,
        quantity: 2,
      ),
    ],
    subtotal: 100.0,
    totalAmount: 100.0,
    paymentMethod: PaymentMethod.pix,
    status: DeliveryStatus.pending,
    scheduledAt: now.add(const Duration(hours: 2)),
    userId: 'u1',
    userName: 'Vendedor',
    createdAt: now,
  );

  final deliveryDelayed = DeliveryEntity(
    id: 'd2',
    saleId: 's2',
    saleNumber: '002',
    customerId: 'c2',
    customerName: 'Maria Santos',
    customerAddress: 'Rua B, 456',
    items: const [
      SaleItemEntity(
        productId: 'p2',
        productName: 'Calça',
        productImgUrl: '',
        unitPrice: 120.0,
        quantity: 1,
      ),
    ],
    subtotal: 120.0,
    totalAmount: 120.0,
    paymentMethod: PaymentMethod.dinheiro,
    status: DeliveryStatus.delayed,
    scheduledAt: now.subtract(const Duration(hours: 1)),
    userId: 'u1',
    userName: 'Vendedor',
    createdAt: now,
  );

  final deliveryCompleted = DeliveryEntity(
    id: 'd3',
    saleId: 's3',
    saleNumber: '003',
    customerId: 'c3',
    customerName: 'Carlos Souza',
    customerAddress: 'Rua C, 789',
    items: const [],
    subtotal: 80.0,
    totalAmount: 80.0,
    paymentMethod: PaymentMethod.credito,
    status: DeliveryStatus.completed,
    scheduledAt: now.subtract(const Duration(days: 1)),
    deliveredAt: now.subtract(const Duration(hours: 20)),
    userId: 'u1',
    userName: 'Vendedor',
    createdAt: now,
  );

  setUpAll(() {
    registerFallbackValue(deliveryPending);
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

  test('rescheduleDelivery delegates to repository updateDelivery', () async {
    when(() => mockRepository.updateDelivery(any())).thenAnswer((_) async {});
    final newDate = now.add(const Duration(days: 2));
    await viewModel.rescheduleDelivery(deliveryPending, newDate);
    verify(() => mockRepository.updateDelivery(any(that: isA<DeliveryEntity>().having((d) => d.scheduledAt, 'scheduledAt', newDate)))).called(1);
  });

  test('createDelivery creates and saves new DeliveryEntity in repository', () async {
    when(() => mockRepository.save(any())).thenAnswer((_) async {});
    final sale = SaleEntity(
      id: 's1',
      saleNumber: 'A1B2C3',
      items: const [],
      subtotal: 100.0,
      discountType: DiscountType.valueAmount,
      discountValue: 0.0,
      total: 100.0,
      paymentMethod: PaymentMethod.pix,
      customerId: 'c1',
      customerName: 'Cliente Teste',
      userId: 'u1',
      userName: 'Vendedor',
      status: SaleStatus.completed,
      createdAt: now,
    );

    final scheduled = now.add(const Duration(hours: 2));
    await viewModel.createDelivery(
      sale: sale,
      customerAddress: 'Rua das Flores, 123',
      customerPhone: '11999999999',
      scheduledAt: scheduled,
      observations: 'Entregar na portaria',
      userId: 'u1',
      userName: 'Vendedor',
    );

    verify(() => mockRepository.save(any(that: isA<DeliveryEntity>()
        .having((d) => d.saleId, 'saleId', 's1')
        .having((d) => d.saleNumber, 'saleNumber', 'A1B2C3')
        .having((d) => d.customerAddress, 'customerAddress', 'Rua das Flores, 123')
        .having((d) => d.customerPhone, 'customerPhone', '11999999999')
        .having((d) => d.observations, 'observations', 'Entregar na portaria')
        .having((d) => d.status, 'status', DeliveryStatus.pending)))).called(1);
  });

  test('updateDelivery delegates to repository updateDelivery', () async {
    when(() => mockRepository.updateDelivery(any())).thenAnswer((_) async {});
    final updated = deliveryPending.copyWith(
      customerAddress: 'Nova Rua, 999',
      observations: 'Novo recado',
    );
    await viewModel.updateDelivery(updated);
    verify(() => mockRepository.updateDelivery(updated)).called(1);
  });

  test('deleteDelivery delegates to repository delete', () async {
    when(() => mockRepository.delete(any())).thenAnswer((_) async {});
    await viewModel.deleteDelivery('d1');
    verify(() => mockRepository.delete('d1')).called(1);
  });
}
