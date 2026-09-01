import 'dart:async';

import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/delete_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/get_deliveries_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/save_delivery_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/update_delivery_status_use_case.dart';
import 'package:estoque_pro/app/features/deliveries/domain/usecases/update_delivery_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';

enum DeliveryFilterTab {
  all('Todas'),
  delayed('Atrasadas'),
  pending('Pendentes'),
  inProgress('Em andamento'),
  completed('Finalizadas'),
  cancelled('Canceladas');

  final String label;
  const DeliveryFilterTab(this.label);
}

enum DeliveriesState { initial, loading, loaded, error }

class DeliveriesViewModel extends BaseViewModel {
  final GetDeliveriesUseCase _getDeliveriesUseCase;
  final SaveDeliveryUseCase _saveDeliveryUseCase;
  final UpdateDeliveryUseCase _updateDeliveryUseCase;
  final UpdateDeliveryStatusUseCase _updateDeliveryStatusUseCase;
  final DeleteDeliveryUseCase _deleteDeliveryUseCase;

  DeliveriesViewModel(
    this._getDeliveriesUseCase,
    this._saveDeliveryUseCase,
    this._updateDeliveryUseCase,
    this._updateDeliveryStatusUseCase,
    this._deleteDeliveryUseCase,
  );

  StreamSubscription<List<DeliveryEntity>>? _subscription;

  List<DeliveryEntity> _deliveries = [];
  List<DeliveryEntity> get deliveries => _deliveries;

  DeliveriesState _state = DeliveriesState.initial;
  DeliveriesState get state => _state;
  bool get isLoading => _state == DeliveriesState.loading;

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

    _subscription = _getDeliveriesUseCase.watchAll().listen(
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

      if (prioA < 3) {
        final dateCompare = a.scheduledAt.compareTo(b.scheduledAt);
        if (dateCompare != 0) return dateCompare;
        return b.createdAt.compareTo(a.createdAt);
      } else {
        final dateCompare = b.scheduledAt.compareTo(a.scheduledAt);
        if (dateCompare != 0) return dateCompare;
        return b.createdAt.compareTo(a.createdAt);
      }
    });
    return sorted;
  }

  List<DeliveryEntity> get delayedDeliveries => _deliveries.where((d) => d.isDelayed).toList();
  List<DeliveryEntity> get pendingDeliveries =>
      _deliveries.where((d) => d.status == DeliveryStatus.pending && !d.isDelayed).toList();
  List<DeliveryEntity> get inProgressDeliveries =>
      _deliveries.where((d) => d.status == DeliveryStatus.inProgress && !d.isDelayed).toList();
  List<DeliveryEntity> get completedDeliveries =>
      _deliveries.where((d) => d.status == DeliveryStatus.completed).toList();
  List<DeliveryEntity> get cancelledDeliveries =>
      _deliveries.where((d) => d.status == DeliveryStatus.cancelled).toList();

  int get delayedCount => _deliveries.where((d) => d.isDelayed).length;
  int get pendingCount => _deliveries.where((d) => d.status == DeliveryStatus.pending && !d.isDelayed).length;
  int get inProgressCount => _deliveries.where((d) => d.status == DeliveryStatus.inProgress && !d.isDelayed).length;
  int get completedCount => _deliveries.where((d) => d.status == DeliveryStatus.completed).length;
  int get cancelledCount => _deliveries.where((d) => d.status == DeliveryStatus.cancelled).length;

  int countForTab(DeliveryFilterTab tab) => switch (tab) {
        DeliveryFilterTab.all => _deliveries.length,
        DeliveryFilterTab.delayed => delayedCount,
        DeliveryFilterTab.pending => pendingCount,
        DeliveryFilterTab.inProgress => inProgressCount,
        DeliveryFilterTab.completed => completedCount,
        DeliveryFilterTab.cancelled => cancelledCount,
      };

  int getTabCount(DeliveryFilterTab tab) => countForTab(tab);

  List<DeliveryEntity> get filteredDeliveries {
    final list = switch (_selectedTab) {
      DeliveryFilterTab.all => _sortDeliveriesForAllTab(_deliveries),
      DeliveryFilterTab.delayed => _deliveries.where((d) => d.isDelayed).toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt)),
      DeliveryFilterTab.pending =>
        _deliveries.where((d) => d.status == DeliveryStatus.pending && !d.isDelayed).toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt)),
      DeliveryFilterTab.inProgress =>
        _deliveries.where((d) => d.status == DeliveryStatus.inProgress && !d.isDelayed).toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt)),
      DeliveryFilterTab.completed => _deliveries.where((d) => d.status == DeliveryStatus.completed).toList()
        ..sort((a, b) => (b.deliveredAt ?? b.scheduledAt).compareTo(a.deliveredAt ?? a.scheduledAt)),
      DeliveryFilterTab.cancelled => _deliveries.where((d) => d.status == DeliveryStatus.cancelled).toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt)),
    };

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
    await _updateDeliveryStatusUseCase(deliveryId, status, deliveredAt: deliveredAt);
  }

  Future<void> rescheduleDelivery(
    DeliveryEntity delivery,
    DateTime newScheduledAt,
  ) async {
    final updated = delivery.copyWith(
      scheduledAt: newScheduledAt,
      status: delivery.status == DeliveryStatus.delayed ? DeliveryStatus.pending : delivery.status,
    );
    await _updateDeliveryUseCase(updated);
  }

  Future<void> updateDelivery(DeliveryEntity delivery) async {
    await _updateDeliveryUseCase(delivery);
  }

  Future<void> deleteDelivery(String deliveryId) async {
    await _deleteDeliveryUseCase(deliveryId);
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
    await _saveDeliveryUseCase(delivery);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
