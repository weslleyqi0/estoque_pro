import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/core/utils/cnpj_input_formatter.dart';
import 'package:estoque_pro/app/core/utils/phone_input_formatter.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class SuppliersItem extends StatelessWidget {
  final SupplierEntity supplier;
  final int productCount;
  final VoidCallback? onTap;
  final bool showProductsTag;

  const SuppliersItem({
    super.key,
    required this.supplier,
    this.productCount = 0,
    this.onTap,
    this.showProductsTag = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = !supplier.isActive ? context.colorScheme.onSurface.withValues(alpha: 0.4) : null;
    final countText = productCount == 1 ? '1 produto' : '$productCount produtos';
    return Card(
      color: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadius16,
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap ?? () => context.push(AppRoutes.supplierForm, extra: supplier),
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
                  AppIcons.localShipping,
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
                          AppIcons.homeWork,
                          color: color,
                          size: AppSpacing.icon16,
                          weight: 600,
                        ),
                        const Gap(AppSpacing.space4),
                        Text(
                          supplier.cnpj == null || supplier.cnpj!.isEmpty
                              ? 'Não informado'
                              : CnpjInputFormatter.formatString(supplier.cnpj!),
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
                              AppIcons.phone,
                              color: color,
                              size: AppSpacing.icon16,
                              weight: 600,
                            ),
                            const Gap(AppSpacing.space4),
                            Text(
                              supplier.phone == null || supplier.phone!.isEmpty
                                  ? 'Não informado'
                                  : PhoneInputFormatter.formatString(supplier.phone!),
                              style: context.textTheme.labelLarge?.copyWith(color: color),
                            ),
                          ],
                        ),
                        if (showProductsTag)
                          AppTag(
                            title: countText,
                            icon: AppIcons.package2,
                            color: context.colorScheme.primary,
                            onTap: () => context.push(AppRoutes.products, extra: supplier.name),
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
