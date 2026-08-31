import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/discount_type.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_history_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';

class EditSaleUseCase {
  final SalesRepository _salesRepository;
  final ProductsRepository _productsRepository;

  const EditSaleUseCase(
    this._salesRepository,
    this._productsRepository,
  );

  AsyncResult<SaleEntity> call({
    required SaleEntity originalSale,
    required List<SaleItemEntity> updatedItems,
    required String reason,
    String? comment,
    String? customerId,
    String? customerName,
    required UserEntity currentUser,
  }) async {
    if (!currentUser.hasPermission(UserPermission.editSales)) {
      return Result.failure(
        const PermissionFailure(
          message: 'Usuário não possui permissão para editar vendas.',
        ),
      );
    }

    if (updatedItems.isEmpty) {
      return Result.failure(
        const BusinessRuleFailure(
          message: 'A venda deve possuir pelo menos um item.',
        ),
      );
    }

    final Map<String, int> originalQuantities = {
      for (var item in originalSale.items) item.productId: item.quantity,
    };

    final Map<String, int> updatedQuantities = {
      for (var item in updatedItems) item.productId: item.quantity,
    };

    final Set<String> allProductIds = {
      ...originalQuantities.keys,
      ...updatedQuantities.keys,
    };

    final List<SaleItemEntity> addedItems = [];
    final List<SaleItemEntity> removedItems = [];
    final Map<String, int> stockDeltas = {};

    for (final productId in allProductIds) {
      if (productId.trim().isEmpty) continue;
      final origQty = originalQuantities[productId] ?? 0;
      final newQty = updatedQuantities[productId] ?? 0;
      final delta = newQty - origQty;

      if (delta != 0) {
        stockDeltas[productId] = delta;

        if (delta > 0) {
          final item = updatedItems.firstWhere((i) => i.productId == productId);
          addedItems.add(item.copyWith(quantity: delta));
        } else {
          final item = originalSale.items.firstWhere((i) => i.productId == productId);
          removedItems.add(item.copyWith(quantity: delta.abs()));
        }
      }
    }

    final allProducts = await _productsRepository.getAll();
    final productsMap = {for (var p in allProducts) p.id: p};

    for (final entry in stockDeltas.entries) {
      final productId = entry.key;
      final delta = entry.value;

      if (delta > 0) {
        final product = productsMap[productId];
        final availableStock = product?.stock ?? 0;
        if (availableStock < delta) {
          final productName = product?.name ?? productId;
          return Result.failure(
            BusinessRuleFailure(
              message:
                  'Estoque insuficiente para o produto "$productName". Disponível: $availableStock, Solicitado: $delta.',
            ),
          );
        }
      }
    }

    return Result.guard(() async {
      final newSubtotal = updatedItems.fold<double>(
        0.0,
        (sum, item) => sum + (item.unitPrice * item.quantity),
      );

      double newTotal = newSubtotal;
      if (originalSale.discountValue > 0) {
        final calculatedDiscount = originalSale.discountType == DiscountType.percent
            ? newSubtotal * (originalSale.discountValue / 100)
            : originalSale.discountValue;
        newTotal = (newSubtotal - calculatedDiscount).clamp(0.0, double.infinity);
      }

      final hasItemChanges = addedItems.isNotEmpty || removedItems.isNotEmpty;

      if (!hasItemChanges) {
        // Se apenas o cliente ou dados cadastrais mudaram, não adiciona histórico de edição
        final updatedSale = originalSale.copyWith(
          customerId: customerId ?? originalSale.customerId,
          customerName: customerName ?? originalSale.customerName,
          updatedAt: DateTime.now(),
        );

        await _salesRepository.updateSale(updatedSale);
        return updatedSale;
      }

      final nextSequence = originalSale.editHistory.length + 1;
      final newHistoryEntry = SaleEditHistoryEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sequenceNumber: nextSequence,
        userId: currentUser.uid,
        userName: currentUser.name,
        timestamp: DateTime.now(),
        reason: reason,
        addedItems: addedItems,
        removedItems: removedItems,
        comment: comment,
      );

      final updatedHistory = [
        ...originalSale.editHistory,
        newHistoryEntry,
      ];

      final updatedSale = originalSale.copyWith(
        items: updatedItems,
        subtotal: newSubtotal,
        total: newTotal,
        status: SaleStatus.edited,
        customerId: customerId ?? originalSale.customerId,
        customerName: customerName ?? originalSale.customerName,
        editHistory: updatedHistory,
        updatedAt: DateTime.now(),
      );

      await _salesRepository.updateSaleWithStockAndHistory(
        sale: updatedSale,
        stockDeltas: stockDeltas,
        editHistoryEntry: newHistoryEntry,
        currentProductStocks: {for (var p in allProducts) p.id: p.stock},
      );

      return updatedSale;
    });
  }
}
