import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/delete_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSalesRepository extends Mock implements SalesRepository {}

void main() {
  late MockSalesRepository mockSalesRepository;
  late GetSalesUseCase getSalesUseCase;
  late DeleteSaleUseCase deleteSaleUseCase;

  final sampleSale = SaleEntity(
    id: 's1',
    saleNumber: '#1001',
    items: const [],
    subtotal: 100.0,
    total: 100.0,
    paymentMethod: PaymentMethod.dinheiro,
    userId: 'u1',
    userName: 'Vendedor',
    status: SaleStatus.completed,
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockSalesRepository = MockSalesRepository();
    getSalesUseCase = GetSalesUseCase(mockSalesRepository);
    deleteSaleUseCase = DeleteSaleUseCase(mockSalesRepository);
  });

  group('GetSalesUseCase', () {
    test('watchAll delegates to repository with limit', () {
      when(() => mockSalesRepository.watchAll(limit: 50)).thenAnswer((_) => Stream.value([sampleSale]));

      final stream = getSalesUseCase.watchAll(limit: 50);

      expect(stream, emits([sampleSale]));
      verify(() => mockSalesRepository.watchAll(limit: 50)).called(1);
    });
  });

  group('DeleteSaleUseCase', () {
    test('returns BusinessRuleFailure when saleId is empty', () async {
      final result = await deleteSaleUseCase('');

      expect(result.isFailure, isTrue);
      expect(result.error, isA<BusinessRuleFailure>());
      verifyNever(() => mockSalesRepository.delete(any()));
    });

    test('deletes sale and returns success when saleId is valid', () async {
      when(() => mockSalesRepository.delete('s1')).thenAnswer((_) async => const Result.success(null));

      final result = await deleteSaleUseCase('s1');

      expect(result.isSuccess, isTrue);
      expect(result.value, isTrue);
      verify(() => mockSalesRepository.delete('s1')).called(1);
    });
  });
}
