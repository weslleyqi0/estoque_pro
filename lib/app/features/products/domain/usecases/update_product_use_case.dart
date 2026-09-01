import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';

class UpdateProductUseCase {
  final ProductsRepository _repository;

  const UpdateProductUseCase(this._repository);

  AsyncResult<bool> call(ProductEntity product) async {
    if (product.id.trim().isEmpty) {
      return Result.failure(
        const BusinessRuleFailure(
          message: 'ID do produto é obrigatório para atualização.',
        ),
      );
    }
    if (product.name.trim().isEmpty) {
      return Result.failure(
        const BusinessRuleFailure(
          message: 'O nome do produto é obrigatório.',
        ),
      );
    }
    if (product.barcode.isNotEmpty) {
      final barcodeResult = await _repository.checkBarcodeExists(
        product.barcode,
        ignoreId: product.id,
      );
      if (barcodeResult.isFailure) {
        return Result.failure(barcodeResult.error!);
      }
      if (barcodeResult.value == true) {
        return Result.failure(
          const BusinessRuleFailure(
            message: 'Já existe um produto cadastrado com este código de barras.',
          ),
        );
      }
    }
    final result = await _repository.update(product);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
