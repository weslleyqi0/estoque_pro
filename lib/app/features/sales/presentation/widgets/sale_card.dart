import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SaleCard extends StatelessWidget {
  final SaleEntity sale;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const SaleCard({
    super.key,
    required this.sale,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  Color _getStatusColor(SaleStatus status) => switch (status) {
    SaleStatus.inProgress => AppColors.warning,
    SaleStatus.completed => AppColors.success,
    SaleStatus.cancelled => AppColors.error,
    SaleStatus.returned => AppColors.warning,
    SaleStatus.exchanged => AppColors.warning,
    SaleStatus.corrected => AppColors.warning,
  };

  bool get _canCancelSale {
    final currentUser = getIt<AuthViewModel>().currentUser;
    if (currentUser == null || !currentUser.isActive) return false;

    if (currentUser.role == UserRole.owner || currentUser.role == UserRole.admin) {
      return true;
    }

    if (sale.userId == currentUser.uid) {
      return true;
    }

    return currentUser.hasPermission(UserPermission.deleteSales);
  }

  void _cancelSale(BuildContext context) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Cancelar Venda',
      content: 'Deseja realmente cancelar e excluir a Venda ${sale.saleNumber} em andamento?',
      confirmLabel: 'Sim, Cancelar',
      cancelLabel: 'Voltar',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await getIt<SalesViewModel>().deleteSale(sale.id);
        if (context.mounted) {
          AppSnackbar.success(context, 'Venda cancelada com sucesso!');
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.error(
            context,
            'Erro ao cancelar venda. Talvez você não tenha permissão para realizar essa ação.',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final statusColor = _getStatusColor(sale.status);

    return Card(
      margin: const .only(bottom: AppSpacing.space12),
      shape: RoundedRectangleBorder(
        borderRadius: .circular(AppSpacing.radius16),
        side: BorderSide(
          color: isExpanded ? context.colorScheme.primary : context.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onToggleExpand,
        overlayColor: .all(context.colorScheme.primary.withValues(alpha: 0.1)),
        borderRadius: .circular(AppSpacing.radius16),
        child: Padding(
          padding: const .all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                crossAxisAlignment: .start,
                children: [
                  Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'Venda ${sale.saleNumber}',
                        style: context.textTheme.titleMedium?.copyWith(fontWeight: .bold),
                      ),
                      Text(
                        dateFormat.format(sale.createdAt),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  AppTag(title: sale.status.label, color: statusColor),
                ],
              ),
              const Gap(AppSpacing.space4),

              // Summary details
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    '${sale.totalItems} ${sale.totalItems == 1 ? 'item' : 'itens'} • ${sale.paymentMethod.label}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    mainAxisSize: .min,
                    children: [
                      Text(
                        CurrencyInputFormatter.formatCurrency(sale.total),
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: .w900,
                        ),
                      ),
                      const Gap(AppSpacing.space4),
                      Icon(
                        isExpanded ? AppIcons.arrowUp : AppIcons.arrowDown,
                        color: context.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),

              if (sale.customerName?.isNotEmpty == true) ...[
                const Gap(4),
                Text(
                  'Cliente: ${sale.customerName}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.outline,
                    fontStyle: .italic,
                  ),
                ),
              ],

              // Expanded Details
              if (isExpanded) ...[
                const Divider(height: AppSpacing.space16),
                Text(
                  'Produtos Vendidos',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: .bold,
                  ),
                ),
                const Gap(8),
                ...sale.items.map(
                  (item) => Padding(
                    padding: const .symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x  ${item.productName}',
                            style: context.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: .ellipsis,
                          ),
                        ),
                        const Gap(AppSpacing.space4),
                        Text(
                          CurrencyInputFormatter.formatCurrency(item.totalPrice),
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: .w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: AppSpacing.space24),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text('Subtotal', style: context.textTheme.bodySmall),
                    Text(CurrencyInputFormatter.formatCurrency(sale.subtotal), style: context.textTheme.bodySmall),
                  ],
                ),
                if (sale.discountValue > 0)
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text('Desconto', style: context.textTheme.bodySmall?.copyWith(color: AppColors.error)),
                      Text(
                        '- ${CurrencyInputFormatter.formatCurrency(sale.discountValue)}',
                        style: context.textTheme.bodySmall?.copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                const Gap(AppSpacing.space4),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text('Vendedor', style: context.textTheme.bodySmall),
                    Text(
                      sale.userName,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: .bold,
                      ),
                    ),
                  ],
                ),
                if (sale.status == SaleStatus.inProgress) ...[
                  const Gap(AppSpacing.space12),
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      if (_canCancelSale) ...[
                        Expanded(
                          child: SizedBox(
                            height: AppSpacing.space48,
                            child: AppButton.outlined(
                              onPressed: () => _cancelSale(context),
                              icon: AppIcons.close,
                              borderColor: context.colorScheme.error,
                              backgroundColor: context.colorScheme.error.withValues(alpha: 0.2),
                              label: 'Cancelar',
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.space8),
                      ],
                      Expanded(
                        child: SizedBox(
                          height: AppSpacing.space48,
                          child: AppButton(
                            onPressed: () => context.push(AppRoutes.newSale, extra: sale),
                            icon: AppIcons.play,
                            label: 'Continuar',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
