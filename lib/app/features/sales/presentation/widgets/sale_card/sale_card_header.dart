import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/widgets/delivery_detail_bottom_sheet.dart';
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
  final DeliveryEntity? delivery;
  final AuthViewModel authViewModel;

  const SaleCardHeader({
    super.key,
    required this.sale,
    this.delivery,
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

  Color _getDeliveryStatusColor(DeliveryStatus status) => switch (status) {
    DeliveryStatus.pending => AppColors.warning,
    DeliveryStatus.inProgress => Colors.blue,
    DeliveryStatus.completed => Colors.green,
    DeliveryStatus.delayed => AppColors.error,
    DeliveryStatus.cancelled => Colors.grey,
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
                size: AppIconButtonSize.large,
                icon: AppIcons.edit,
                iconColor: context.colorScheme.primary,
                visualDensity: VisualDensity.compact,
                tooltip: 'Editar Venda',
                onPressed: () => EditSaleBottomSheet.show(
                  context,
                  sale,
                  authViewModel: authViewModel,
                ),
              ),
            ],
            if (delivery != null) ...[
              AppIconButton(
                size: AppIconButtonSize.large,
                icon: AppIcons.truck,
                iconColor: _getDeliveryStatusColor(delivery!.effectiveStatus),
                visualDensity: VisualDensity.compact,
                tooltip: 'Detalhes da Entrega (${delivery!.effectiveStatus.label})',
                onPressed: () => DeliveryDetailBottomSheet.show(
                  context: context,
                  delivery: delivery!,
                  viewModel: getIt<DeliveriesViewModel>(),
                ),
              ),
            ],
            if (sale.status != SaleStatus.inProgress) ...[
              AppIconButton(
                size: AppIconButtonSize.large,
                icon: AppIcons.receipt,
                iconColor: context.colorScheme.primary,
                visualDensity: VisualDensity.compact,
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
