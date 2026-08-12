import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/cart_item.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/discount_type.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/save_sale_use_case.dart';

/// Saves a sale in progress (status [SaleStatus.inProgress]).
///
/// Responsibilities:
/// - validate cart is not empty and stock availability;
/// - build the [SaleEntity] with draft status;
/// - persist the sale via [SaveSaleUseCase].
class SaveDraftSaleUseCase {
  final SaveSaleUseCase _saveSaleUseCase;

  const SaveDraftSaleUseCase(this._saveSaleUseCase);

  Future<void> execute({
    required List<CartItem> items,
    required String saleNumber,
    required String? editingSaleId,
    required DiscountType discountType,
    required double discountValue,
    required double subtotal,
    required double total,
    required PaymentMethod paymentMethod,
    required double amountPaid,
    required double change,
    required String userId,
    required String userName,
    required List<ProductEntity> availableProducts,
    required DateTime createdAt,
  }) async {
    if (items.isEmpty) {
      throw Exception('O carrinho está vazio.');
    }

    final outOfStock = _getOutOfStockProducts(items, availableProducts);
    if (outOfStock.isNotEmpty) {
      final names = outOfStock.map((p) => '${p.name} (Estoque: ${p.stock})').join(', ');
      throw Exception('Estoque insuficiente para: $names');
    }

    final saleItems = items
        .map(
          (item) => SaleItemEntity(
            productId: item.product.id,
            productName: item.product.name,
            productImgUrl: item.product.imgUrl,
            unitPrice: item.product.price,
            quantity: item.quantity,
          ),
        )
        .toList();

    final sale = SaleEntity(
      id: editingSaleId ?? '',
      saleNumber: saleNumber,
      items: saleItems,
      subtotal: subtotal,
      discountType: discountType,
      discountValue: discountValue,
      total: total,
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
      change: change,
      customerId: '',
      customerName: '',
      userId: userId,
      userName: userName,
      status: SaleStatus.inProgress,
      createdAt: createdAt,
    );

    final isUpdate = editingSaleId != null && editingSaleId.isNotEmpty;
    await _saveSaleUseCase.execute(sale: sale, isUpdate: isUpdate);
  }

  List<ProductEntity> _getOutOfStockProducts(
    List<CartItem> items,
    List<ProductEntity> availableProducts,
  ) {
    final List<ProductEntity> invalid = [];
    for (final item in items) {
      final matched = availableProducts.firstWhere(
        (p) => p.id == item.product.id,
        orElse: () => item.product.copyWith(stock: 0),
      );
      if (item.quantity > matched.stock) {
        invalid.add(matched);
      }
    }
    return invalid;
  }
}
