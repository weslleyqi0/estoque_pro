import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/customers_debt_report_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CustomersDebtReportCard extends StatelessWidget {
  final CustomersDebtReportEntity customersDebtReport;

  const CustomersDebtReportCard({
    super.key,
    required this.customersDebtReport,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final hasDebt = customersDebtReport.customersInDebtCount > 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space8),
                    decoration: BoxDecoration(
                      color: Colors.pink.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radius8),
                    ),
                    child: const Icon(
                      Icons.groups_outlined,
                      color: Colors.pink,
                      size: AppSpacing.icon20,
                    ),
                  ),
                  const Gap(AppSpacing.space12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clientes & Fiados',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${customersDebtReport.totalCustomers} clientes cadastrados',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 14),
                onPressed: () => context.push(AppRoutes.customers),
                tooltip: 'Ver clientes',
              ),
            ],
          ),

          const Gap(AppSpacing.space16),

          // Card de Fiado / Devedores
          Container(
            padding: const EdgeInsets.all(AppSpacing.space16),
            decoration: BoxDecoration(
              color: hasDebt ? Colors.pink.withValues(alpha: 0.08) : AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radius12),
              border: Border.all(
                color: hasDebt ? Colors.pink.withValues(alpha: 0.25) : AppColors.success.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total a Receber (Fiados)',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const Gap(AppSpacing.space4),
                    Text(
                      currency.format(customersDebtReport.totalDebtAmount),
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: hasDebt ? Colors.pink.shade700 : AppColors.success,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space12,
                    vertical: AppSpacing.space8,
                  ),
                  decoration: BoxDecoration(
                    color: hasDebt ? Colors.pink.withValues(alpha: 0.18) : AppColors.success.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppSpacing.radius8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${customersDebtReport.customersInDebtCount}',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: hasDebt ? Colors.pink.shade700 : AppColors.success,
                        ),
                      ),
                      Text(
                        'em débito',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: hasDebt ? Colors.pink.shade700 : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
