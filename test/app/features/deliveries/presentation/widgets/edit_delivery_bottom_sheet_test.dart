import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/widgets/edit_delivery_bottom_sheet.dart';
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

  final delivery = DeliveryEntity(
    id: 'd1',
    saleId: 's1',
    saleNumber: 'A1B2C3',
    customerId: 'c1',
    customerName: 'Maria Silva',
    customerPhone: '11999999999',
    customerAddress: 'Rua Antiga, 100',
    observations: 'Observação inicial',
    items: const [],
    subtotal: 100.0,
    totalAmount: 100.0,
    paymentMethod: PaymentMethod.pix,
    status: DeliveryStatus.pending,
    scheduledAt: DateTime.now().add(const Duration(days: 2)),
    userId: 'u1',
    userName: 'Vendedor',
    createdAt: now,
  );

  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
    registerFallbackValue(delivery);
  });

  setUp(() {
    mockDeliveriesRepository = MockDeliveriesRepository();
    when(() => mockDeliveriesRepository.watchAll()).thenAnswer((_) => Stream.value([delivery]));
    deliveriesViewModel = DeliveriesViewModel(mockDeliveriesRepository);
  });

  testWidgets('EditDeliveryBottomSheet pre-populates fields and saves updated delivery', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockDeliveriesRepository.updateDelivery(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => EditDeliveryBottomSheet.show(
                context: context,
                delivery: delivery,
                viewModel: deliveriesViewModel,
              ),
              child: const Text('Open Edit'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Edit'));
    await tester.pumpAndSettle();

    // Valida dados pré-populados
    expect(find.text('Editar Entrega'), findsOneWidget);
    expect(find.text('Maria Silva'), findsOneWidget);
    expect(find.text('Rua Antiga, 100'), findsOneWidget);

    // Altera o endereço
    await tester.enterText(find.widgetWithText(TextFormField, 'Rua Antiga, 100'), 'Rua Nova, 500');
    await tester.pumpAndSettle();

    // Clica no botão Salvar Alterações
    await tester.ensureVisible(find.text('Salvar Alterações'));
    expect(find.text('Observação inicial'), findsOneWidget);
    await tester.tap(find.text('Salvar Alterações'));
    await tester.pumpAndSettle();

    // Verifica que chamou updateDelivery no repositório com os novos dados
    verify(() => mockDeliveriesRepository.updateDelivery(any(that: isA<DeliveryEntity>()
        .having((d) => d.id, 'id', 'd1')
        .having((d) => d.customerAddress, 'customerAddress', 'Rua Nova, 500')))).called(1);
  });

  testWidgets('EditDeliveryBottomSheet allows deleting delivery with confirmation dialog', (tester) async {
    when(() => mockDeliveriesRepository.delete(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => EditDeliveryBottomSheet.show(
                context: context,
                delivery: delivery,
                viewModel: deliveriesViewModel,
              ),
              child: const Text('Open Edit'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Edit'));
    await tester.pumpAndSettle();

    // Clica no botão de excluir no cabeçalho
    await tester.tap(find.byTooltip('Excluir Entrega'));
    await tester.pumpAndSettle();

    // Diálogo de confirmação deve aparecer
    expect(find.text('Excluir Entrega'), findsOneWidget);
    expect(find.text('Excluir'), findsOneWidget);

    // Confirma exclusão
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    verify(() => mockDeliveriesRepository.delete('d1')).called(1);
  });

  testWidgets('EditDeliveryBottomSheet allows selecting and switching customer', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockDeliveriesRepository.updateDelivery(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => EditDeliveryBottomSheet.show(
                context: context,
                delivery: delivery,
                viewModel: deliveriesViewModel,
              ),
              child: const Text('Open Edit'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Trocar Cliente'), findsOneWidget);
  });
}
