import 'dart:async';

import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/delete_product_permanently_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/get_products_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/unarchive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/archived_products_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}
class MockUnarchiveProductUseCase extends Mock implements UnarchiveProductUseCase {}
class MockDeleteProductPermanentlyUseCase extends Mock implements DeleteProductPermanentlyUseCase {}

void main() {
  late MockGetProductsUseCase mockGetProductsUseCase;
  late MockUnarchiveProductUseCase mockUnarchiveProductUseCase;
  late MockDeleteProductPermanentlyUseCase mockDeleteProductPermanentlyUseCase;
  late ArchivedProductsViewModel viewModel;

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    mockUnarchiveProductUseCase = MockUnarchiveProductUseCase();
    mockDeleteProductPermanentlyUseCase = MockDeleteProductPermanentlyUseCase();
    viewModel = ArchivedProductsViewModel(
      mockGetProductsUseCase,
      mockUnarchiveProductUseCase,
      mockDeleteProductPermanentlyUseCase,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  const archivedProd = ProductEntity(
    id: 'prod-1',
    name: 'Produto Arquivado',
    imgUrl: '',
    description: '',
    categories: [],
    price: 10.0,
    costPrice: 5.0,
    stock: 0,
    minStock: 0,
    isArchived: true,
  );

  group('ArchivedProductsViewModel', () {
    test('listenAll populates archivedProducts and filters by query', () async {
      final controller = StreamController<List<ProductEntity>>();
      when(() => mockGetProductsUseCase.watchAll()).thenAnswer((_) => controller.stream);

      viewModel.listenAll();

      controller.add([
        archivedProd,
        const ProductEntity(
          id: 'prod-2',
          name: 'Produto Ativo',
          imgUrl: '',
          description: '',
          categories: [],
          price: 10.0,
          costPrice: 5.0,
          stock: 5,
          minStock: 1,
          isArchived: false,
        ),
      ]);
      await Future.delayed(Duration.zero);

      expect(viewModel.archivedProducts.length, equals(1));
      expect(viewModel.archivedProducts.first.name, equals('Produto Arquivado'));

      viewModel.setSearchQuery('Arquivado');
      expect(viewModel.filteredArchivedProducts.length, equals(1));

      viewModel.setSearchQuery('Inexistente');
      expect(viewModel.filteredArchivedProducts, isEmpty);

      await controller.close();
    });

    test('unarchiveProductCommand executes unarchive usecase', () async {
      when(() => mockUnarchiveProductUseCase(any()))
          .thenAnswer((_) async => const Result.success(true));

      await viewModel.unarchiveProductCommand.execute('prod-1');

      verify(() => mockUnarchiveProductUseCase('prod-1')).called(1);
      expect(viewModel.unarchiveProductCommand.isSuccess, isTrue);
    });

    test('deletePermanentlyCommand executes delete usecase', () async {
      when(() => mockDeleteProductPermanentlyUseCase(any()))
          .thenAnswer((_) async => const Result.success(true));

      await viewModel.deletePermanentlyCommand.execute('prod-1');

      verify(() => mockDeleteProductPermanentlyUseCase('prod-1')).called(1);
      expect(viewModel.deletePermanentlyCommand.isSuccess, isTrue);
    });
  });
}
