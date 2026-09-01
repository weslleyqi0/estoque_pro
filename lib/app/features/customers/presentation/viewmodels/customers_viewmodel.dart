import 'dart:async';

import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/core/utils/list_extensions.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/get_customers_use_case.dart';

enum CustomersLoadState { idle, loading, success, failure }

class CustomersViewModel extends BaseViewModel {
  final GetCustomersUseCase _getCustomersUseCase;

  StreamSubscription<List<CustomerEntity>>? _customersSubscription;

  CustomersLoadState _state = CustomersLoadState.idle;
  CustomersLoadState get state => _state;
  bool get isLoading => _state == CustomersLoadState.loading;

  List<CustomerEntity> _customers = [];
  List<CustomerEntity> get customers => _customers;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<CustomerEntity> get filteredCustomers {
    if (_searchQuery.trim().isEmpty) return _customers;

    final query = _searchQuery.toLowerCase().trim();
    final queryDigits = query.replaceAll(RegExp(r'\D'), '');
    final isSearchingNumbers = queryDigits.isNotEmpty;

    return _customers.where((customer) {
      final nameMatches = customer.name.toLowerCase().contains(query);
      final addressMatches = customer.address?.toLowerCase().contains(query) ?? false;

      var cpfMatches = false;
      var phoneMatches = false;

      if (isSearchingNumbers) {
        final cpfDigits = customer.cpf?.replaceAll(RegExp(r'\D'), '') ?? '';
        final phoneDigits = customer.phone?.replaceAll(RegExp(r'\D'), '') ?? '';

        cpfMatches = cpfDigits.contains(queryDigits);
        phoneMatches = phoneDigits.contains(queryDigits);
      } else {
        cpfMatches = customer.cpf?.toLowerCase().contains(query) ?? false;
        phoneMatches = customer.phone?.toLowerCase().contains(query) ?? false;
      }

      return nameMatches || addressMatches || cpfMatches || phoneMatches;
    }).toList();
  }

  List<CustomerEntity> get activeCustomers {
    return filteredCustomers.where((c) => c.isActive).toList();
  }

  Object? _error;
  Object? get error => _error;

  CustomersViewModel(this._getCustomersUseCase);

  void listenAll() {
    _state = CustomersLoadState.loading;
    notifyListeners();

    _customersSubscription?.cancel();
    _customersSubscription = _getCustomersUseCase.watchAll().listen(
      (list) {
        _customers = list.sortByName((a) => a.name);
        _state = CustomersLoadState.success;
        notifyListeners();
      },
      onError: (e) {
        _error = e;
        _state = CustomersLoadState.failure;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _customersSubscription?.cancel();
    super.dispose();
  }
}
