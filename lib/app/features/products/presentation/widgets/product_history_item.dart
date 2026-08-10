import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ProductHistoryItem extends StatelessWidget {
  final ProductHistoryEntity history;
  final bool isLast;

  const ProductHistoryItem({
    super.key,
    required this.history,
    this.isLast = false,
  });

  bool get _isPositive => history.action == ProductHistoryAction.add;

  String get _actionText {
    switch (history.action) {
      case ProductHistoryAction.add:
        return 'Entrada manual de estoque';
      case ProductHistoryAction.remove:
        return 'Saída manual de estoque';
      case ProductHistoryAction.sale:
        return 'Venda';
      case ProductHistoryAction.set:
        return 'Ajuste de estoque';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _isPositive ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.space12,
        right: AppSpacing.space12,
        bottom: AppSpacing.space8,
        top: AppSpacing.space8,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : BorderDirectional(
                bottom: BorderSide(color: context.colorScheme.outline, width: 1),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.space12),
            decoration: BoxDecoration(
              borderRadius: AppSpacing.borderRadius16,
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(
              _isPositive ? AppIcons.trendingUp : AppIcons.trendingDown,
              color: color,
              weight: 700,
            ),
          ),
          const Gap(AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${history.oldStock} ➝ ${history.newStock} unidade${history.newStock == 1 ? '' : 's'}',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 0.9,
                      ),
                    ),
                    const Gap(AppSpacing.space8),
                    Text(
                      '${_isPositive ? "+" : "-"}${history.quantity} un.',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: color,
                      ),
                    ),
                  ],
                ),
                Text(
                  '"$_actionText"',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (history.note.isNotEmpty) ...[
                  const Gap(AppSpacing.space4),
                  Text(
                    '"${history.note}"',
                    style: context.textTheme.labelLarge?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const Gap(AppSpacing.space4),
                Row(
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(history.date),
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    if (history.userName != null && history.userName!.isNotEmpty) ...[
                      Text(
                        ' • ',
                        style: context.textTheme.labelLarge?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        history.userName!,
                        style: context.textTheme.labelLarge?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
