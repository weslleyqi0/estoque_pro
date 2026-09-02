import 'dart:async';

import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customer_payments_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customers_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/get_deliveries_use_case.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/usecases/get_products_use_case.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/report_period.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/reports_summary_entity.dart';
import 'package:estoque_pro/app/features/reports/domain/usecases/get_reports_use_case.dart';
import 'package:estoque_pro/app/features/reports/presentation/viewmodels/reports_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetReportsUseCase extends Mock implements GetReportsUseCase {}
class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}
class MockGetSalesUseCase extends Mock implements GetSalesUseCase {}
class MockGetDeliveriesUseCase extends Mock implements GetDeliveriesUseCase {}
class MockGetCustomersUseCase extends Mock implements GetCustomersUseCase {}
class MockGetCustomerPaymentsUseCase extends Mock implements GetCustomerPaymentsUseCase {}

class FakeReportPeriod extends Fake implements ReportPeriod {}

void main() {
  late MockGetReportsUseCase mockGetReportsUseCase;
  late MockGetProductsUseCase mockGetProductsUseCase;
  late MockGetSalesUseCase mockGetSalesUseCase;
  late MockGetDeliveriesUseCase mockGetDeliveriesUseCase;
  late MockGetCustomersUseCase mockGetCustomersUseCase;
  late MockGetCustomerPaymentsUseCase mockGetCustomerPaymentsUseCase;

  late StreamController<List<ProductEntity>> productsController;
  late StreamController<List<SaleEntity>> salesController;
  late StreamController<List<DeliveryEntity>> deliveriesController;
  late StreamController<List<CustomerEntity>> customersController;
  late StreamController<List<CustomerPaymentEntity>> paymentsController;

  late ReportsViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeReportPeriod());
  });

  setUp(() {
    mockGetReportsUseCase = MockGetReportsUseCase();
    mockGetProductsUseCase = MockGetProductsUseCase();
    mockGetSalesUseCase = MockGetSalesUseCase();
    mockGetDeliveriesUseCase = MockGetDeliveriesUseCase();
    mockGetCustomersUseCase = MockGetCustomersUseCase();
    mockGetCustomerPaymentsUseCase = MockGetCustomerPaymentsUseCase();

    productsController = StreamController<List<ProductEntity>>.broadcast();
    salesController = StreamController<List<SaleEntity>>.broadcast();
    deliveriesController = StreamController<List<DeliveryEntity>>.broadcast();
    customersController = StreamController<List<CustomerEntity>>.broadcast();
    paymentsController = StreamController<List<CustomerPaymentEntity>>.broadcast();

    when(() => mockGetProductsUseCase.watchAll()).thenAnswer((_) => productsController.stream);
    when(() => mockGetSalesUseCase.watchAll(limit: any(named: 'limit'))).thenAnswer((_) => salesController.stream);
    when(() => mockGetDeliveriesUseCase.watchAll(limit: any(named: 'limit'))).thenAnswer((_) => deliveriesController.stream);
    when(() => mockGetCustomersUseCase.watchAll()).thenAnswer((_) => customersController.stream);
    when(() => mockGetCustomerPaymentsUseCase.watchAll()).thenAnswer((_) => paymentsController.stream);

    when(() => mockGetReportsUseCase.execute(
          period: any(named: 'period'),
          products: any(named: 'products'),
          sales: any(named: 'sales'),
          deliveries: any(named: 'deliveries'),
          customers: any(named: 'customers'),
          customerPayments: any(named: 'customerPayments'),
        )).thenReturn(ReportsSummaryEntity(period: ReportPeriod.today()));

    viewModel = ReportsViewModel(
      mockGetReportsUseCase,
      mockGetProductsUseCase,
      mockGetSalesUseCase,
      mockGetDeliveriesUseCase,
      mockGetCustomersUseCase,
      mockGetCustomerPaymentsUseCase,
    );
  });

  tearDown(() {
    viewModel.dispose();
    productsController.close();
    salesController.close();
    deliveriesController.close();
    customersController.close();
    paymentsController.close();
  });

  group('ReportsViewModel', () {
    test('listenAll subscribes to streams and updates summary', () async {
      viewModel.listenAll();
      expect(viewModel.isLoading, isTrue);

      productsController.add([]);
      await pumpEventQueue();

      expect(viewModel.summary, isNotNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('setPeriodType changes active period and triggers recalculate', () async {
      viewModel.listenAll();

      viewModel.setPeriodType(ReportPeriodType.week);

      expect(viewModel.period.type, ReportPeriodType.week);
      verify(() => mockGetReportsUseCase.execute(
            period: any(named: 'period'),
            products: any(named: 'products'),
            sales: any(named: 'sales'),
            deliveries: any(named: 'deliveries'),
            customers: any(named: 'customers'),
            customerPayments: any(named: 'customerPayments'),
          )).called(greaterThanOrEqualTo(1));
    });
  });
}
