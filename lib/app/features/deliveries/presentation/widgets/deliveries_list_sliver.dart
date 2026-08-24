import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/widgets/delivery_card.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/widgets/delivery_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DeliveriesListSliver extends StatelessWidget {
  final DeliveriesViewModel viewModel;

  const DeliveriesListSliver({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModel.state == DeliveriesState.loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.state == DeliveriesState.error) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            viewModel.errorMessage ?? 'Erro ao carregar entregas.',
            style: context.textTheme.bodyMedium?.copyWith(color: AppColors.error),
          ),
        ),
      );
    }

    if (viewModel.deliveries.isEmpty) {
      return const SliverFillRemaining(
        child: AppEmptyList(
          message: 'Nenhuma entrega registrada.\nAo finalizar uma venda com opção de entrega, ela aparecerá aqui.',
          icon: AppIcons.deliveryTruck,
          iconColor: Colors.orange,
          iconSize: AppSpacing.icon48,
        ),
      );
    }

    final filtered = viewModel.filteredDeliveries;

    if (filtered.isEmpty) {
      return const SliverFillRemaining(
        child: AppEmptyList(
          message: 'Nenhuma entrega encontrada para o filtro selecionado.',
          icon: AppIcons.searchOff,
          iconColor: Colors.grey,
          iconSize: AppSpacing.icon48,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      sliver: SliverList.separated(
        itemCount: filtered.length,
        separatorBuilder: (_, _) => const Gap(AppSpacing.space12),
        itemBuilder: (context, index) {
          final delivery = filtered[index];
          return DeliveryCard(
            delivery: delivery,
            onTap: () {
              DeliveryDetailBottomSheet.show(
                context: context,
                delivery: delivery,
                viewModel: viewModel,
              );
            },
            onStatusChanged: (newStatus) {
              viewModel.updateDeliveryStatus(delivery.id, newStatus);
            },
          );
        },
      ),
    );
  }
}
