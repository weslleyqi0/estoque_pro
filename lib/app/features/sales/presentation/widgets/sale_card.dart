import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sheets/digital_invoice_sheet.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sheets/edit_sale_bottom_sheet.dart';
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
    SaleStatus.edited => AppColors.warning,
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

  bool get _canEditSale {
    final currentUser = getIt<AuthViewModel>().currentUser;
    if (currentUser == null || !currentUser.isActive) return false;
    if (sale.status == SaleStatus.cancelled || sale.status == SaleStatus.inProgress) return false;
    if (currentUser.role == UserRole.owner || currentUser.role == UserRole.admin) return true;
    return currentUser.hasPermission(UserPermission.editSales);
  }

  bool get _canViewSalesHistory {
    final currentUser = getIt<AuthViewModel>().currentUser;
    if (currentUser == null || !currentUser.isActive) return false;
    if (currentUser.role == UserRole.owner || currentUser.role == UserRole.admin) return true;
    return currentUser.hasPermission(UserPermission.viewSalesHistory) ||
        currentUser.hasPermission(UserPermission.editSales);
  }

  bool get _canDeleteWithoutStock {
    final currentUser = getIt<AuthViewModel>().currentUser;
    if (currentUser == null || !currentUser.isActive) return false;
    if (!_canEditSale) return false;
    if (currentUser.role == UserRole.owner || currentUser.role == UserRole.admin) return true;
    return currentUser.hasPermission(UserPermission.deleteSales) ||
        currentUser.hasPermission(UserPermission.cancelCompletedSales);
  }

  void _deleteSaleWithoutStock(BuildContext context) async {
    if (!_canDeleteWithoutStock) {
      AppSnackbar.error(
        context,
        'Você não possui permissão para excluir vendas do histórico.',
      );
      return;
    }

    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Excluir Venda (Manter Estoque)',
      content:
          'Deseja realmente excluir a Venda ${sale.saleNumber} do histórico?\n\n'
          '⚠️ Atenção: Os produtos desta venda NÃO voltarão ao estoque. Esta ação é recomendada para limpeza de vendas antigas.',
      confirmLabel: 'Excluir sem alterar estoque',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await getIt<SalesViewModel>().deleteSale(sale.id);
        if (context.mounted) {
          AppToast.info(
            'Venda ${sale.saleNumber} excluída sem alterar o estoque.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.error(
            context,
            'Erro ao excluir venda: ${e.toString()}',
          );
        }
      }
    }
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
      margin: const EdgeInsets.only(bottom: AppSpacing.space12),
      color: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        side: BorderSide(
          color: isExpanded ? context.colorScheme.primary : context.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onToggleExpand,
        overlayColor: WidgetStateProperty.all(context.colorScheme.primary.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venda ${sale.saleNumber}',
                        style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        dateFormat.format(sale.createdAt),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTag(title: sale.status.label, color: statusColor),
                      if (sale.status != SaleStatus.inProgress) ...[
                        const Gap(AppSpacing.space4),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            Icons.receipt_long_rounded,
                            size: AppSpacing.icon20,
                            color: context.colorScheme.primary,
                          ),
                          tooltip: 'Comprovante de Venda',
                          onPressed: () => DigitalInvoiceSheet.show(context, sale),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const Gap(AppSpacing.space4),

              // Summary details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${sale.totalItems} ${sale.totalItems == 1 ? 'item' : 'itens'} • ${sale.paymentMethod.label}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyInputFormatter.formatCurrency(sale.total),
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.w900,
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
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              // Expanded Details
              if (isExpanded) ...[
                const Divider(height: AppSpacing.space16),
                Text(
                  'Produtos Vendidos',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(8),
                ...sale.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x  ${item.productName}',
                            style: context.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Gap(AppSpacing.space4),
                        Text(
                          CurrencyInputFormatter.formatCurrency(item.totalPrice),
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: AppSpacing.space24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal', style: context.textTheme.bodySmall),
                    Text(CurrencyInputFormatter.formatCurrency(sale.subtotal), style: context.textTheme.bodySmall),
                  ],
                ),
                if (sale.discountValue > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Vendedor', style: context.textTheme.bodySmall),
                    Text(
                      sale.userName,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // History Section
                if (sale.editHistory.isNotEmpty && _canViewSalesHistory) ...[
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
                          onPressed: () => _showAllHistoryModal(context, sale),
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

                // Action Buttons
                const Gap(AppSpacing.space12),
                Row(
                  children: [
                    if (sale.status == SaleStatus.inProgress) ...[
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
                    ] else ...[
                      Expanded(
                        child: SizedBox(
                          height: AppSpacing.space48,
                          child: AppButton.outlined(
                            onPressed: () => DigitalInvoiceSheet.show(context, sale),
                            icon: Icons.receipt_long_rounded,
                            child: Text(
                              'Comprovante',
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_canEditSale) ...[
                        const Gap(AppSpacing.space8),
                        SizedBox(
                          height: AppSpacing.space48,
                          child: AppButton.outlined(
                            onPressed: () => EditSaleBottomSheet.show(context, sale),
                            icon: Icons.edit,
                            child: Text(
                              'Editar',
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (_canDeleteWithoutStock) ...[
                        const Gap(AppSpacing.space8),
                        SizedBox(
                          height: AppSpacing.space48,
                          width: AppSpacing.space48,
                          child: IconButton.outlined(
                            onPressed: () => _deleteSaleWithoutStock(context),
                            icon: Icon(Icons.delete_outline_rounded, color: context.colorScheme.error),
                            style: IconButton.styleFrom(
                              side: BorderSide(color: context.colorScheme.error.withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radius12),
                              ),
                            ),
                            tooltip: 'Excluir Venda (Sem alterar estoque)',
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAllHistoryModal(BuildContext context, SaleEntity sale) {
    final reversedHistory = sale.editHistory.reversed.toList();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: ctx.colorScheme.surface,
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
                  color: ctx.colorScheme.outlineVariant,
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
                    style: ctx.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.close),
                    onPressed: () => Navigator.pop(ctx),
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
                      color: ctx.colorScheme.outline.withValues(alpha: 0.5),
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
                              style: ctx.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ctx.colorScheme.primary,
                              ),
                            ),
                            Text(
                              dateFormat.format(entry.timestamp),
                              style: ctx.textTheme.bodySmall?.copyWith(
                                color: ctx.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Por: ${entry.userName}',
                          style: ctx.textTheme.bodySmall,
                        ),
                        if (entry.comment?.isNotEmpty == true) ...[
                          const Gap(2),
                          Text(
                            'Obs: ${entry.comment}',
                            style: ctx.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        if (entry.addedItems.isNotEmpty) ...[
                          const Gap(4),
                          Text(
                            'Adicionados:',
                            style: ctx.textTheme.bodySmall?.copyWith(
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
                                      style: ctx.textTheme.bodySmall?.copyWith(color: AppColors.success),
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
                            style: ctx.textTheme.bodySmall?.copyWith(
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
                                      style: ctx.textTheme.bodySmall?.copyWith(color: AppColors.error),
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
      ),
    );
  }
}
