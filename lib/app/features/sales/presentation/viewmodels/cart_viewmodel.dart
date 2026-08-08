import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_item.dart';
import 'package:flutter/foundation.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

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
}
