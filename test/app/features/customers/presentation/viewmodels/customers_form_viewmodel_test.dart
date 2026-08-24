import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_form_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCustomersRepository extends Mock implements CustomersRepository {}

void main() {
  late MockCustomersRepository mockRepository;
  late CustomersFormViewModel viewModel;

  const testCustomer = CustomerEntity(
    id: '123',
    name: 'Cliente Teste',
    address: 'Rua Central, 1',
    cpf: '12345678901',
    phone: '11988887777',
    isActive: true,
  );

  setUpAll(() {
    registerFallbackValue(testCustomer);
  });

  setUp(() {
    mockRepository = MockCustomersRepository();
    viewModel = CustomersFormViewModel(mockRepository);
  });

  test('saveCustomerCommand executes repository save', () async {
    when(() => mockRepository.save(any())).thenAnswer((_) async {});

    await viewModel.saveCustomerCommand.execute(testCustomer);

    verify(() => mockRepository.save(testCustomer)).called(1);
    expect(viewModel.saveCustomerCommand.isSuccess, isTrue);
  });

  test('updateCustomerCommand executes repository update', () async {
    when(() => mockRepository.update(any())).thenAnswer((_) async {});

    await viewModel.updateCustomerCommand.execute(testCustomer);

    verify(() => mockRepository.update(testCustomer)).called(1);
    expect(viewModel.updateCustomerCommand.isSuccess, isTrue);
  });

  test('deleteCustomerCommand executes repository delete', () async {
    when(() => mockRepository.delete(any())).thenAnswer((_) async {});

    await viewModel.deleteCustomerCommand.execute('123');

    verify(() => mockRepository.delete('123')).called(1);
    expect(viewModel.deleteCustomerCommand.isSuccess, isTrue);
  });
}
