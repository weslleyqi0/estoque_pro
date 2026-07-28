import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SuppliersItem extends StatelessWidget {
  final SupplierEntity supplier;

  const SuppliersItem({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    final color = !supplier.isActive ? context.colorScheme.onSurface.withValues(alpha: 0.4) : null;
    return Padding(
      padding: const .symmetric(vertical: AppSpacing.space4),
      child: InkWell(
        onTap: () => context.push(AppRoutes.supplierForm, extra: supplier),
        borderRadius: AppSpacing.borderRadius12,
        //overlayColor: WidgetStateProperty.all(color.withValues(alpha: 0.1)),
        child: Container(
          padding: const .all(AppSpacing.space12),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadius12,
            color: context.colorScheme.outline.withValues(alpha: 0.4),
            border: Border.all(
              color: context.colorScheme.outline,
              width: 1,
            ),
          ),
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
                  Symbols.local_shipping_rounded,
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
                        Text(
                          supplier.name,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium?.copyWith(color: color),
                        ),
                        Text(
                          !supplier.isActive ? 'Inativo' : '',
                          style: context.textTheme.labelLarge,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Symbols.home_work_rounded,
                          color: color,
                          size: AppSpacing.icon16,
                          weight: 600,
                        ),
                        const Gap(AppSpacing.space4),
                        Text(
                          supplier.cnpj ?? '',
                          style: context.textTheme.labelLarge?.copyWith(color: color),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Symbols.phone,
                              color: color,
                              size: AppSpacing.icon16,
                              weight: 600,
                            ),
                            const Gap(AppSpacing.space4),
                            Text(
                              supplier.phone ?? '',
                              style: context.textTheme.labelLarge?.copyWith(color: color),
                            ),
                          ],
                        ),
                        AppTag(
                          title: '5 produtos',
                          icon: Symbols.package_2_rounded,
                          color: context.colorScheme.primary,
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
