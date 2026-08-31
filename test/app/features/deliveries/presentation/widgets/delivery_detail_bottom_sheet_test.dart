import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/delete_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/get_deliveries_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/save_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/update_delivery_status_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/update_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/widgets/delivery_detail_bottom_sheet.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class MockDeliveriesRepository extends Mock implements DeliveriesRepository {}

void main() {
  late MockDeliveriesRepository mockDeliveriesRepository;
  late DeliveriesViewModel deliveriesViewModel;

  final now = DateTime(2026, 8, 25, 10, 0);

  final pendingDelivery = DeliveryEntity(
    id: 'd1',
    saleId: 's1',
    saleNumber: 'A1B2C3',
    customerId: 'c1',
    customerName: 'Maria Silva',
    customerPhone: '11999999999',
    customerAddress: 'Rua das Flores, 100',
    observations: '',
    items: const [],
    subtotal: 100.0,
    totalAmount: 100.0,
    paymentMethod: PaymentMethod.pix,
    status: DeliveryStatus.pending,
    scheduledAt: now.add(const Duration(days: 1)),
    userId: 'u1',
    userName: 'Vendedor',
    createdAt: now,
  );

  final cancelledDelivery = pendingDelivery.copyWith(
    status: DeliveryStatus.cancelled,
  );

  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  setUp(() {
    mockDeliveriesRepository = MockDeliveriesRepository();
    when(() => mockDeliveriesRepository.watchAll()).thenAnswer((_) => Stream.value([]));
    deliveriesViewModel = DeliveriesViewModel(
      GetDeliveriesUseCase(mockDeliveriesRepository),
      SaveDeliveryUseCase(mockDeliveriesRepository),
      UpdateDeliveryUseCase(mockDeliveriesRepository),
      UpdateDeliveryStatusUseCase(mockDeliveriesRepository),
      DeleteDeliveryUseCase(mockDeliveriesRepository),
    );
  });

  testWidgets('DeliveryDetailBottomSheet does NOT show delete button when delivery is pending', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DeliveryDetailBottomSheet.show(
                context: context,
                delivery: pendingDelivery,
                viewModel: deliveriesViewModel,
              ),
              child: const Text('Open Details'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Details'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Excluir Entrega'), findsNothing);
    expect(find.text('Excluir Entrega'), findsNothing);
    expect(find.byTooltip('Editar Entrega'), findsOneWidget);
  });

  testWidgets('DeliveryDetailBottomSheet shows delete button when delivery is cancelled and allows deletion', (tester) async {
    when(() => mockDeliveriesRepository.delete(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DeliveryDetailBottomSheet.show(
                context: context,
                delivery: cancelledDelivery,
                viewModel: deliveriesViewModel,
              ),
              child: const Text('Open Details'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Details'));
    await tester.pumpAndSettle();

    // Botão de excluir visível no cabeçalho e na barra inferior
    expect(find.byTooltip('Excluir Entrega'), findsOneWidget);
    expect(find.text('Excluir Entrega'), findsOneWidget);
    expect(find.byTooltip('Editar Entrega'), findsNothing);

    // Clica no botão de excluir no cabeçalho
    await tester.tap(find.byTooltip('Excluir Entrega'));
    await tester.pumpAndSettle();

    // Diálogo de confirmação
    expect(find.text('Excluir'), findsOneWidget);
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    verify(() => mockDeliveriesRepository.delete('d1')).called(1);
  });

  testWidgets('DeliveryDetailBottomSheet shows delete button when delivery is completed', (tester) async {
    final completedDelivery = pendingDelivery.copyWith(
      status: DeliveryStatus.completed,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DeliveryDetailBottomSheet.show(
                context: context,
                delivery: completedDelivery,
                viewModel: deliveriesViewModel,
              ),
              child: const Text('Open Details'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Details'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Excluir Entrega'), findsOneWidget);
    expect(find.text('Excluir Entrega'), findsOneWidget);
    expect(find.byTooltip('Editar Entrega'), findsNothing);
  });
}
