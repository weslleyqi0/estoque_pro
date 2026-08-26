import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_summary_entity.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/register_customer_payment_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomerDebtSummaryCard extends StatelessWidget {
  final CustomerEntity customer;
  final CustomerSummaryEntity summary;
  final CustomerDebtsViewModel debtsViewModel;
  final AuthViewModel authViewModel;

  const CustomerDebtSummaryCard({
    super.key,
    required this.customer,
    required this.summary,
    required this.debtsViewModel,
    required this.authViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final hasDebt = summary.hasPendingDebt;
    final primaryDebtColor = hasDebt ? AppColors.error : AppColors.success;

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        border: Border.all(
          color: hasDebt
              ? AppColors.error.withValues(alpha: 0.3)
              : context.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.receiptLong,
                      size: AppSpacing.icon20,
                      color: context.colorScheme.primary,
                    ),
                    const Gap(AppSpacing.space8),
                    Text(
                      'Resumo de Débitos',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space8,
                    vertical: AppSpacing.space4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryDebtColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radius8),
                  ),
                  child: Text(
                    hasDebt ? 'Débito Pendente' : 'Sem Débitos',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: primaryDebtColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const Gap(AppSpacing.space16),

            // Saldo Devedor em Destaque
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space12),
              decoration: BoxDecoration(
                color: hasDebt
                    ? AppColors.error.withValues(alpha: 0.08)
                    : context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSpacing.radius12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total a Pagar',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        CurrencyInputFormatter.formatCurrency(summary.currentDebt),
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: hasDebt ? AppColors.error : context.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  if (hasDebt)
                    AppButton(
                      label: 'Abater Dívida',
                      icon: AppIcons.check,
                      onPressed: () => RegisterCustomerPaymentBottomSheet.show(
                        context: context,
                        customer: customer,
                        currentDebt: summary.currentDebt,
                        debtsViewModel: debtsViewModel,
                        authViewModel: authViewModel,
                      ),
                    ),
                ],
              ),
            ),

            const Gap(AppSpacing.space16),

            // Métricas Rápidas: Compras, Total Fiado, Total Pago
            Row(
              children: [
                Expanded(
                  child: _MetricItem(
                    label: 'Compras',
                    value: '${summary.totalPurchasesCount}',
                    icon: AppIcons.shoppingBag,
                  ),
                ),
                Container(
                  height: 32,
                  width: 1,
                  color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: _MetricItem(
                    label: 'Total Fiado',
                    value: CurrencyInputFormatter.formatCurrency(summary.totalDebt),
                    icon: AppIcons.trendingDown,
                  ),
                ),
                Container(
                  height: 32,
                  width: 1,
                  color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: _MetricItem(
                    label: 'Total Pago',
                    value: CurrencyInputFormatter.formatCurrency(summary.totalPaid),
                    icon: AppIcons.trendingUp,
                    valueColor: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSpacing.icon16,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const Gap(AppSpacing.space4),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const Gap(2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? context.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
