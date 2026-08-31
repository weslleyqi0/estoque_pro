import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/delete_category_use_case.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/save_category_use_case.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/update_category_use_case.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_form_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoriesRepository extends Mock implements CategoriesRepository {}

void main() {
  late MockCategoriesRepository mockRepository;
  late CategoriesFormViewmodel viewModel;

  const testCategory = CategoryEntity(
    id: '123',
    name: 'Eletrônicos',
    icon: 'phone',
  );

  setUpAll(() {
    registerFallbackValue(testCategory);
  });

  setUp(() {
    mockRepository = MockCategoriesRepository();
    viewModel = CategoriesFormViewmodel(
      SaveCategoryUseCase(mockRepository),
      UpdateCategoryUseCase(mockRepository),
      DeleteCategoryUseCase(mockRepository),
    );
  });

  test('saveCategoryCommand executes repository save', () async {
    when(() => mockRepository.save(any())).thenAnswer((_) async {});

    await viewModel.saveCategoryCommand.execute(testCategory);

    verify(() => mockRepository.save(testCategory)).called(1);
    expect(viewModel.saveCategoryCommand.isSuccess, isTrue);
  });

  test('updateCategoryCommand executes repository update', () async {
    when(() => mockRepository.update(any())).thenAnswer((_) async {});

    await viewModel.updateCategoryCommand.execute(testCategory);

    verify(() => mockRepository.update(testCategory)).called(1);
    expect(viewModel.updateCategoryCommand.isSuccess, isTrue);
  });

  test('deleteCategoryCommand executes repository delete', () async {
    when(() => mockRepository.delete(any())).thenAnswer((_) async {});

    await viewModel.deleteCategoryCommand.execute('123');

    verify(() => mockRepository.delete('123')).called(1);
    expect(viewModel.deleteCategoryCommand.isSuccess, isTrue);
  });
}
