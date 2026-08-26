import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_summary_entity.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomerItem extends StatelessWidget {
  final CustomerEntity customer;
  final CustomerSummaryEntity? summary;
  final CustomerDebtsViewModel debtsViewModel;
  final AuthViewModel authViewModel;
  final VoidCallback? onTap;
  final bool canEdit;

  const CustomerItem({
    super.key,
    required this.customer,
    this.summary,
    required this.debtsViewModel,
    required this.authViewModel,
    this.onTap,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = !customer.isActive ? context.colorScheme.onSurface.withValues(alpha: 0.4) : null;
    final effectiveSummary = summary ?? debtsViewModel.getCustomerSummary(customer.id);
    final hasDebt = effectiveSummary.hasPendingDebt;
    final debtBadgeColor = hasDebt ? AppColors.error : AppColors.success;

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
                  debtsViewModel: debtsViewModel,
                  authViewModel: authViewModel,
                ),
        borderRadius: AppSpacing.borderRadius16,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              const Gap(AppSpacing.space12),
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
                    const Gap(2),
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
                    const Gap(AppSpacing.space8),
                    // Badges de Compras e Débitos
                    Wrap(
                      spacing: AppSpacing.space8,
                      runSpacing: AppSpacing.space4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppSpacing.radius4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppIcons.shoppingBag,
                                size: AppSpacing.icon16 - 4,
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              const Gap(AppSpacing.space4),
                              Text(
                                '${effectiveSummary.totalPurchasesCount} ${effectiveSummary.totalPurchasesCount == 1 ? "compra" : "compras"}',
                                style: context.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: debtBadgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppSpacing.radius4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasDebt ? AppIcons.warning : AppIcons.checkCircle,
                                size: AppSpacing.icon16 - 4,
                                color: debtBadgeColor,
                              ),
                              const Gap(AppSpacing.space4),
                              Text(
                                hasDebt
                                    ? 'Deve ${CurrencyInputFormatter.formatCurrency(effectiveSummary.currentDebt)}'
                                    : 'Sem débitos',
                                style: context.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: debtBadgeColor,
                                ),
                              ),
                            ],
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
