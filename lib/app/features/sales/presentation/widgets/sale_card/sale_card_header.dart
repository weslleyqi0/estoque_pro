import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sheets/digital_invoice_sheet.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sheets/edit_sale_bottom_sheet.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class SaleCardHeader extends StatelessWidget {
  final SaleEntity sale;
  final AuthViewModel authViewModel;

  const SaleCardHeader({
    super.key,
    required this.sale,
    required this.authViewModel,
  });

  bool get _canEditSale {
    final currentUser = authViewModel.currentUser;
    if (currentUser == null || !currentUser.isActive) return false;
    if (sale.status == SaleStatus.cancelled || sale.status == SaleStatus.inProgress) return false;
    if (currentUser.role == UserRole.owner || currentUser.role == UserRole.admin) return true;
    return currentUser.hasPermission(UserPermission.editSales);
  }

  Color _getStatusColor(SaleStatus status) => switch (status) {
    SaleStatus.inProgress => AppColors.warning,
    SaleStatus.completed => AppColors.success,
    SaleStatus.cancelled => AppColors.error,
    SaleStatus.returned => AppColors.warning,
    SaleStatus.exchanged => AppColors.warning,
    SaleStatus.corrected => AppColors.warning,
    SaleStatus.edited => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final statusColor = _getStatusColor(sale.status);

    return Row(
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
        Row(
          mainAxisSize: .min,
          children: [
            AppTag(title: sale.status.label, color: statusColor),
            if (_canEditSale) ...[
              const Gap(AppSpacing.space4),
              AppIconButton(
                size: .medium,
                icon: AppIcons.edit,
                iconColor: context.colorScheme.primary,
                tooltip: 'Editar Venda',
                onPressed: () => EditSaleBottomSheet.show(
                  context,
                  sale,
                  authViewModel: authViewModel,
                ),
              ),
            ],
            if (sale.status != SaleStatus.inProgress) ...[
              AppIconButton(
                size: AppIconButtonSize.medium,
                icon: Icons.receipt_long_rounded,
                iconColor: context.colorScheme.primary,
                tooltip: 'Comprovante de Venda',
                onPressed: () => DigitalInvoiceSheet.show(context, sale),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
