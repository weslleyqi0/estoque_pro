import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late MockProductsRepository mockRepository;
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
    mockRepository = MockProductsRepository();
    viewModel = ProductsViewModel(mockRepository);
  });

  test('listenAll updates products list and command state', () async {
    when(() => mockRepository.watchAll()).thenAnswer((_) => Stream.value([testProduct]));

    viewModel.listenAll();

    expect(viewModel.state, equals(CommandState.running));
    expect(viewModel.isLoading, isTrue);

    await Future.delayed(Duration.zero);

    expect(viewModel.state, equals(CommandState.success));
    expect(viewModel.isSuccess, isTrue);
    expect(viewModel.products.length, equals(1));
    expect(viewModel.products.first.name, equals('Camisa Polo'));
  });

  test('archiveProductCommand executes and archives product', () async {
    when(() => mockRepository.archive('p1')).thenAnswer((_) async {});

    await viewModel.archiveProductCommand.execute('p1');

    expect(viewModel.archiveProductCommand.isSuccess, isTrue);
    verify(() => mockRepository.archive('p1')).called(1);
  });

  test('unarchiveProductCommand executes and unarchives product', () async {
    when(() => mockRepository.unarchive('p1')).thenAnswer((_) async {});

    await viewModel.unarchiveProductCommand.execute('p1');

    expect(viewModel.unarchiveProductCommand.isSuccess, isTrue);
    verify(() => mockRepository.unarchive('p1')).called(1);
  });

  test('deletePermanentlyCommand executes and permanently deletes product', () async {
    when(() => mockRepository.deletePermanently('p1')).thenAnswer((_) async {});

    await viewModel.deletePermanentlyCommand.execute('p1');

    expect(viewModel.deletePermanentlyCommand.isSuccess, isTrue);
    verify(() => mockRepository.deletePermanently('p1')).called(1);
  });
}
