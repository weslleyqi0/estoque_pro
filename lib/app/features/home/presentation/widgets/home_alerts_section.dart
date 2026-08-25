import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class _AlertData {
  final String title;
  final String subtitle;
  final IconData icon;
  final AppInfoBannerType type;
  final VoidCallback onTap;

  const _AlertData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
    required this.onTap,
  });
}

class HomeAlertsSection extends StatelessWidget {
  final int delayedDeliveriesCount;
  final int pendingDeliveriesCount;
  final int inProgressSalesCount;
  final int lowStockProductsCount;
  final VoidCallback? onLowStockTap;

  const HomeAlertsSection({
    super.key,
    this.delayedDeliveriesCount = 0,
    this.pendingDeliveriesCount = 0,
    this.inProgressSalesCount = 0,
    this.lowStockProductsCount = 0,
    this.onLowStockTap,
  });

  @override
  Widget build(BuildContext context) {
    final alerts = <_AlertData>[
      if (delayedDeliveriesCount > 0)
        _AlertData(
          title: delayedDeliveriesCount == 1
              ? '1 entrega atrasada'
              : '$delayedDeliveriesCount entregas atrasadas',
          subtitle: 'Toque para gerenciar as entregas atrasadas',
          icon: AppIcons.deliveryTruck,
          type: AppInfoBannerType.error,
          onTap: () => context.push(
            AppRoutes.deliveries,
            extra: DeliveryFilterTab.delayed,
          ),
        ),
      if (pendingDeliveriesCount > 0)
        _AlertData(
          title: pendingDeliveriesCount == 1
              ? '1 entrega pendente'
              : '$pendingDeliveriesCount entregas pendentes',
          subtitle: 'Toque para gerenciar as entregas pendentes',
          icon: AppIcons.deliveryTruck,
          type: AppInfoBannerType.warning,
          onTap: () => context.push(
            AppRoutes.deliveries,
            extra: DeliveryFilterTab.pending,
          ),
        ),
      if (inProgressSalesCount > 0)
        _AlertData(
          title: inProgressSalesCount == 1
              ? '1 venda aguardando finalização'
              : '$inProgressSalesCount vendas aguardando finalização',
          subtitle: 'Toque para ver ou gerenciar as vendas em andamento',
          icon: AppIcons.shoppingCart,
          type: AppInfoBannerType.warning,
          onTap: () => context.push(
            AppRoutes.sales,
            extra: SalesFilterTab.inProgress,
          ),
        ),
      if (lowStockProductsCount > 0)
        _AlertData(
          title: lowStockProductsCount == 1
              ? '1 produto com estoque baixo'
              : '$lowStockProductsCount produtos com estoque baixo',
          subtitle: 'Toque para gerenciar o estoque dos produtos',
          icon: AppIcons.package2,
          type: AppInfoBannerType.warning,
          onTap: onLowStockTap ?? () => context.push(AppRoutes.products, extra: true),
        ),
    ];

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(AppSpacing.space8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: Text(
            'Avisos',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Gap(AppSpacing.space8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
          itemCount: alerts.length,
          separatorBuilder: (_, _) => const Gap(AppSpacing.space12),
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return AppInfoBanner(
              title: alert.title,
              subtitle: alert.subtitle,
              icon: alert.icon,
              type: alert.type,
              onTap: alert.onTap,
            );
          },
        ),
      ],
    );
  }
}
