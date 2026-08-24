import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PaymentDeliveryToggle extends StatelessWidget {
  final bool isDelivery;
  final ValueChanged<bool> onChanged;

  const PaymentDeliveryToggle({
    super.key,
    required this.isDelivery,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: isDelivery
            ? context.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        border: Border.all(
          color: isDelivery ? context.colorScheme.primary : context.colorScheme.outline,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.deliveryTruck,
            color: isDelivery ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant,
          ),
          const Gap(AppSpacing.space12),
          Expanded(
            child: AppSwitchTitle(
              value: isDelivery,
              title: 'É para entrega?',
              subtitle: isDelivery ? 'Agende data, horário e endereço' : 'Retirada no balcão / local',
              titleStyle: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
