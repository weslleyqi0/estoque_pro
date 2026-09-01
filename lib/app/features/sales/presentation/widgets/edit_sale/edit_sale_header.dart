import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_status.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EditSaleHeader extends StatelessWidget {
  final SaleEntity sale;
  final VoidCallback? onClose;

  const EditSaleHeader({
    super.key,
    required this.sale,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isEdited = sale.status == SaleStatus.edited;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar Venda ${sale.saleNumber}',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(4),
              AppTag(
                title: isEdited ? 'Editada' : sale.status.label,
                color: isEdited ? AppColors.warning : AppColors.success,
              ),
            ],
          ),
          CloseButton(
            onPressed: onClose ?? () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
