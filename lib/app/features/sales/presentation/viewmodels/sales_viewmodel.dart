import 'dart:async';

import 'package:estoque_pro/app/core/utils/string_extensions.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:flutter/foundation.dart';

enum SalesLoadState { idle, loading, success, failure }

enum SalesFilterTab {
  all('Todas'),
  inProgress('Em andamento'),
  completed('Finalizadas'),
  fiado('Fiados'),
  edited('Editadas'),
  cancelled('Canceladas');

  final String label;
  const SalesFilterTab(this.label);
}

class SalesViewModel extends ChangeNotifier {
  final SalesRepository _repository;

  StreamSubscription<List<SaleEntity>>? _salesSubscription;

  SalesLoadState _state = SalesLoadState.idle;
  SalesLoadState get state => _state;

  List<SaleEntity> _sales = [];
  List<SaleEntity> get sales => _sales;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _expandedSaleId;
  String? get expandedSaleId => _expandedSaleId;

  Object? _error;
  Object? get error => _error;

  List<SaleEntity> get inProgressSales => _sales.where((s) => s.status == SaleStatus.inProgress).toList();

  SalesViewModel(this._repository);

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleExpand(String saleId) {
    if (_expandedSaleId == saleId) {
      _expandedSaleId = null;
    } else {
      _expandedSaleId = saleId;
    }
    notifyListeners();
  }

  List<SaleEntity> get filteredSales {
    if (_searchQuery.trim().isEmpty) return _sales;

    final query = _searchQuery.withoutDiacritics.toLowerCase().trim();

    return _sales.where((sale) {
      final matchesNumber = sale.saleNumber.toLowerCase().contains(query);
      final matchesCustomer = sale.customerName?.withoutDiacritics.toLowerCase().contains(query) ?? false;
      final matchesPayment = sale.paymentMethod.label.withoutDiacritics.toLowerCase().contains(query);
      final matchesStatus = sale.status.label.withoutDiacritics.toLowerCase().contains(query);
      final matchesUser = sale.userName.withoutDiacritics.toLowerCase().contains(query);
      final matchesItem = sale.items.any((i) => i.productName.withoutDiacritics.toLowerCase().contains(query));

      return matchesNumber || matchesCustomer || matchesPayment || matchesStatus || matchesUser || matchesItem;
    }).toList();
  }

  Map<DateTime, List<SaleEntity>> get groupedFilteredSales {
    final Map<DateTime, List<SaleEntity>> grouped = {};
    for (final sale in filteredSales) {
      final dateKey = DateTime(sale.createdAt.year, sale.createdAt.month, sale.createdAt.day);
      grouped.putIfAbsent(dateKey, () => []).add(sale);
    }
    return grouped;
  }

  void listenAll() {
    if (_salesSubscription != null) return;

    _state = SalesLoadState.loading;
    notifyListeners();

    _salesSubscription?.cancel();
    _salesSubscription = _repository.watchAll().listen(
      (list) {
        _sales = list;
        _state = SalesLoadState.success;
        notifyListeners();
      },
      onError: (e) {
        _error = e;
        _state = SalesLoadState.failure;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _salesSubscription?.cancel();
    super.dispose();
  }
}
