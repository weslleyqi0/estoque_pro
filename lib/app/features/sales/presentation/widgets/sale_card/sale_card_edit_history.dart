import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_card/sale_card_full_history_sheet.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class SaleCardEditHistory extends StatelessWidget {
  final SaleEntity sale;
  final AuthViewModel authViewModel;

  const SaleCardEditHistory({
    super.key,
    required this.sale,
    required this.authViewModel,
  });

  bool get _canViewSalesHistory {
    final currentUser = authViewModel.currentUser;
    if (currentUser == null || !currentUser.isActive) return false;
    if (currentUser.role == UserRole.owner || currentUser.role == UserRole.admin) return true;
    return currentUser.hasPermission(UserPermission.viewSalesHistory);
  }

  @override
  Widget build(BuildContext context) {
    if (sale.editHistory.isEmpty || !_canViewSalesHistory) return const SizedBox.shrink();

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: AppSpacing.space24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Histórico de Edições (${sale.editHistory.length})',
              style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (sale.editHistory.length > 3)
              TextButton(
                onPressed: () => SaleCardFullHistorySheet.show(context, sale),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Ver todas',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const Gap(AppSpacing.space8),
        ...sale.editHistory.reversed
            .take(3)
            .map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.space8),
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
              ),
            ),
      ],
    );
  }
}
