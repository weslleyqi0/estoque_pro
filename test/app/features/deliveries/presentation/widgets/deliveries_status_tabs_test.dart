import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/delete_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/get_deliveries_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/save_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/update_delivery_status_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/update_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/widgets/deliveries_status_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDeliveriesRepository extends Mock implements DeliveriesRepository {}

void main() {
  late MockDeliveriesRepository mockRepository;
  late DeliveriesViewModel viewModel;

  setUp(() {
    mockRepository = MockDeliveriesRepository();
    when(() => mockRepository.watchAll()).thenAnswer((_) => Stream.value([]));
    viewModel = DeliveriesViewModel(
      GetDeliveriesUseCase(mockRepository),
      SaveDeliveryUseCase(mockRepository),
      UpdateDeliveryUseCase(mockRepository),
      UpdateDeliveryStatusUseCase(mockRepository),
      DeleteDeliveryUseCase(mockRepository),
    );
  });

  testWidgets('DeliveriesStatusTabs renders tabs in correct order: Todas, Atrasadas, Pendentes, Em andamento, Finalizadas, Canceladas', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeliveriesStatusTabs(
            viewModel: viewModel,
          ),
        ),
      ),
    );

    // Encontra todos os textos renderizados nas abas
    final tabLabels = ['Todas', 'Atrasadas', 'Pendentes', 'Em andamento', 'Finalizadas', 'Canceladas'];
    for (final label in tabLabels) {
      expect(find.text(label), findsOneWidget);
    }

    // Verifica a ordem horizontal das abas
    for (var i = 0; i < tabLabels.length - 1; i++) {
      final currentPos = tester.getTopLeft(find.text(tabLabels[i])).dx;
      final nextPos = tester.getTopLeft(find.text(tabLabels[i + 1])).dx;
      expect(currentPos, lessThan(nextPos), reason: '${tabLabels[i]} should be before ${tabLabels[i + 1]}');
    }
  });
}
