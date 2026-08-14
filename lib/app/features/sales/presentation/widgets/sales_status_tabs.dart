import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SalesStatusTabs extends StatelessWidget {
  final SalesViewModel viewModel;
  final List<SaleEntity>? draftSales;
  final ValueChanged<SalesFilterTab>? onTabSelected;

  const SalesStatusTabs({
    super.key,
    required this.viewModel,
    this.draftSales,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const .symmetric(horizontal: AppSpacing.space16),
      child: Row(
        children: SalesFilterTab.values.map((tab) {
          final isSelected = viewModel.selectedTab == tab;
          final count = viewModel.getTabCount(tab, draftSales: draftSales);

          return Padding(
            padding: const .only(right: AppSpacing.space8),
            child: InkWell(
              onTap: () {
                viewModel.setSelectedTab(tab);
                onTabSelected?.call(tab);
              },
              borderRadius: .circular(AppSpacing.radius16),
              child: Container(
                padding: const .symmetric(vertical: AppSpacing.space12, horizontal: AppSpacing.space16),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : context.colorScheme.surface.withValues(alpha: 0.3),
                  borderRadius: .circular(AppSpacing.radius24),
                  border: .all(
                    color: isSelected ? primaryColor : context.colorScheme.onSurface.withValues(alpha: 0.2),
                    width: isSelected ? 2.0 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: .min,
                  children: [
                    Text(
                      tab.label,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? context.colorScheme.surface
                            : context.colorScheme.onSurface.withValues(alpha: 0.8),
                        fontWeight: isSelected ? .bold : .w500,
                      ),
                    ),
                    if (count > 0) ...[
                      const Gap(AppSpacing.space4),
                      Container(
                        padding: const .symmetric(horizontal: AppSpacing.space8, vertical: AppSpacing.space4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colorScheme.outline.withValues(alpha: 0.4)
                              : primaryColor.withValues(alpha: 0.15),
                          borderRadius: .circular(AppSpacing.radius24),
                        ),
                        child: Text(
                          '$count',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: isSelected ? context.colorScheme.onPrimary : context.colorScheme.onSurface,
                            fontWeight: isSelected ? .bold : .w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
