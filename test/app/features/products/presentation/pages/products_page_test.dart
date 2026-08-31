import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/archive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/delete_product_permanently_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/get_products_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/unarchive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/watch_product_history_use_case.dart';
import 'package:estoque_pro/app/features/products/presentation/pages/products_page.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late MockProductsRepository mockProductsRepository;

  setUp(() {
    mockProductsRepository = MockProductsRepository();
    when(() => mockProductsRepository.watchAll()).thenAnswer((_) => Stream.value(<ProductEntity>[]));
  });

  ProductsViewModel createViewModel() {
    return ProductsViewModel(
      GetProductsUseCase(mockProductsRepository),
      ArchiveProductUseCase(mockProductsRepository),
      UnarchiveProductUseCase(mockProductsRepository),
      DeleteProductPermanentlyUseCase(mockProductsRepository),
      WatchProductHistoryUseCase(mockProductsRepository),
    );
  }

  testWidgets('ProductsPage instantiates viewModel via factory and sets initialShowOnlyLowStock', (tester) async {
    late ProductsViewModel createdVm;

    await tester.pumpWidget(
      MaterialApp(
        home: ProductsPage(
          viewModelFactory: () {
            createdVm = createViewModel();
            return createdVm;
          },
          initialShowOnlyLowStock: true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(createdVm.showOnlyLowStock, isTrue);
  });

  testWidgets('ProductsPage instantiates viewModel and sets initialSearchQuery', (tester) async {
    late ProductsViewModel createdVm;

    await tester.pumpWidget(
      MaterialApp(
        home: ProductsPage(
          viewModelFactory: () {
            createdVm = createViewModel();
            return createdVm;
          },
          initialSearchQuery: 'Refrigerante',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(createdVm.searchQuery, 'Refrigerante');
  });
}
