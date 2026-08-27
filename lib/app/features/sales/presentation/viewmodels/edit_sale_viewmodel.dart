import 'package:estoque_pro/app/core/utils/list_extensions.dart';
import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/discount_type.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_reason.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/cancel_completed_sale_use_case.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/edit_sale_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:flutter/foundation.dart';

class EditSaleViewModel extends ChangeNotifier {
  final EditSaleUseCase _editSaleUseCase;
  final CancelCompletedSaleUseCase _cancelCompletedSaleUseCase;
  final ProductsRepository _productsRepository;

  EditSaleViewModel(
    this._editSaleUseCase,
    this._cancelCompletedSaleUseCase,
    this._productsRepository,
  );

  late SaleEntity _originalSale;
  SaleEntity get originalSale => _originalSale;

  List<ProductEntity> _products = [];
  List<ProductEntity> get products => List.unmodifiable(_products);

  final List<SaleItemEntity> _draftItems = [];
  List<SaleItemEntity> get draftItems => _draftItems.sortedByName((item) => item.productName);

  String? _selectedCustomerId;
  String? get selectedCustomerId => _selectedCustomerId;

  String? _selectedCustomerName;
  String? get selectedCustomerName => _selectedCustomerName;

  SaleEditReason _selectedReason = SaleEditReason.addition;
  SaleEditReason get selectedReason => _selectedReason;

  String _comment = '';
  String get comment => _comment;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void initWithSale(SaleEntity sale) {
    _originalSale = sale;
    _draftItems.clear();
    _draftItems.addAll(sale.items);
    _selectedCustomerId = sale.customerId;
    _selectedCustomerName = sale.customerName;
    _selectedReason = SaleEditReason.addition;
    _comment = '';
    _errorMessage = null;
    _isSaving = false;
    notifyListeners();
  }

  void setCustomer({String? id, String? name}) {
    _selectedCustomerId = id;
    _selectedCustomerName = name;
    notifyListeners();
  }

  Future<List<ProductEntity>> loadProducts() async {
    _products = await _productsRepository.getAll();
    notifyListeners();
    return _products;
  }

  void setReason(SaleEditReason reason) {
    _selectedReason = reason;
    notifyListeners();
  }

  void setComment(String comment) {
    _comment = comment;
    notifyListeners();
  }

  void addItem(ProductEntity product, int quantity) {
    final index = _draftItems.indexWhere((i) => i.productId == product.id);
    if (index >= 0) {
      final current = _draftItems[index];
      _draftItems[index] = current.copyWith(quantity: current.quantity + quantity);
    } else {
      _draftItems.add(
        SaleItemEntity(
          productId: product.id,
          productName: product.name,
          productImgUrl: product.imgUrl,
          unitPrice: product.price,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(SaleItemEntity item) {
    _draftItems.removeWhere((i) => i.productId == item.productId);
    notifyListeners();
  }

  void updateQuantity(SaleItemEntity item, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(item);
    } else {
      final index = _draftItems.indexWhere((i) => i.productId == item.productId);
      if (index >= 0) {
        _draftItems[index] = _draftItems[index].copyWith(quantity: newQuantity);
        notifyListeners();
      }
    }
  }

  void swapItem(SaleItemEntity oldItem, ProductEntity newProduct, int newQuantity) {
    final oldIndex = _draftItems.indexWhere((i) => i.productId == oldItem.productId);
    final existingIndex = _draftItems.indexWhere((i) => i.productId == newProduct.id);

    if (existingIndex >= 0 && existingIndex != oldIndex) {
      final existingItem = _draftItems[existingIndex];
      _draftItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + newQuantity,
      );
      if (oldIndex >= 0) {
        _draftItems.removeAt(oldIndex);
      }
    } else {
      final newItem = SaleItemEntity(
        productId: newProduct.id,
        productName: newProduct.name,
        productImgUrl: newProduct.imgUrl,
        unitPrice: newProduct.price,
        quantity: newQuantity,
      );
      if (oldIndex >= 0) {
        _draftItems[oldIndex] = newItem;
      } else {
        _draftItems.add(newItem);
      }
    }
    notifyListeners();
  }

  bool get hasChanges {
    if (_selectedCustomerId != _originalSale.customerId ||
        _selectedCustomerName != _originalSale.customerName) {
      return true;
    }
    if (_draftItems.length != _originalSale.items.length) return true;
    for (int i = 0; i < _draftItems.length; i++) {
      final orig = _originalSale.items.firstWhere(
        (item) => item.productId == _draftItems[i].productId,
        orElse: () => const SaleItemEntity(
          productId: '',
          productName: '',
          productImgUrl: '',
          unitPrice: 0,
          quantity: -1,
        ),
      );
      if (orig.quantity != _draftItems[i].quantity || orig.unitPrice != _draftItems[i].unitPrice) {
        return true;
      }
    }
    return false;
  }

  double get newSubtotal => _draftItems.fold(
    0.0,
    (sum, item) => sum + (item.unitPrice * item.quantity),
  );

  double get newTotal {
    if (_originalSale.discountValue > 0) {
      final calculatedDiscount = _originalSale.discountType == DiscountType.percent
          ? newSubtotal * (_originalSale.discountValue / 100)
          : _originalSale.discountValue;
      return (newSubtotal - calculatedDiscount).clamp(0.0, double.infinity);
    }
    return newSubtotal;
  }

  double get totalDifference => newTotal - _originalSale.total;

  Future<Result<SaleEntity>> saveEdit({required UserEntity currentUser}) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _editSaleUseCase.call(
      originalSale: _originalSale,
      updatedItems: _draftItems,
      reason: _selectedReason.label,
      comment: _comment.isNotEmpty ? _comment : null,
      customerId: _selectedCustomerId,
      customerName: _selectedCustomerName,
      currentUser: currentUser,
    );

    _isSaving = false;
    if (result.isFailure) {
      _errorMessage = result.error.toString();
    }
    notifyListeners();
    return result;
  }

  Future<Result<SaleEntity>> cancelSale({
    required UserEntity currentUser,
    String? reason,
    String? comment,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _cancelCompletedSaleUseCase.call(
      sale: _originalSale,
      reason: reason ?? 'Cancelamento',
      comment: comment ?? (_comment.isNotEmpty ? _comment : null),
      currentUser: currentUser,
    );

    _isSaving = false;
    if (result.isFailure) {
      _errorMessage = result.error.toString();
    }
    notifyListeners();
    return result;
  }
}
