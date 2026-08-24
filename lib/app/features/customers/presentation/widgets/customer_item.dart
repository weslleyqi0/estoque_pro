import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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
        onTap: onTap ?? (canEdit ? () => context.push(AppRoutes.customerForm, extra: customer) : null),
        borderRadius: AppSpacing.borderRadius16,
        child: Padding(
          padding: const .all(AppSpacing.space12),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            crossAxisAlignment: .start,
            children: [
              Container(
                padding: .all(AppSpacing.space8),
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
              Flexible(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      crossAxisAlignment: .start,
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
                            customer.address != null ? '${customer.address}' : '',
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
