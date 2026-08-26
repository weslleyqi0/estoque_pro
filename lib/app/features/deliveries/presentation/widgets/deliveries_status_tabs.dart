import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DeliveriesStatusTabs extends StatelessWidget {
  final DeliveriesViewModel viewModel;
  final ValueChanged<DeliveryFilterTab>? onTabSelected;

  const DeliveriesStatusTabs({
    super.key,
    required this.viewModel,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: Row(
        children: DeliveryFilterTab.values.map((tab) {
          final isSelected = viewModel.selectedTab == tab;
          final count = viewModel.getTabCount(tab);

          Color badgeColor;
          if (tab == DeliveryFilterTab.delayed) {
            badgeColor = AppColors.error;
          } else if (tab == DeliveryFilterTab.pending) {
            badgeColor = AppColors.warning;
          } else if (tab == DeliveryFilterTab.inProgress) {
            badgeColor = Colors.blue;
          } else if (tab == DeliveryFilterTab.completed) {
            badgeColor = Colors.green;
          } else {
            badgeColor = primaryColor;
          }

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space8),
            child: InkWell(
              onTap: () {
                viewModel.setSelectedTab(tab);
                onTabSelected?.call(tab);
              },
              borderRadius: BorderRadius.circular(AppSpacing.radius16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space12,
                  horizontal: AppSpacing.space16,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : context.colorScheme.surface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSpacing.radius24),
                  border: Border.all(
                    color: isSelected ? primaryColor : context.colorScheme.onSurface.withValues(alpha: 0.2),
                    width: isSelected ? 2.0 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tab.label,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isSelected ? AppColors.white : context.colorScheme.onSurface.withValues(alpha: 0.8),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    if (count > 0) ...[
                      const Gap(AppSpacing.space8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space8,
                          vertical: AppSpacing.space4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colorScheme.outline.withValues(alpha: 0.4)
                              : badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSpacing.radius24),
                        ),
                        child: Text(
                          '$count',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: isSelected ? context.colorScheme.onPrimary : badgeColor,
                            fontWeight: FontWeight.bold,
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
