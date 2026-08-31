import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/cart_item.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/discount_type.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/usecases/save_sale_use_case.dart';

/// Finalizes a completed sale (status [SaleStatus.completed]).
///
/// Responsibilities:
/// - validate cart is not empty and stock availability;
/// - validate customer requirements for fiado / delivery;
/// - build the [SaleEntity] from the cart;
/// - persist the sale via [SaveSaleUseCase];
/// - optionally create and persist a [DeliveryEntity] if delivery is requested.
class FinalizeSaleUseCase {
  final SaveSaleUseCase _saveSaleUseCase;
  final DeliveriesRepository _deliveriesRepository;

  const FinalizeSaleUseCase(
    this._saveSaleUseCase,
    this._deliveriesRepository,
  );

  AsyncResult<SaleEntity> execute({
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
    String? customerId,
    String? customerName,
    String? customerPhone,
    required String userId,
    required String userName,
    required List<ProductEntity> availableProducts,
    DateTime? createdAt,
    bool isDelivery = false,
    DateTime? deliveryScheduledAt,
    String? deliveryAddress,
    String? deliveryNotes,
  }) async {
    if (items.isEmpty) {
      return Result.failure(
        const BusinessRuleFailure(message: 'O carrinho está vazio.'),
      );
    }

    if (paymentMethod == PaymentMethod.fiado &&
        (customerName == null || customerName.trim().isEmpty)) {
      return Result.failure(
        const BusinessRuleFailure(
          message: 'Para vendas no fiado, é obrigatório selecionar um cliente.',
        ),
      );
    }

    if (isDelivery) {
      if (customerName == null || customerName.trim().isEmpty) {
        return Result.failure(
          const BusinessRuleFailure(
            message: 'Para entregas, é obrigatório selecionar um cliente.',
          ),
        );
      }
      if (deliveryAddress == null || deliveryAddress.trim().isEmpty) {
        return Result.failure(
          const BusinessRuleFailure(
            message: 'Para entregas, é obrigatório informar o endereço de entrega.',
          ),
        );
      }
    }

    final outOfStock = _getOutOfStockProducts(items, availableProducts);
    if (outOfStock.isNotEmpty) {
      final names =
          outOfStock.map((p) => '${p.name} (Estoque: ${p.stock})').join(', ');
      return Result.failure(
        BusinessRuleFailure(message: 'Estoque insuficiente para: $names'),
      );
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
      amountPaid: paymentMethod == PaymentMethod.dinheiro ? amountPaid : null,
      change: paymentMethod == PaymentMethod.dinheiro ? change : null,
      customerId: customerId,
      customerName: customerName,
      userId: userId,
      userName: userName,
      status: SaleStatus.completed,
      createdAt: createdAt ?? DateTime.now(),
    );

    final isUpdate = editingSaleId != null && editingSaleId.isNotEmpty;
    final saveResult = await _saveSaleUseCase.execute(sale: sale, isUpdate: isUpdate);
    if (saveResult.isFailure) {
      return saveResult;
    }

    if (isDelivery) {
      final delivery = DeliveryEntity(
        id: '',
        saleId: sale.id,
        saleNumber: saleNumber,
        customerId: customerId ?? '',
        customerName: customerName ?? '',
        customerPhone: customerPhone,
        customerAddress: deliveryAddress ?? '',
        items: saleItems,
        subtotal: subtotal,
        totalAmount: total,
        paymentMethod: paymentMethod,
        status: DeliveryStatus.pending,
        scheduledAt: deliveryScheduledAt ?? DateTime.now(),
        observations: deliveryNotes ?? '',
        userId: userId,
        userName: userName,
        createdAt: DateTime.now(),
      );

      try {
        await _deliveriesRepository.save(delivery);
      } on AppFailure catch (e) {
        return Result.failure(e);
      } catch (e, stackTrace) {
        return Result.failure(e, stackTrace);
      }
    }

    return Result.success(sale);
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
