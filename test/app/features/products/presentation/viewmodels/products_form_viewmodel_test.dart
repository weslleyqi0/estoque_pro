import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/adjust_stock_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/archive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/save_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/unarchive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/update_product_use_case.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_form_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSaveProductUseCase extends Mock implements SaveProductUseCase {}
class MockUpdateProductUseCase extends Mock implements UpdateProductUseCase {}
class MockArchiveProductUseCase extends Mock implements ArchiveProductUseCase {}
class MockUnarchiveProductUseCase extends Mock implements UnarchiveProductUseCase {}
class MockAdjustStockUseCase extends Mock implements AdjustStockUseCase {}

void main() {
  late MockSaveProductUseCase mockSaveProductUseCase;
  late MockUpdateProductUseCase mockUpdateProductUseCase;
  late MockArchiveProductUseCase mockArchiveProductUseCase;
  late MockUnarchiveProductUseCase mockUnarchiveProductUseCase;
  late MockAdjustStockUseCase mockAdjustStockUseCase;
  late ProductsFormViewModel viewModel;

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

  setUpAll(() {
    registerFallbackValue(testProduct);
  });

  setUp(() {
    mockSaveProductUseCase = MockSaveProductUseCase();
    mockUpdateProductUseCase = MockUpdateProductUseCase();
    mockArchiveProductUseCase = MockArchiveProductUseCase();
    mockUnarchiveProductUseCase = MockUnarchiveProductUseCase();
    mockAdjustStockUseCase = MockAdjustStockUseCase();

    viewModel = ProductsFormViewModel(
      mockSaveProductUseCase,
      mockUpdateProductUseCase,
      mockArchiveProductUseCase,
      mockUnarchiveProductUseCase,
      mockAdjustStockUseCase,
    );
  });

  test('saveProductCommand fails when use case returns failure', () async {
    when(() => mockSaveProductUseCase(any())).thenAnswer(
      (_) async => Result.failure(
        const BusinessRuleFailure(message: 'Já existe um produto cadastrado com este código de barras.'),
      ),
    );

    await viewModel.saveProductCommand.execute(testProduct);

    expect(viewModel.saveProductCommand.isFailure, isTrue);
    expect(
      viewModel.saveProductCommand.error?.message,
      contains('Já existe um produto cadastrado com este código de barras'),
    );
  });

  test('saveProductCommand succeeds when use case succeeds', () async {
    when(() => mockSaveProductUseCase(any())).thenAnswer((_) async => const Result.success(true));

    await viewModel.saveProductCommand.execute(testProduct);

    expect(viewModel.saveProductCommand.isSuccess, isTrue);
    verify(() => mockSaveProductUseCase(any())).called(1);
  });

  test('archiveProductCommand executes and archives current product', () async {
    when(() => mockArchiveProductUseCase('p1')).thenAnswer((_) async => const Result.success(true));

    viewModel.init(testProduct);
    final success = await viewModel.archiveCurrentProduct();

    expect(success, isTrue);
    expect(viewModel.archiveProductCommand.isSuccess, isTrue);
    verify(() => mockArchiveProductUseCase('p1')).called(1);
  });

  test('unarchiveProductCommand executes and unarchives current product', () async {
    when(() => mockUnarchiveProductUseCase('p1')).thenAnswer((_) async => const Result.success(true));

    viewModel.init(testProduct);
    final success = await viewModel.unarchiveCurrentProduct();

    expect(success, isTrue);
    expect(viewModel.unarchiveProductCommand.isSuccess, isTrue);
    verify(() => mockUnarchiveProductUseCase('p1')).called(1);
  });
}
