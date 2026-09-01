import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/repositories/products_repository.dart';

class SaveProductUseCase {
  final ProductsRepository _repository;

  const SaveProductUseCase(this._repository);

  AsyncResult<bool> call(ProductEntity product) async {
    if (product.name.trim().isEmpty) {
      return Result.failure(
        const BusinessRuleFailure(
          message: 'O nome do produto é obrigatório.',
        ),
      );
    }
    if (product.barcode.isNotEmpty) {
      final barcodeResult = await _repository.checkBarcodeExists(product.barcode);
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
    final result = await _repository.save(product);
    return result.fold(
      onSuccess: (_) => const Result.success(true),
      onFailure: (error) => Result.failure(error),
    );
  }
}
