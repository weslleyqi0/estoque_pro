import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_history_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/domain/repositories/sales_repository.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';

class CancelCompletedSaleUseCase {
  final SalesRepository _salesRepository;

  const CancelCompletedSaleUseCase(this._salesRepository);

  Future<Result<SaleEntity>> call({
    required SaleEntity sale,
    String? reason,
    String? comment,
    required UserEntity currentUser,
  }) async {
    if (!currentUser.hasPermission(UserPermission.cancelCompletedSales)) {
      return Result.failure(
        const PermissionFailure(
          message: 'Usuário não possui permissão para cancelar vendas concluídas.',
        ),
      );
    }

    if (sale.status == SaleStatus.cancelled) {
      return Result.failure(
        const BusinessRuleFailure(
          message: 'Esta venda já está cancelada.',
        ),
      );
    }

    final Map<String, int> stockDeltas = {
      for (final item in sale.items) item.productId: -item.quantity,
    };

    final nextSequence = sale.editHistory.length + 1;
    final cancelHistoryEntry = SaleEditHistoryEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sequenceNumber: nextSequence,
      userId: currentUser.uid,
      userName: currentUser.name,
      timestamp: DateTime.now(),
      reason: reason ?? 'Cancelamento',
      addedItems: const [],
      removedItems: sale.items,
      comment: comment,
    );

    final updatedHistory = [
      ...sale.editHistory,
      cancelHistoryEntry,
    ];

    final cancelledSale = sale.copyWith(
      status: SaleStatus.cancelled,
      editHistory: updatedHistory,
      updatedAt: DateTime.now(),
    );

    final updateResult = await _salesRepository.updateSaleWithStockAndHistory(
      sale: cancelledSale,
      stockDeltas: stockDeltas,
      editHistoryEntry: cancelHistoryEntry,
    );

    return updateResult.fold(
      onSuccess: (_) => Result.success(cancelledSale),
      onFailure: (error) => Result.failure(error),
    );
  }
}
