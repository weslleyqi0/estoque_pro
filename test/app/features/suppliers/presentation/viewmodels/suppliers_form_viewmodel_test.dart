import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/delete_supplier_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/save_supplier_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/update_supplier_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_form_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSuppliersRepository extends Mock implements SuppliersRepository {}

void main() {
  late MockSuppliersRepository mockRepository;
  late SuppliersFormViewmodel viewModel;

  const testSupplier = SupplierEntity(
    id: '123',
    name: 'Distribuidora Central',
    cnpj: '12345678000199',
    phone: '11999998888',
  );

  setUpAll(() {
    registerFallbackValue(testSupplier);
  });

  setUp(() {
    mockRepository = MockSuppliersRepository();
    viewModel = SuppliersFormViewmodel(
      SaveSupplierUseCase(mockRepository),
      UpdateSupplierUseCase(mockRepository),
      DeleteSupplierUseCase(mockRepository),
    );
  });

  test('saveSupplierCommand executes repository save', () async {
    when(() => mockRepository.save(any())).thenAnswer((_) async {});

    await viewModel.saveSupplierCommand.execute(testSupplier);

    verify(() => mockRepository.save(testSupplier)).called(1);
    expect(viewModel.saveSupplierCommand.isSuccess, isTrue);
  });

  test('updateSupplierCommand executes repository update', () async {
    when(() => mockRepository.update(any())).thenAnswer((_) async {});

    await viewModel.updateSupplierCommand.execute(testSupplier);

    verify(() => mockRepository.update(testSupplier)).called(1);
    expect(viewModel.updateSupplierCommand.isSuccess, isTrue);
  });

  test('deleteSupplierCommand executes repository delete', () async {
    when(() => mockRepository.delete(any())).thenAnswer((_) async {});

    await viewModel.deleteSupplierCommand.execute('123');

    verify(() => mockRepository.delete('123')).called(1);
    expect(viewModel.deleteSupplierCommand.isSuccess, isTrue);
  });
}
