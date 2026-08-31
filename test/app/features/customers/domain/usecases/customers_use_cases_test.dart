import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customer_payments_repository.dart';
import 'package:estoque_pro/app/features/customers/domain/repositories/customers_repository.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/cancel_customer_payment_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/delete_customer_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customer_payments_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customers_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/register_customer_payment_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/save_customer_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/update_customer_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCustomersRepository extends Mock implements CustomersRepository {}
class MockCustomerPaymentsRepository extends Mock implements CustomerPaymentsRepository {}

void main() {
  late MockCustomersRepository mockCustomersRepository;
  late MockCustomerPaymentsRepository mockPaymentsRepository;

  const testCustomer = CustomerEntity(
    id: 'c1',
    name: 'Cliente Teste',
    phone: '11999999999',
  );

  final testPayment = CustomerPaymentEntity(
    id: 'p1',
    customerId: 'c1',
    customerName: 'Cliente Teste',
    amount: 150.0,
    paymentMethod: PaymentMethod.pix,
    userId: 'u1',
    userName: 'Vendedor',
    createdAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(testCustomer);
    registerFallbackValue(testPayment);
  });

  setUp(() {
    mockCustomersRepository = MockCustomersRepository();
    mockPaymentsRepository = MockCustomerPaymentsRepository();
  });

  group('GetCustomersUseCase', () {
    test('watchAll delegates to repository', () {
      when(() => mockCustomersRepository.watchAll()).thenAnswer((_) => Stream.value([testCustomer]));

      final useCase = GetCustomersUseCase(mockCustomersRepository);
      expect(useCase.watchAll(), emits([testCustomer]));
    });

    test('getAll delegates to repository', () async {
      when(() => mockCustomersRepository.getAll()).thenAnswer((_) async => const Result.success([testCustomer]));

      final useCase = GetCustomersUseCase(mockCustomersRepository);
      final result = await useCase.getAll();
      expect(result.value, equals([testCustomer]));
    });
  });

  group('GetCustomerPaymentsUseCase', () {
    test('watchAll delegates to repository', () {
      when(() => mockPaymentsRepository.watchAll()).thenAnswer((_) => Stream.value([testPayment]));

      final useCase = GetCustomerPaymentsUseCase(mockPaymentsRepository);
      expect(useCase.watchAll(), emits([testPayment]));
    });

    test('getAll delegates to repository', () async {
      when(() => mockPaymentsRepository.getAll()).thenAnswer((_) async => Result.success([testPayment]));

      final useCase = GetCustomerPaymentsUseCase(mockPaymentsRepository);
      final result = await useCase.getAll();
      expect(result.value, equals([testPayment]));
    });
  });

  group('SaveCustomerUseCase', () {
    test('returns BusinessRuleFailure if name is empty', () async {
      final useCase = SaveCustomerUseCase(mockCustomersRepository);
      final result = await useCase.call(const CustomerEntity(id: '', name: '  '));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('saves and returns success when valid', () async {
      when(() => mockCustomersRepository.save(any())).thenAnswer((_) async => const Result.success(null));

      final useCase = SaveCustomerUseCase(mockCustomersRepository);
      final result = await useCase.call(testCustomer);

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });

  group('UpdateCustomerUseCase', () {
    test('returns BusinessRuleFailure if id is empty', () async {
      final useCase = UpdateCustomerUseCase(mockCustomersRepository);
      final result = await useCase.call(const CustomerEntity(id: '', name: 'Cliente'));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('returns BusinessRuleFailure if name is empty', () async {
      final useCase = UpdateCustomerUseCase(mockCustomersRepository);
      final result = await useCase.call(const CustomerEntity(id: 'c1', name: ''));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('updates and returns success when valid', () async {
      when(() => mockCustomersRepository.update(any())).thenAnswer((_) async => const Result.success(null));

      final useCase = UpdateCustomerUseCase(mockCustomersRepository);
      final result = await useCase.call(testCustomer);

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });

  group('DeleteCustomerUseCase', () {
    test('returns BusinessRuleFailure if id is empty', () async {
      final useCase = DeleteCustomerUseCase(mockCustomersRepository);
      final result = await useCase.call('');

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('deletes and returns success when valid', () async {
      when(() => mockCustomersRepository.delete('c1')).thenAnswer((_) async => const Result.success(null));

      final useCase = DeleteCustomerUseCase(mockCustomersRepository);
      final result = await useCase.call('c1');

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });

  group('RegisterCustomerPaymentUseCase', () {
    test('returns BusinessRuleFailure if customerId is empty or amount <= 0', () async {
      final useCase = RegisterCustomerPaymentUseCase(mockPaymentsRepository);
      final result = await useCase.call(testPayment.copyWith(amount: 0));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('saves and returns success when valid', () async {
      when(() => mockPaymentsRepository.save(any())).thenAnswer((_) async => const Result.success(null));

      final useCase = RegisterCustomerPaymentUseCase(mockPaymentsRepository);
      final result = await useCase.call(testPayment);

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });

  group('CancelCustomerPaymentUseCase', () {
    test('returns BusinessRuleFailure if reason is empty', () async {
      final useCase = CancelCustomerPaymentUseCase(mockPaymentsRepository);
      final result = await useCase.call(testPayment, reason: '  ');

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('updates payment with cancelled status and reason', () async {
      when(() => mockPaymentsRepository.save(any())).thenAnswer((_) async => const Result.success(null));

      final useCase = CancelCustomerPaymentUseCase(mockPaymentsRepository);
      final result = await useCase.call(testPayment, reason: 'Pagamento duplicado');

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });
}
