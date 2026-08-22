import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class SaleCardFullHistorySheet extends StatelessWidget {
  final SaleEntity sale;

  const SaleCardFullHistorySheet({
    super.key,
    required this.sale,
  });

  static Future<void> show(BuildContext context, SaleEntity sale) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SaleCardFullHistorySheet(sale: sale),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reversedHistory = sale.editHistory.reversed.toList();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radius24)),
      ),
      child: Column(
        children: [
          const Gap(AppSpacing.space8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(AppSpacing.space8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Histórico de Edições - Venda ${sale.saleNumber}',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppIconButton(
                  icon: AppIcons.close,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.space16),
              itemCount: reversedHistory.length,
              itemBuilder: (_, index) {
                final entry = reversedHistory[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.space12),
                  padding: const EdgeInsets.all(AppSpacing.space12),
                  decoration: BoxDecoration(
                    color: context.colorScheme.outline.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSpacing.radius16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${entry.sequenceNumber} • ${entry.reason}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colorScheme.primary,
                            ),
                          ),
                          Text(
                            dateFormat.format(entry.timestamp),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Por: ${entry.userName}',
                        style: context.textTheme.bodySmall,
                      ),
                      if (entry.comment?.isNotEmpty == true) ...[
                        const Gap(2),
                        Text(
                          'Obs: ${entry.comment}',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (entry.addedItems.isNotEmpty) ...[
                        const Gap(4),
                        Text(
                          'Adicionados:',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        ...entry.addedItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.space8, top: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.add_circle_outline, size: 14, color: AppColors.success),
                                const Gap(4),
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.productName}',
                                    style: context.textTheme.bodySmall?.copyWith(color: AppColors.success),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (entry.removedItems.isNotEmpty) ...[
                        const Gap(4),
                        Text(
                          'Removidos:',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        ...entry.removedItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.space8, top: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.remove_circle_outline, size: 14, color: AppColors.error),
                                const Gap(4),
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.productName}',
                                    style: context.textTheme.bodySmall?.copyWith(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
