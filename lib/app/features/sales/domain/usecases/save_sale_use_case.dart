import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';

/// Persists a sale entity, handling stock validation for completed sales.
///
/// Responsibilities:
/// - validate sale has items;
/// - for completed sales (not inProgress), verify stock availability;
/// - delegate to repository for save or update.
class SaveSaleUseCase {
  final SalesRepository _salesRepository;
  final ProductsRepository _productsRepository;

  const SaveSaleUseCase(
    this._salesRepository,
    this._productsRepository,
  );

  AsyncResult<SaleEntity> call({
    required SaleEntity sale,
    bool isUpdate = false,
  }) async {
    if (sale.items.isEmpty) {
      return Result.failure(
        const BusinessRuleFailure(message: 'A venda não possui itens.'),
      );
    }

    final Map<String, int> productStocks = {};

    // Se for uma venda concluída, busca os estoques atuais e valida disponibilidade
    if (sale.status != SaleStatus.inProgress) {
      final allProductsResult = await _productsRepository.getAll();
      final allProducts = allProductsResult.value ?? [];
      final productsMap = {for (var p in allProducts) p.id: p};

      for (final item in sale.items) {
        final product = productsMap[item.productId];
        if (product != null && product.stock < item.quantity) {
          return Result.failure(
            BusinessRuleFailure(
              message:
                  'Estoque insuficiente para o produto "${product.name}". Estoque disponível: ${product.stock}, Solicitado: ${item.quantity}.',
            ),
          );
        }
        productStocks[item.productId] = product?.stock ?? 0;
      }
    }

    final result = isUpdate
        ? await _salesRepository.updateSale(sale, productStocks: productStocks)
        : await _salesRepository.save(sale, productStocks: productStocks);
    return result.fold(
      onSuccess: (_) => Result.success(sale),
      onFailure: (error) => Result.failure(error),
    );
  }
}
