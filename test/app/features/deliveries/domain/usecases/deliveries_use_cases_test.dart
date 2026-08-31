import 'package:estoque_pro/app/core/errors/app_failure.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/delete_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/get_deliveries_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/save_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/update_delivery_status_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/update_delivery_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDeliveriesRepository extends Mock implements DeliveriesRepository {}

void main() {
  late MockDeliveriesRepository mockRepository;

  final testDelivery = DeliveryEntity(
    id: 'd1',
    saleId: 's1',
    saleNumber: '#1001',
    customerId: 'c1',
    customerName: 'Cliente 1',
    customerAddress: 'Rua Principal, 100',
    items: const [],
    subtotal: 50.0,
    totalAmount: 50.0,
    paymentMethod: PaymentMethod.pix,
    status: DeliveryStatus.pending,
    scheduledAt: DateTime.now(),
    userId: 'u1',
    userName: 'User 1',
    createdAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(testDelivery);
    registerFallbackValue(DeliveryStatus.completed);
  });

  setUp(() {
    mockRepository = MockDeliveriesRepository();
  });

  group('GetDeliveriesUseCase', () {
    test('watchAll delegates to repository', () {
      when(() => mockRepository.watchAll(limit: any(named: 'limit')))
          .thenAnswer((_) => Stream.value([testDelivery]));

      final useCase = GetDeliveriesUseCase(mockRepository);
      expect(useCase.watchAll(), emits([testDelivery]));
    });
  });

  group('SaveDeliveryUseCase', () {
    test('returns BusinessRuleFailure if address is empty', () async {
      final useCase = SaveDeliveryUseCase(mockRepository);
      final result = await useCase.call(testDelivery.copyWith(customerAddress: '  '));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('saves and returns success when valid', () async {
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      final useCase = SaveDeliveryUseCase(mockRepository);
      final result = await useCase.call(testDelivery);

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });

  group('UpdateDeliveryUseCase', () {
    test('returns BusinessRuleFailure if id is empty', () async {
      final useCase = UpdateDeliveryUseCase(mockRepository);
      final result = await useCase.call(testDelivery.copyWith(id: ''));

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('updates and returns success when valid', () async {
      when(() => mockRepository.updateDelivery(any())).thenAnswer((_) async {});

      final useCase = UpdateDeliveryUseCase(mockRepository);
      final result = await useCase.call(testDelivery);

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });

  group('UpdateDeliveryStatusUseCase', () {
    test('returns BusinessRuleFailure if deliveryId is empty', () async {
      final useCase = UpdateDeliveryStatusUseCase(mockRepository);
      final result = await useCase.call('', DeliveryStatus.completed);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('updates status and returns success when valid', () async {
      when(() => mockRepository.updateStatus(any(), any(), deliveredAt: any(named: 'deliveredAt')))
          .thenAnswer((_) async {});

      final useCase = UpdateDeliveryStatusUseCase(mockRepository);
      final result = await useCase.call('d1', DeliveryStatus.completed);

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });

  group('DeleteDeliveryUseCase', () {
    test('returns BusinessRuleFailure if deliveryId is empty', () async {
      final useCase = DeleteDeliveryUseCase(mockRepository);
      final result = await useCase.call('');

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
    });

    test('deletes and returns success when valid', () async {
      when(() => mockRepository.delete('d1')).thenAnswer((_) async {});

      final useCase = DeleteDeliveryUseCase(mockRepository);
      final result = await useCase.call('d1');

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
    });
  });
}
