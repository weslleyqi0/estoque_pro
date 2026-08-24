import 'dart:async';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:flutter/foundation.dart';

enum DeliveryFilterTab {
  all('Todas'),
  pending('Pendentes'),
  inProgress('Em andamento'),
  completed('Finalizadas'),
  delayed('Atrasadas'),
  cancelled('Canceladas');

  final String label;
  const DeliveryFilterTab(this.label);
}

enum DeliveriesState { initial, loading, loaded, error }

class DeliveriesViewModel extends ChangeNotifier {
  final DeliveriesRepository _repository;

  DeliveriesViewModel(this._repository);

  StreamSubscription<List<DeliveryEntity>>? _subscription;

  List<DeliveryEntity> _deliveries = [];
  List<DeliveryEntity> get deliveries => _deliveries;

  DeliveriesState _state = DeliveriesState.initial;
  DeliveriesState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DeliveryFilterTab _selectedTab = DeliveryFilterTab.all;
  DeliveryFilterTab get selectedTab => _selectedTab;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSelectedTab(DeliveryFilterTab tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void listenAll() {
    if (_subscription != null) return;

    _state = DeliveriesState.loading;
    notifyListeners();

    _subscription = _repository.watchAll().listen(
      (data) {
        _deliveries = data;
        _state = DeliveriesState.loaded;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _state = DeliveriesState.error;
        _errorMessage = error.toString().replaceAll('Exception: ', '');
        notifyListeners();
      },
    );
  }

  List<DeliveryEntity> get delayedDeliveries =>
      _deliveries.where((d) => d.isDelayed).toList();

  List<DeliveryEntity> get pendingDeliveries => _deliveries
      .where((d) => d.status == DeliveryStatus.pending && !d.isDelayed)
      .toList();

  List<DeliveryEntity> get inProgressDeliveries => _deliveries
      .where((d) => d.status == DeliveryStatus.inProgress && !d.isDelayed)
      .toList();

  List<DeliveryEntity> get completedDeliveries =>
      _deliveries.where((d) => d.status == DeliveryStatus.completed).toList();

  List<DeliveryEntity> get cancelledDeliveries =>
      _deliveries.where((d) => d.status == DeliveryStatus.cancelled).toList();

  int getTabCount(DeliveryFilterTab tab) {
    switch (tab) {
      case DeliveryFilterTab.all:
        return _deliveries.length;
      case DeliveryFilterTab.pending:
        return pendingDeliveries.length;
      case DeliveryFilterTab.inProgress:
        return inProgressDeliveries.length;
      case DeliveryFilterTab.completed:
        return completedDeliveries.length;
      case DeliveryFilterTab.delayed:
        return delayedDeliveries.length;
      case DeliveryFilterTab.cancelled:
        return cancelledDeliveries.length;
    }
  }

  List<DeliveryEntity> get filteredDeliveries {
    List<DeliveryEntity> list;
    switch (_selectedTab) {
      case DeliveryFilterTab.all:
        list = _deliveries;
        break;
      case DeliveryFilterTab.pending:
        list = pendingDeliveries;
        break;
      case DeliveryFilterTab.inProgress:
        list = inProgressDeliveries;
        break;
      case DeliveryFilterTab.completed:
        list = completedDeliveries;
        break;
      case DeliveryFilterTab.delayed:
        list = delayedDeliveries;
        break;
      case DeliveryFilterTab.cancelled:
        list = cancelledDeliveries;
        break;
    }

    if (_searchQuery.isEmpty) return list;

    return list.where((d) {
      final matchCustomer = d.customerName.toLowerCase().contains(_searchQuery);
      final matchSale = d.saleNumber.toLowerCase().contains(_searchQuery);
      final matchAddress = d.customerAddress.toLowerCase().contains(_searchQuery);
      final matchPhone = d.customerPhone?.toLowerCase().contains(_searchQuery) ?? false;
      final matchItems = d.items.any((i) => i.productName.toLowerCase().contains(_searchQuery));
      return matchCustomer || matchSale || matchAddress || matchPhone || matchItems;
    }).toList();
  }

  Future<void> updateDeliveryStatus(
    String deliveryId,
    DeliveryStatus status, {
    DateTime? deliveredAt,
  }) async {
    await _repository.updateStatus(deliveryId, status, deliveredAt: deliveredAt);
  }

  Future<void> rescheduleDelivery(
    DeliveryEntity delivery,
    DateTime newScheduledAt,
  ) async {
    final updated = delivery.copyWith(
      scheduledAt: newScheduledAt,
      status: delivery.status == DeliveryStatus.delayed ? DeliveryStatus.pending : delivery.status,
    );
    await _repository.updateDelivery(updated);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
