import 'dart:async';

import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/core/utils/string_extensions.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/get_deliveries_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/delete_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/get_sales_use_case.dart';

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

class SalesViewModel extends BaseViewModel {
  final GetSalesUseCase _getSalesUseCase;
  final DeleteSaleUseCase _deleteSaleUseCase;
  final GetDeliveriesUseCase? _getDeliveriesUseCase;

  late final Command1<bool, String> deleteSaleCommand;

  SalesViewModel(
    this._getSalesUseCase,
    this._deleteSaleUseCase, [
    this._getDeliveriesUseCase,
  ]) {
    deleteSaleCommand = Command1((saleId) async {
      return _deleteSaleUseCase(saleId);
    });
  }

  StreamSubscription<List<SaleEntity>>? _salesSubscription;
  StreamSubscription<List<DeliveryEntity>>? _deliveriesSubscription;

  Map<String, DeliveryEntity> _deliveriesBySaleId = {};

  DeliveryEntity? getDeliveryForSale(String saleId, [String? saleNumber]) {
    return _deliveriesBySaleId[saleId] ?? (saleNumber != null ? _deliveriesBySaleId[saleNumber] : null);
  }

  CommandState _state = CommandState.idle;
  CommandState get state => _state;
  bool get isLoading => _state == CommandState.running;

  List<SaleEntity> _sales = [];
  List<SaleEntity> get sales => _sales;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _expandedSaleId;
  String? get expandedSaleId => _expandedSaleId;

  Object? _error;
  Object? get error => _error;

  SalesFilterTab _selectedTab = SalesFilterTab.all;
  SalesFilterTab get selectedTab => _selectedTab;

  void setSelectedTab(SalesFilterTab tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  List<SaleEntity> get inProgressSales => _sales.where((s) => s.status == SaleStatus.inProgress).toList();

  int getTabCount(SalesFilterTab tab, {List<SaleEntity>? draftSales}) => switch (tab) {
    SalesFilterTab.all => _sales.length,
    SalesFilterTab.inProgress => _sales.where((s) => s.status == SaleStatus.inProgress).length,
    SalesFilterTab.completed => _sales.where((s) => s.status == SaleStatus.completed).length,
    SalesFilterTab.fiado => _sales.where((s) => s.paymentMethod == PaymentMethod.fiado).length,
    SalesFilterTab.edited => _sales.where((s) => s.isEdited).length,
    SalesFilterTab.cancelled => _sales.where((s) => s.status == SaleStatus.cancelled).length,
  };

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
    final list = switch (_selectedTab) {
      SalesFilterTab.all => _sales,
      SalesFilterTab.inProgress => _sales.where((s) => s.status == SaleStatus.inProgress),
      SalesFilterTab.completed => _sales.where((s) => s.status == SaleStatus.completed),
      SalesFilterTab.fiado => _sales.where((s) => s.paymentMethod == PaymentMethod.fiado),
      SalesFilterTab.edited => _sales.where((s) => s.isEdited),
      SalesFilterTab.cancelled => _sales.where((s) => s.status == SaleStatus.cancelled),
    }.toList();

    if (_searchQuery.trim().isEmpty) return list;

    final query = _searchQuery.withoutDiacritics.toLowerCase().trim();

    return list.where((sale) {
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

    _state = CommandState.running;
    notifyListeners();

    _salesSubscription?.cancel();
    _salesSubscription = _getSalesUseCase.watchAll().listen(
      (list) {
        _sales = list;
        _state = CommandState.success;
        notifyListeners();
      },
      onError: (e) {
        _error = e;
        _state = CommandState.failure;
        notifyListeners();
      },
    );

    if (_getDeliveriesUseCase != null && _deliveriesSubscription == null) {
      _deliveriesSubscription = _getDeliveriesUseCase.watchAll().listen((deliveries) {
        final map = <String, DeliveryEntity>{};
        for (final d in deliveries) {
          if (d.saleId.isNotEmpty) {
            map[d.saleId] = d;
          }
          if (d.saleNumber.isNotEmpty) {
            map[d.saleNumber] = d;
          }
        }
        _deliveriesBySaleId = map;
        notifyListeners();
      });
    }
  }

  Future<void> deleteSale(String saleId) async {
    await deleteSaleCommand.execute(saleId);
    if (deleteSaleCommand.isFailure) {
      throw deleteSaleCommand.error!;
    }
  }

  @override
  void dispose() {
    _salesSubscription?.cancel();
    _deliveriesSubscription?.cancel();
    super.dispose();
  }
}
