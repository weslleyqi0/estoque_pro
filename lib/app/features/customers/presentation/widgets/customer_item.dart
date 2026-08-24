import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomerItem extends StatelessWidget {
  final CustomerEntity customer;
  final VoidCallback? onTap;
  final bool canEdit;

  const CustomerItem({
    super.key,
    required this.customer,
    this.onTap,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = !customer.isActive ? context.colorScheme.onSurface.withValues(alpha: 0.4) : null;

    return Card(
      color: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadius16,
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap:
            onTap ??
            () => CustomerDetailBottomSheet.show(
              context: context,
              customer: customer,
              canEdit: canEdit,
            ),
        borderRadius: AppSpacing.borderRadius16,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.space8),
                decoration: BoxDecoration(
                  borderRadius: AppSpacing.borderRadius12,
                  color: context.colorScheme.outline,
                ),
                child: Icon(
                  AppIcons.person,
                  color: color,
                  size: AppSpacing.icon32,
                  weight: 600,
                ),
              ),
              const Gap(AppSpacing.space8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!customer.isActive)
                          Text(
                            'Inativo',
                            style: context.textTheme.labelLarge?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                      ],
                    ),

                    Row(
                      children: [
                        Icon(
                          AppIcons.homeWork,
                          color: color,
                          size: AppSpacing.icon16,
                          weight: 600,
                        ),
                        const Gap(AppSpacing.space4),
                        Expanded(
                          child: Text(
                            customer.address ?? 'Endereço não informado',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.labelLarge?.copyWith(color: color),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
