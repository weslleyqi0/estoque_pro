import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/delete_category_use_case.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/get_categories_use_case.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/save_category_use_case.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/update_category_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoriesRepository extends Mock implements CategoriesRepository {}

void main() {
  late MockCategoriesRepository mockRepository;

  const testCategory = CategoryEntity(
    id: 'cat1',
    name: 'Eletrônicos',
    icon: 'phone',
  );

  setUpAll(() {
    registerFallbackValue(testCategory);
  });

  setUp(() {
    mockRepository = MockCategoriesRepository();
  });

  group('GetCategoriesUseCase', () {
    test('watchAll delegates to repository', () {
      when(() => mockRepository.watchAll()).thenAnswer((_) => Stream.value([testCategory]));

      final useCase = GetCategoriesUseCase(mockRepository);
      expect(useCase.watchAll(), emits([testCategory]));
    });

    test('getAll delegates to repository', () async {
      when(() => mockRepository.getAll()).thenAnswer((_) async => const Result.success([testCategory]));

      final useCase = GetCategoriesUseCase(mockRepository);
      final result = await useCase.getAll();
      expect(result.value, equals([testCategory]));
    });
  });

  group('SaveCategoryUseCase', () {
    test('returns BusinessRuleFailure if name is empty', () async {
      final useCase = SaveCategoryUseCase(mockRepository);
      final result = await useCase.call(const CategoryEntity(id: '', name: '  ', icon: 'phone'));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('saves and returns success when valid', () async {
      when(() => mockRepository.save(any())).thenAnswer((_) async => const Result.success(null));

      final useCase = SaveCategoryUseCase(mockRepository);
      final result = await useCase.call(testCategory);

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });

  group('UpdateCategoryUseCase', () {
    test('returns BusinessRuleFailure if id is empty', () async {
      final useCase = UpdateCategoryUseCase(mockRepository);
      final result = await useCase.call(const CategoryEntity(id: '', name: 'Roupas', icon: 'shirt'));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('returns BusinessRuleFailure if name is empty', () async {
      final useCase = UpdateCategoryUseCase(mockRepository);
      final result = await useCase.call(const CategoryEntity(id: 'cat1', name: '', icon: 'shirt'));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('updates and returns success when valid', () async {
      when(() => mockRepository.update(any())).thenAnswer((_) async => const Result.success(null));

      final useCase = UpdateCategoryUseCase(mockRepository);
      final result = await useCase.call(testCategory);

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });

  group('DeleteCategoryUseCase', () {
    test('returns BusinessRuleFailure if id is empty', () async {
      final useCase = DeleteCategoryUseCase(mockRepository);
      final result = await useCase.call('');

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('deletes and returns success when valid', () async {
      when(() => mockRepository.delete('cat1')).thenAnswer((_) async => const Result.success(null));

      final useCase = DeleteCategoryUseCase(mockRepository);
      final result = await useCase.call('cat1');

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });
}
