import 'dart:async';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
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

  int _getDeliveryPriority(DeliveryEntity d) {
    if (d.isDelayed) return 0;
    if (d.status == DeliveryStatus.pending) return 1;
    if (d.status == DeliveryStatus.inProgress) return 2;
    return 3;
  }

  List<DeliveryEntity> _sortDeliveriesForAllTab(List<DeliveryEntity> list) {
    final sorted = List<DeliveryEntity>.from(list);
    sorted.sort((a, b) {
      final prioA = _getDeliveryPriority(a);
      final prioB = _getDeliveryPriority(b);

      if (prioA != prioB) {
        return prioA.compareTo(prioB);
      }

      // Se ambas forem atrasadas, pendentes ou em andamento:
      if (prioA < 3) {
        final dateCompare = a.scheduledAt.compareTo(b.scheduledAt);
        if (dateCompare != 0) return dateCompare;
        return b.createdAt.compareTo(a.createdAt);
      } else {
        // Ordena as outras por data decrescente (da mais recente para a mais antiga)
        final dateA = a.deliveredAt ?? a.scheduledAt;
        final dateB = b.deliveredAt ?? b.scheduledAt;
        final dateCompare = dateB.compareTo(dateA);
        if (dateCompare != 0) return dateCompare;
        return b.createdAt.compareTo(a.createdAt);
      }
    });
    return sorted;
  }

  List<DeliveryEntity> get delayedDeliveries {
    final list = _deliveries.where((d) => d.isDelayed).toList();
    list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return list;
  }

  List<DeliveryEntity> get pendingDeliveries {
    final list = _deliveries
        .where((d) => d.status == DeliveryStatus.pending && !d.isDelayed)
        .toList();
    list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return list;
  }

  List<DeliveryEntity> get inProgressDeliveries {
    final list = _deliveries
        .where((d) => d.status == DeliveryStatus.inProgress && !d.isDelayed)
        .toList();
    list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return list;
  }

  List<DeliveryEntity> get completedDeliveries {
    final list = _deliveries.where((d) => d.status == DeliveryStatus.completed).toList();
    list.sort((a, b) {
      final dateA = a.deliveredAt ?? a.scheduledAt;
      final dateB = b.deliveredAt ?? b.scheduledAt;
      final dateCompare = dateB.compareTo(dateA);
      if (dateCompare != 0) return dateCompare;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  List<DeliveryEntity> get cancelledDeliveries {
    final list = _deliveries.where((d) => d.status == DeliveryStatus.cancelled).toList();
    list.sort((a, b) {
      final dateA = a.scheduledAt;
      final dateB = b.scheduledAt;
      final dateCompare = dateB.compareTo(dateA);
      if (dateCompare != 0) return dateCompare;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

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
        list = _sortDeliveriesForAllTab(_deliveries);
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

  Future<void> createDelivery({
    required SaleEntity sale,
    required String customerAddress,
    required DateTime scheduledAt,
    String? customerPhone,
    String? observations,
    required String userId,
    required String userName,
  }) async {
    final delivery = DeliveryEntity(
      id: '',
      saleId: sale.id,
      saleNumber: sale.saleNumber,
      customerId: sale.customerId ?? '',
      customerName: sale.customerName ?? 'Cliente',
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      items: sale.items,
      subtotal: sale.subtotal,
      totalAmount: sale.total,
      paymentMethod: sale.paymentMethod,
      status: DeliveryStatus.pending,
      scheduledAt: scheduledAt,
      observations: observations ?? '',
      userId: userId,
      userName: userName,
      createdAt: DateTime.now(),
    );
    await _repository.save(delivery);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
