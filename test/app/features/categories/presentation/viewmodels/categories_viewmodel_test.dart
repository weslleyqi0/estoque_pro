import 'dart:async';

import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/get_categories_use_case.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/count_products_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoriesRepository extends Mock implements CategoriesRepository {}
class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late MockCategoriesRepository mockCategoriesRepo;
  late MockProductsRepository mockProductsRepo;
  late GetCategoriesUseCase getCategoriesUseCase;
  late CountProductsUseCase countProductsUseCase;
  late StreamController<List<CategoryEntity>> categoriesController;
  late CategoriesViewModel viewModel;

  final cat1 = const CategoryEntity(id: 'c1', name: 'Bebidas', icon: 'cup');
  final cat2 = const CategoryEntity(id: 'c2', name: 'Alimentos', icon: 'food');

  setUp(() {
    mockCategoriesRepo = MockCategoriesRepository();
    mockProductsRepo = MockProductsRepository();
    getCategoriesUseCase = GetCategoriesUseCase(mockCategoriesRepo);
    countProductsUseCase = CountProductsUseCase(mockProductsRepo);

    categoriesController = StreamController<List<CategoryEntity>>.broadcast();
    when(() => mockCategoriesRepo.watchAll()).thenAnswer((_) => categoriesController.stream);
    when(() => mockProductsRepo.watchAll()).thenAnswer((_) => const Stream.empty());

    viewModel = CategoriesViewModel(getCategoriesUseCase, countProductsUseCase);
  });

  tearDown(() {
    categoriesController.close();
    viewModel.dispose();
  });

  test('listenAll streams and sorts categories by name', () async {
    viewModel.listenAll();
    expect(viewModel.isLoading, isTrue);

    categoriesController.add([cat1, cat2]);
    await pumpEventQueue();

    expect(viewModel.state, CategoriesLoadState.success);
    expect(viewModel.categories.length, 2);
    expect(viewModel.categories.first.name, 'Alimentos');
    expect(viewModel.categories.last.name, 'Bebidas');
  });

  test('filteredCategories filters by search query', () async {
    viewModel.listenAll();
    categoriesController.add([cat1, cat2]);
    await pumpEventQueue();

    viewModel.setSearchQuery('alim');
    expect(viewModel.filteredCategories.length, 1);
    expect(viewModel.filteredCategories.first.name, 'Alimentos');
  });
}
