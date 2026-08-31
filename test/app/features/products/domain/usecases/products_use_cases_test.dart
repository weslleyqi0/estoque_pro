import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/adjust_stock_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/archive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/delete_product_permanently_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/get_products_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/save_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/unarchive_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/update_product_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/watch_product_history_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late MockProductsRepository mockRepository;

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
    registerFallbackValue(
      ProductHistoryEntity(
        action: ProductHistoryAction.add,
        quantity: 1,
        oldStock: 0,
        newStock: 1,
        date: DateTime.now(),
        note: 'teste',
        userName: 'Admin',
      ),
    );
  });

  setUp(() {
    mockRepository = MockProductsRepository();
  });

  group('GetProductsUseCase', () {
    test('watchAll delegates to repository', () {
      when(() => mockRepository.watchAll()).thenAnswer((_) => Stream.value([testProduct]));
      final useCase = GetProductsUseCase(mockRepository);

      expect(useCase.watchAll(), emits([testProduct]));
    });

    test('getAll delegates to repository', () async {
      when(() => mockRepository.getAll()).thenAnswer((_) async => const Result.success([testProduct]));
      final useCase = GetProductsUseCase(mockRepository);

      final result = await useCase.getAll();
      expect(result.value, [testProduct]);
    });
  });

  group('SaveProductUseCase', () {
    test('fails if product name is empty', () async {
      final useCase = SaveProductUseCase(mockRepository);
      final result = await useCase(testProduct.copyWith(name: '   '));

      expect(result.isFailure, isTrue);
      expect(result.error?.message, equals('O nome do produto é obrigatório.'));
    });

    test('fails if barcode already exists', () async {
      when(() => mockRepository.checkBarcodeExists('7891234567890')).thenAnswer((_) async => const Result.success(true));
      final useCase = SaveProductUseCase(mockRepository);
      final result = await useCase(testProduct);

      expect(result.isFailure, isTrue);
      expect(result.error?.message, contains('Já existe um produto cadastrado'));
    });

    test('succeeds when valid', () async {
      when(() => mockRepository.checkBarcodeExists('7891234567890')).thenAnswer((_) async => const Result.success(false));
      when(() => mockRepository.save(any())).thenAnswer((_) async => const Result.success(null));
      final useCase = SaveProductUseCase(mockRepository);
      final result = await useCase(testProduct);

      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.save(testProduct)).called(1);
    });
  });

  group('UpdateProductUseCase', () {
    test('fails if id is empty', () async {
      final useCase = UpdateProductUseCase(mockRepository);
      final result = await useCase(testProduct.copyWith(id: ''));

      expect(result.isFailure, isTrue);
    });

    test('succeeds when valid', () async {
      when(
        () => mockRepository.checkBarcodeExists(
          '7891234567890',
          ignoreId: 'p1',
        ),
      ).thenAnswer((_) async => const Result.success(false));
      when(() => mockRepository.update(any())).thenAnswer((_) async => const Result.success(null));
      final useCase = UpdateProductUseCase(mockRepository);
      final result = await useCase(testProduct);

      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.update(testProduct)).called(1);
    });
  });

  group('Archive / Unarchive / Delete UseCases', () {
    test('ArchiveProductUseCase succeeds with valid id', () async {
      when(() => mockRepository.archive('p1')).thenAnswer((_) async => const Result.success(null));
      final useCase = ArchiveProductUseCase(mockRepository);
      final result = await useCase('p1');

      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.archive('p1')).called(1);
    });

    test('UnarchiveProductUseCase succeeds with valid id', () async {
      when(() => mockRepository.unarchive('p1')).thenAnswer((_) async => const Result.success(null));
      final useCase = UnarchiveProductUseCase(mockRepository);
      final result = await useCase('p1');

      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.unarchive('p1')).called(1);
    });

    test('DeleteProductPermanentlyUseCase succeeds with valid id', () async {
      when(() => mockRepository.deletePermanently('p1')).thenAnswer((_) async => const Result.success(null));
      final useCase = DeleteProductPermanentlyUseCase(mockRepository);
      final result = await useCase('p1');

      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.deletePermanently('p1')).called(1);
    });
  });

  group('AdjustStockUseCase', () {
    test('fails if quantityDiff is 0', () async {
      final useCase = AdjustStockUseCase(mockRepository);
      final result = await useCase(
        productId: 'p1',
        quantityDiff: 0,
        history: ProductHistoryEntity(
          action: ProductHistoryAction.add,
          quantity: 0,
          oldStock: 5,
          newStock: 5,
          date: DateTime.now(),
          note: 'teste',
          userName: 'Admin',
        ),
      );

      expect(result.isFailure, isTrue);
    });
  });

  group('WatchProductHistoryUseCase', () {
    test('delegates to repository', () {
      when(() => mockRepository.watchHistory('p1', limit: 20)).thenAnswer((_) => Stream.value([]));
      final useCase = WatchProductHistoryUseCase(mockRepository);

      expect(useCase('p1', limit: 20), emits([]));
    });
  });
}
