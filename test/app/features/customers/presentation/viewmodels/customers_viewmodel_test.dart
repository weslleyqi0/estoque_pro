import 'dart:async';

import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customers_use_case.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCustomersRepository extends Mock implements CustomersRepository {}

void main() {
  late MockCustomersRepository mockRepository;
  late CustomersViewModel viewModel;
  late StreamController<List<CustomerEntity>> streamController;

  final customersList = [
    const CustomerEntity(
      id: '1',
      name: 'Carlos Oliveira',
      cpf: '11122233344',
      phone: '11987654321',
      address: 'Rua A, 100',
      isActive: true,
    ),
    const CustomerEntity(
      id: '2',
      name: 'Ana Paula',
      cpf: '55566677788',
      phone: '21912345678',
      address: 'Av B, 200',
      isActive: false,
    ),
    const CustomerEntity(
      id: '3',
      name: 'Bruno Lima',
      cpf: '99988877766',
      phone: '31998877665',
      address: 'Rua C, 300',
      isActive: true,
    ),
  ];

  setUp(() {
    mockRepository = MockCustomersRepository();
    streamController = StreamController<List<CustomerEntity>>.broadcast();
    when(() => mockRepository.watchAll()).thenAnswer((_) => streamController.stream);
    viewModel = CustomersViewModel(GetCustomersUseCase(mockRepository));
  });

  tearDown(() {
    streamController.close();
    viewModel.dispose();
  });

  test('listenAll streams and sorts customers by name', () async {
    viewModel.listenAll();
    expect(viewModel.state, CustomersLoadState.loading);

    streamController.add(customersList);
    await pumpEventQueue();

    expect(viewModel.state, CustomersLoadState.success);
    expect(viewModel.customers.length, 3);
    expect(viewModel.customers[0].name, 'Ana Paula');
    expect(viewModel.customers[1].name, 'Bruno Lima');
    expect(viewModel.customers[2].name, 'Carlos Oliveira');
  });

  test('filteredCustomers filters by name, cpf, and phone', () async {
    viewModel.listenAll();
    streamController.add(customersList);
    await pumpEventQueue();

    viewModel.setSearchQuery('bruno');
    expect(viewModel.filteredCustomers.length, 1);
    expect(viewModel.filteredCustomers.first.name, 'Bruno Lima');

    viewModel.setSearchQuery('111.222');
    expect(viewModel.filteredCustomers.length, 1);
    expect(viewModel.filteredCustomers.first.name, 'Carlos Oliveira');

    viewModel.setSearchQuery('2191234');
    expect(viewModel.filteredCustomers.length, 1);
    expect(viewModel.filteredCustomers.first.name, 'Ana Paula');
  });

  test('activeCustomers returns only active customers', () async {
    viewModel.listenAll();
    streamController.add(customersList);
    await pumpEventQueue();

    expect(viewModel.activeCustomers.length, 2);
    expect(viewModel.activeCustomers.any((c) => c.name == 'Ana Paula'), isFalse);
  });
}
