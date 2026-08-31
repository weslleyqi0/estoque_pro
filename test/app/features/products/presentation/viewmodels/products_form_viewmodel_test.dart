import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_form_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late MockProductsRepository mockRepository;
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
    mockRepository = MockProductsRepository();
    viewModel = ProductsFormViewModel(mockRepository);
  });

  test('saveProductCommand fails when barcode already exists', () async {
    when(() => mockRepository.checkBarcodeExists('7891234567890')).thenAnswer((_) async => true);

    await viewModel.saveProductCommand.execute(testProduct);

    expect(viewModel.saveProductCommand.isFailure, isTrue);
    expect(
      viewModel.saveProductCommand.error?.message,
      contains('Já existe um produto cadastrado com este código de barras'),
    );
  });

  test('saveProductCommand succeeds when barcode does not exist', () async {
    when(() => mockRepository.checkBarcodeExists('7891234567890')).thenAnswer((_) async => false);
    when(() => mockRepository.save(any())).thenAnswer((_) async {});

    await viewModel.saveProductCommand.execute(testProduct);

    expect(viewModel.saveProductCommand.isSuccess, isTrue);
    verify(() => mockRepository.save(any())).called(1);
  });

  test('archiveProductCommand executes and archives current product', () async {
    when(() => mockRepository.archive('p1')).thenAnswer((_) async {});

    viewModel.init(testProduct);
    final success = await viewModel.archiveCurrentProduct();

    expect(success, isTrue);
    expect(viewModel.archiveProductCommand.isSuccess, isTrue);
    verify(() => mockRepository.archive('p1')).called(1);
  });

  test('unarchiveProductCommand executes and unarchives current product', () async {
    when(() => mockRepository.unarchive('p1')).thenAnswer((_) async {});

    viewModel.init(testProduct);
    final success = await viewModel.unarchiveCurrentProduct();

    expect(success, isTrue);
    expect(viewModel.unarchiveProductCommand.isSuccess, isTrue);
    verify(() => mockRepository.unarchive('p1')).called(1);
  });
}
