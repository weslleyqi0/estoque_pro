import 'dart:async';

import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/count_products_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/repositories/suppliers_repository.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/get_suppliers_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSuppliersRepository extends Mock implements SuppliersRepository {}
class MockProductsRepository extends Mock implements ProductsRepository {}

void main() {
  late MockSuppliersRepository mockSuppliersRepo;
  late MockProductsRepository mockProductsRepo;
  late GetSuppliersUseCase getSuppliersUseCase;
  late CountProductsUseCase countProductsUseCase;
  late StreamController<List<SupplierEntity>> suppliersController;
  late SuppliersViewModel viewModel;

  const sup1 = SupplierEntity(id: 's1', name: 'Distribuidora Beta', phone: '11999991111');
  const sup2 = SupplierEntity(id: 's2', name: 'Atacadista Alpha', phone: '11999992222');

  setUp(() {
    mockSuppliersRepo = MockSuppliersRepository();
    mockProductsRepo = MockProductsRepository();
    getSuppliersUseCase = GetSuppliersUseCase(mockSuppliersRepo);
    countProductsUseCase = CountProductsUseCase(mockProductsRepo);

    suppliersController = StreamController<List<SupplierEntity>>.broadcast();
    when(() => mockSuppliersRepo.watchAll()).thenAnswer((_) => suppliersController.stream);
    when(() => mockProductsRepo.watchAll()).thenAnswer((_) => const Stream.empty());

    viewModel = SuppliersViewModel(getSuppliersUseCase, countProductsUseCase);
  });

  tearDown(() {
    suppliersController.close();
    viewModel.dispose();
  });

  test('listenAll streams and sorts suppliers by name', () async {
    viewModel.listenAll();
    expect(viewModel.isLoading, isTrue);

    suppliersController.add([sup1, sup2]);
    await pumpEventQueue();

    expect(viewModel.state, SuppliersLoadState.success);
    expect(viewModel.suppliers.length, 2);
    expect(viewModel.suppliers.first.name, 'Atacadista Alpha');
    expect(viewModel.suppliers.last.name, 'Distribuidora Beta');
  });

  test('filteredSuppliers filters by search query', () async {
    viewModel.listenAll();
    suppliersController.add([sup1, sup2]);
    await pumpEventQueue();

    viewModel.setSearchQuery('alpha');
    expect(viewModel.filteredSuppliers.length, 1);
    expect(viewModel.filteredSuppliers.first.name, 'Atacadista Alpha');
  });
}
