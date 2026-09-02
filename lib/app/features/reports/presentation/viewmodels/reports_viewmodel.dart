import 'dart:async';

import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
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
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/get_users_use_case.dart';

class ReportsViewModel extends BaseViewModel {
  final GetReportsUseCase _getReportsUseCase;
  final GetProductsUseCase _getProductsUseCase;
  final GetSalesUseCase _getSalesUseCase;
  final GetDeliveriesUseCase _getDeliveriesUseCase;
  final GetCustomersUseCase _getCustomersUseCase;
  final GetCustomerPaymentsUseCase _getCustomerPaymentsUseCase;
  final GetUsersUseCase? _getUsersUseCase;

  StreamSubscription<List<ProductEntity>>? _productsSub;
  StreamSubscription<List<SaleEntity>>? _salesSub;
  StreamSubscription<List<DeliveryEntity>>? _deliveriesSub;
  StreamSubscription<List<CustomerEntity>>? _customersSub;
  StreamSubscription<List<CustomerPaymentEntity>>? _paymentsSub;
  StreamSubscription<Result<List<UserEntity>>>? _usersSub;

  List<ProductEntity> _products = [];
  List<SaleEntity> _sales = [];
  List<DeliveryEntity> _deliveries = [];
  List<CustomerEntity> _customers = [];
  List<CustomerPaymentEntity> _payments = [];
  List<UserEntity> _users = [];

  ReportPeriod _period = ReportPeriod.today();
  ReportPeriod get period => _period;

  ReportsSummaryEntity? _summary;
  ReportsSummaryEntity? get summary => _summary;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Object? _error;
  Object? get error => _error;

  ReportsViewModel(
    this._getReportsUseCase,
    this._getProductsUseCase,
    this._getSalesUseCase,
    this._getDeliveriesUseCase,
    this._getCustomersUseCase,
    this._getCustomerPaymentsUseCase, [
    this._getUsersUseCase,
  ]);

  void listenAll() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _cancelSubscriptions();

    _productsSub = _getProductsUseCase.watchAll().listen(
      (data) {
        _products = data;
        _recalculate();
      },
      onError: _handleError,
    );

    _salesSub = _getSalesUseCase.watchAll(limit: 500).listen(
      (data) {
        _sales = data;
        _recalculate();
      },
      onError: _handleError,
    );

    _deliveriesSub = _getDeliveriesUseCase.watchAll(limit: 200).listen(
      (data) {
        _deliveries = data;
        _recalculate();
      },
      onError: _handleError,
    );

    _customersSub = _getCustomersUseCase.watchAll().listen(
      (data) {
        _customers = data;
        _recalculate();
      },
      onError: _handleError,
    );

    _paymentsSub = _getCustomerPaymentsUseCase.watchAll().listen(
      (data) {
        _payments = data;
        _recalculate();
      },
      onError: _handleError,
    );

    if (_getUsersUseCase != null) {
      _usersSub = _getUsersUseCase.listenAllUsers().listen(
        (result) {
          if (result is Success<List<UserEntity>>) {
            _users = result.value;
            _recalculate();
          }
        },
        onError: _handleError,
      );
    }
  }

  void setPeriodType(ReportPeriodType type) {
    if (_period.type == type && type != ReportPeriodType.custom) return;

    switch (type) {
      case ReportPeriodType.today:
        _period = ReportPeriod.today();
        break;
      case ReportPeriodType.week:
        _period = ReportPeriod.week();
        break;
      case ReportPeriodType.month:
        _period = ReportPeriod.month();
        break;
      case ReportPeriodType.year:
        _period = ReportPeriod.year();
        break;
      case ReportPeriodType.custom:
        // Mantém as datas customizadas se já existirem, ou usa hoje como base
        if (_period.type != ReportPeriodType.custom) {
          final now = DateTime.now();
          _period = ReportPeriod.custom(
            now.subtract(const Duration(days: 7)),
            now,
          );
        }
        break;
    }

    _recalculate();
  }

  void setCustomRange(DateTime start, DateTime end) {
    _period = ReportPeriod.custom(start, end);
    _recalculate();
  }

  void _recalculate() {
    _summary = _getReportsUseCase.execute(
      period: _period,
      products: _products,
      sales: _sales,
      deliveries: _deliveries,
      customers: _customers,
      customerPayments: _payments,
      users: _users,
    );
    _isLoading = false;
    notifyListeners();
  }

  void _handleError(Object e) {
    _error = e;
    _isLoading = false;
    notifyListeners();
  }

  void _cancelSubscriptions() {
    _productsSub?.cancel();
    _salesSub?.cancel();
    _deliveriesSub?.cancel();
    _customersSub?.cancel();
    _paymentsSub?.cancel();
    _usersSub?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
