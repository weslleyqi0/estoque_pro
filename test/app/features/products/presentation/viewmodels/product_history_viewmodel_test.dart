import 'dart:async';

import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/watch_product_history_use_case.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/product_history_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWatchProductHistoryUseCase extends Mock implements WatchProductHistoryUseCase {}

void main() {
  late MockWatchProductHistoryUseCase mockWatchProductHistoryUseCase;
  late ProductHistoryViewModel viewModel;

  setUp(() {
    mockWatchProductHistoryUseCase = MockWatchProductHistoryUseCase();
    viewModel = ProductHistoryViewModel(mockWatchProductHistoryUseCase);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('ProductHistoryViewModel', () {
    test('listenHistory updates history list and state', () async {
      final controller = StreamController<List<ProductHistoryEntity>>();
      when(() => mockWatchProductHistoryUseCase(any(), limit: any(named: 'limit')))
          .thenAnswer((_) => controller.stream);

      viewModel.listenHistory('prod-1');
      expect(viewModel.isLoading, isTrue);

      final entry = ProductHistoryEntity(
        action: ProductHistoryAction.add,
        quantity: 5,
        oldStock: 10,
        newStock: 15,
        date: DateTime(2026, 1, 1),
      );

      controller.add([entry]);
      await Future.delayed(Duration.zero);

      expect(viewModel.history.length, equals(1));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.state, equals(ProductHistoryLoadState.success));

      await controller.close();
    });

    test('listenHistory handles error state', () async {
      final controller = StreamController<List<ProductHistoryEntity>>();
      when(() => mockWatchProductHistoryUseCase(any(), limit: any(named: 'limit')))
          .thenAnswer((_) => controller.stream);

      viewModel.listenHistory('prod-1');

      controller.addError(Exception('History error'));
      await Future.delayed(Duration.zero);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.state, equals(ProductHistoryLoadState.failure));

      await controller.close();
    });
  });
}
