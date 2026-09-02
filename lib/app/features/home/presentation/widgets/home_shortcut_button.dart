import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/home/domain/entities/home_shortcut_type.dart';
import 'package:estoque_pro/app/features/home/presentation/widgets/home_button.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShortcutButton extends StatelessWidget {
  final HomeShortcutType type;
  final int lowStockCount;
  final int inProgressSalesCount;
  final int pendingOrDelayedDeliveriesCount;
  final bool hasDelayedDeliveries;
  final VoidCallback? onProductsTap;

  const HomeShortcutButton({
    super.key,
    required this.type,
    this.lowStockCount = 0,
    this.inProgressSalesCount = 0,
    this.pendingOrDelayedDeliveriesCount = 0,
    this.hasDelayedDeliveries = false,
    this.onProductsTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case HomeShortcutType.products:
        return HomeButton(
          title: type.title,
          subTitle: type.subTitle,
          badgerContent: lowStockCount > 0 ? '$lowStockCount' : null,
          badgerColor: AppColors.warning,
          color: type.color,
          icon: type.icon,
          onPressed: onProductsTap ?? () => context.push(AppRoutes.products),
        );
      case HomeShortcutType.sales:
        return HomeButton(
          title: type.title,
          subTitle: type.subTitle,
          badgerContent: inProgressSalesCount > 0 ? '$inProgressSalesCount' : null,
          badgerColor: AppColors.warning,
          color: type.color,
          icon: type.icon,
          onPressed: () => context.push(
            AppRoutes.sales,
            extra: SalesFilterTab.all,
          ),
        );
      case HomeShortcutType.categories:
        return HomeButton(
          title: type.title,
          subTitle: type.subTitle,
          color: type.color,
          icon: type.icon,
          onPressed: () => context.push(AppRoutes.categories),
        );
      case HomeShortcutType.suppliers:
        return HomeButton(
          title: type.title,
          subTitle: type.subTitle,
          color: type.color,
          icon: type.icon,
          onPressed: () => context.push(AppRoutes.suppliers),
        );
      case HomeShortcutType.customers:
        return HomeButton(
          title: type.title,
          subTitle: type.subTitle,
          color: type.color,
          icon: type.icon,
          onPressed: () => context.push(AppRoutes.customers),
        );
      case HomeShortcutType.deliveries:
        return HomeButton(
          title: type.title,
          subTitle: type.subTitle,
          badgerContent: pendingOrDelayedDeliveriesCount > 0 ? '$pendingOrDelayedDeliveriesCount' : null,
          badgerColor: hasDelayedDeliveries ? AppColors.error : AppColors.warning,
          color: type.color,
          icon: type.icon,
          onPressed: () => context.push(
            AppRoutes.deliveries,
            extra: DeliveryFilterTab.all,
          ),
        );
      case HomeShortcutType.reports:
        return HomeButton(
          title: type.title,
          subTitle: type.subTitle,
          color: type.color,
          icon: type.icon,
          onPressed: () => context.push(AppRoutes.reports),
        );
      case HomeShortcutType.users:
        return HomeButton(
          title: type.title,
          subTitle: type.subTitle,
          color: type.color,
          icon: type.icon,
          onPressed: () => context.push(AppRoutes.users),
        );
    }
  }
}
