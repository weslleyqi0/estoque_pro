import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/archive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/delete_product_permanently_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/get_products_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/unarchive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/watch_product_history_use_case.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockArchiveProductUseCase extends Mock implements ArchiveProductUseCase {}

class MockUnarchiveProductUseCase extends Mock implements UnarchiveProductUseCase {}

class MockDeleteProductPermanentlyUseCase extends Mock implements DeleteProductPermanentlyUseCase {}

class MockWatchProductHistoryUseCase extends Mock implements WatchProductHistoryUseCase {}

void main() {
  late MockGetProductsUseCase mockGetProductsUseCase;
  late MockArchiveProductUseCase mockArchiveProductUseCase;
  late MockUnarchiveProductUseCase mockUnarchiveProductUseCase;
  late MockDeleteProductPermanentlyUseCase mockDeleteProductPermanentlyUseCase;
  late MockWatchProductHistoryUseCase mockWatchProductHistoryUseCase;
  late ProductsViewModel viewModel;

  const testProduct = ProductEntity(
    id: 'p1',
    name: 'Camisa Polo',
    imgUrl: '',
    description: 'Camisa azul',
    price: 49.90,
    stock: 5,
    minStock: 2,
    categories: [],
    barcode: '7891234567890',
  );

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    mockArchiveProductUseCase = MockArchiveProductUseCase();
    mockUnarchiveProductUseCase = MockUnarchiveProductUseCase();
    mockDeleteProductPermanentlyUseCase = MockDeleteProductPermanentlyUseCase();
    mockWatchProductHistoryUseCase = MockWatchProductHistoryUseCase();

    viewModel = ProductsViewModel(
      mockGetProductsUseCase,
      mockArchiveProductUseCase,
      mockUnarchiveProductUseCase,
      mockDeleteProductPermanentlyUseCase,
      mockWatchProductHistoryUseCase,
    );
  });

  test('listenAll updates products list and command state', () async {
    when(() => mockGetProductsUseCase.watchAll()).thenAnswer((_) => Stream.value([testProduct]));

    viewModel.listenAll();

    expect(viewModel.state, equals(ProductsLoadState.loading));
    expect(viewModel.isLoading, isTrue);

    await Future.delayed(Duration.zero);

    expect(viewModel.state, equals(ProductsLoadState.success));
    expect(viewModel.isSuccess, isTrue);
    expect(viewModel.products.length, equals(1));
    expect(viewModel.products.first.name, equals('Camisa Polo'));
  });

  test('archiveProductCommand executes and archives product', () async {
    when(() => mockArchiveProductUseCase('p1')).thenAnswer((_) async => const Result.success(true));

    await viewModel.archiveProductCommand.execute('p1');

    expect(viewModel.archiveProductCommand.isSuccess, isTrue);
    verify(() => mockArchiveProductUseCase('p1')).called(1);
  });

  test('unarchiveProductCommand executes and unarchives product', () async {
    when(() => mockUnarchiveProductUseCase('p1')).thenAnswer((_) async => const Result.success(true));

    await viewModel.unarchiveProductCommand.execute('p1');

    expect(viewModel.unarchiveProductCommand.isSuccess, isTrue);
    verify(() => mockUnarchiveProductUseCase('p1')).called(1);
  });

  test('deletePermanentlyCommand executes and permanently deletes product', () async {
    when(() => mockDeleteProductPermanentlyUseCase('p1')).thenAnswer((_) async => const Result.success(true));

    await viewModel.deletePermanentlyCommand.execute('p1');

    expect(viewModel.deletePermanentlyCommand.isSuccess, isTrue);
    verify(() => mockDeleteProductPermanentlyUseCase('p1')).called(1);
  });

  test('listenProductHistory updates productHistory list', () async {
    final historyItem = ProductHistoryEntity(
      action: ProductHistoryAction.add,
      quantity: 5,
      oldStock: 0,
      newStock: 5,
      date: DateTime(2026, 1, 1),
    );

    when(() => mockWatchProductHistoryUseCase('p1', limit: 6)).thenAnswer((_) => Stream.value([historyItem]));

    viewModel.listenProductHistory('p1', limit: 6);

    await Future.delayed(Duration.zero);

    expect(viewModel.productHistory.length, equals(1));
    expect(viewModel.productHistory.first.quantity, equals(5));
  });

  test('empty stock filter updates filtered products list', () async {
    final outOfStockProduct = testProduct.copyWith(id: 'p2', name: 'Calça Jeans', stock: 0);
    when(() => mockGetProductsUseCase.watchAll()).thenAnswer((_) => Stream.value([testProduct, outOfStockProduct]));

    viewModel.listenAll();
    await Future.delayed(Duration.zero);

    expect(viewModel.products.length, equals(2));
    expect(viewModel.emptyStockProducts.length, equals(1));
    expect(viewModel.emptyStockProducts.first.name, equals('Calça Jeans'));

    viewModel.setShowOnlyEmptyStock(true);
    expect(viewModel.filteredProducts.length, equals(1));
    expect(viewModel.filteredProducts.first.id, equals('p2'));

    viewModel.clearEmptyStockFilter();
    expect(viewModel.filteredProducts.length, equals(2));
  });
}
