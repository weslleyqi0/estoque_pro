import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
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

class SaleCardActions extends StatelessWidget {
  final SaleEntity sale;
  final AuthViewModel authViewModel;
  final SalesViewModel salesViewModel;

  const SaleCardActions({
    super.key,
    required this.sale,
    required this.authViewModel,
    required this.salesViewModel,
  });

  bool get _canCancelSale {
    final currentUser = authViewModel.currentUser;
    if (currentUser == null || !currentUser.isActive) return false;
    if (currentUser.role == UserRole.owner || currentUser.role == UserRole.admin) return true;
    if (sale.userId == currentUser.uid) return true;
    return currentUser.hasPermission(UserPermission.deleteSales);
  }

  bool get _canEditSale {
    final currentUser = authViewModel.currentUser;
    if (currentUser == null || !currentUser.isActive) return false;
    if (sale.status == SaleStatus.cancelled || sale.status == SaleStatus.inProgress) return false;
    if (currentUser.role == UserRole.owner || currentUser.role == UserRole.admin) return true;
    return currentUser.hasPermission(UserPermission.editSales);
  }

  bool get _canDeleteWithoutStock {
    final currentUser = authViewModel.currentUser;
    if (currentUser == null || !currentUser.isActive) return false;
    if (sale.status == SaleStatus.cancelled || sale.status == SaleStatus.inProgress) return false;
    return currentUser.hasPermission(UserPermission.cancelCompletedSales);
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
        await salesViewModel.deleteSale(sale.id);
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
        await salesViewModel.deleteSale(sale.id);
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
    return Column(
      children: [
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
                    onPressed: () => EditSaleBottomSheet.show(
                      context,
                      sale,
                      authViewModel: authViewModel,
                    ),
                    icon: AppIcons.edit,
                    label: 'Editar',
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
    );
  }
}
