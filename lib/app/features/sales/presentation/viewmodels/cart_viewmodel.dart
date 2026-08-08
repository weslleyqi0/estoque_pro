import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/cart_item.dart';
import 'package:flutter/foundation.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  String _saleNumber = '';
  String get saleNumber => _saleNumber;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get total => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  CartViewModel() {
    _initSaleNumber();
  }

  void _initSaleNumber() {
    final now = DateTime.now();
    _saleNumber = '#${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  int getQuantityInCart(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    return index >= 0 ? _items[index].quantity : 0;
  }

  bool addProduct(ProductEntity product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final current = _items[index];
      if (current.quantity >= product.stock) return false;
      _items[index] = current.copyWith(quantity: current.quantity + 1);
    } else {
      if (product.stock <= 0) return false;
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
    return true;
  }

  bool increaseQty(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final current = _items[index];
      if (current.quantity >= current.product.stock) return false;
      _items[index] = current.copyWith(quantity: current.quantity + 1);
      notifyListeners();
      return true;
    }
    return false;
  }

  void decreaseQty(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final current = _items[index];
      if (current.quantity > 1) {
        _items[index] = current.copyWith(quantity: current.quantity - 1);
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeProduct(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }
}
