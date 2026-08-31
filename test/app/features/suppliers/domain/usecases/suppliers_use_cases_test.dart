import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/delete_supplier_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/get_suppliers_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/save_supplier_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/update_supplier_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSuppliersRepository extends Mock implements SuppliersRepository {}

void main() {
  late MockSuppliersRepository mockRepository;

  const testSupplier = SupplierEntity(
    id: 'sup1',
    name: 'Distribuidora ABC',
    cnpj: '12345678000199',
    phone: '11999998888',
  );

  setUpAll(() {
    registerFallbackValue(testSupplier);
  });

  setUp(() {
    mockRepository = MockSuppliersRepository();
  });

  group('GetSuppliersUseCase', () {
    test('watchAll delegates to repository', () {
      when(() => mockRepository.watchAll()).thenAnswer((_) => Stream.value([testSupplier]));

      final useCase = GetSuppliersUseCase(mockRepository);
      expect(useCase.watchAll(), emits([testSupplier]));
    });

    test('getAll delegates to repository', () async {
      when(() => mockRepository.getAll()).thenAnswer((_) async => const Result.success([testSupplier]));

      final useCase = GetSuppliersUseCase(mockRepository);
      final result = await useCase.getAll();
      expect(result.value, equals([testSupplier]));
    });
  });

  group('SaveSupplierUseCase', () {
    test('returns BusinessRuleFailure if name is empty', () async {
      final useCase = SaveSupplierUseCase(mockRepository);
      final result = await useCase.call(const SupplierEntity(id: '', name: '  '));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('saves and returns success when valid', () async {
      when(() => mockRepository.save(any())).thenAnswer((_) async => const Result.success(null));

      final useCase = SaveSupplierUseCase(mockRepository);
      final result = await useCase.call(testSupplier);

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });

  group('UpdateSupplierUseCase', () {
    test('returns BusinessRuleFailure if id is empty', () async {
      final useCase = UpdateSupplierUseCase(mockRepository);
      final result = await useCase.call(const SupplierEntity(id: '', name: 'Fornecedor'));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('returns BusinessRuleFailure if name is empty', () async {
      final useCase = UpdateSupplierUseCase(mockRepository);
      final result = await useCase.call(const SupplierEntity(id: 'sup1', name: ''));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('updates and returns success when valid', () async {
      when(() => mockRepository.update(any())).thenAnswer((_) async => const Result.success(null));

      final useCase = UpdateSupplierUseCase(mockRepository);
      final result = await useCase.call(testSupplier);

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });

  group('DeleteSupplierUseCase', () {
    test('returns BusinessRuleFailure if id is empty', () async {
      final useCase = DeleteSupplierUseCase(mockRepository);
      final result = await useCase.call('');

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('deletes and returns success when valid', () async {
      when(() => mockRepository.delete('sup1')).thenAnswer((_) async => const Result.success(null));

      final useCase = DeleteSupplierUseCase(mockRepository);
      final result = await useCase.call('sup1');

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });
}
