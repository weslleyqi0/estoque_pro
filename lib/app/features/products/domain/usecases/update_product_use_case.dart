import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';

class UpdateProductUseCase {
  final ProductsRepository _repository;

  const UpdateProductUseCase(this._repository);

  AsyncResult<bool> call(ProductEntity product) async {
    return Result.guard(() async {
      if (product.id.trim().isEmpty) {
        throw const BusinessRuleFailure(
          message: 'ID do produto é obrigatório para atualização.',
        );
      }
      if (product.name.trim().isEmpty) {
        throw const BusinessRuleFailure(
          message: 'O nome do produto é obrigatório.',
        );
      }
      if (product.barcode.isNotEmpty) {
        final barcodeExists = await _repository.checkBarcodeExists(
          product.barcode,
          ignoreId: product.id,
        );
        if (barcodeExists) {
          throw const BusinessRuleFailure(
            message: 'Já existe um produto cadastrado com este código de barras.',
          );
        }
      }
      await _repository.update(product);
      return true;
    });
  }
}
