import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DeliveryRecipientCard extends StatelessWidget {
  final String customerName;
  final String? customerPhone;
  final String customerAddress;
  final String observations;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onCall;
  final VoidCallback? onOpenMap;

  const DeliveryRecipientCard({
    super.key,
    required this.customerName,
    this.customerPhone,
    required this.customerAddress,
    this.observations = '',
    this.onWhatsApp,
    this.onCall,
    this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final cleanPhone = customerPhone?.replaceAll(RegExp(r'\D'), '');
    final hasPhone = cleanPhone != null && cleanPhone.isNotEmpty;
    final hasAddress = customerAddress.trim().isNotEmpty &&
        customerAddress.trim().toLowerCase() != 'endereço não cadastrado' &&
        customerAddress.trim().toLowerCase() != 'endereço não informado';
    final hasObservations = observations.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.only(left: AppSpacing.space12),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do Cliente
          Row(
            children: [
              Icon(AppIcons.person, size: AppSpacing.icon20),
              const Gap(AppSpacing.space8),
              Expanded(
                child: Text(
                  customerName,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Endereço com ações (Maps, Copiar)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                AppIcons.locationOn,
                size: AppSpacing.icon20,
                color: context.colorScheme.onSurfaceVariant,
              ),
              const Gap(AppSpacing.space8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    hasAddress ? customerAddress : 'Endereço não cadastrado',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: hasAddress ? context.colorScheme.onSurface : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              if (hasAddress && onOpenMap != null) ...[
                AppIconButton(
                  icon: AppIcons.directions,
                  iconColor: context.colorScheme.primary,
                  visualDensity: VisualDensity.compact,
                  size: AppIconButtonSize.medium,
                  tooltip: 'Abrir no Maps',
                  onPressed: onOpenMap,
                ),
              ],
            ],
          ),

          // Telefone com ações (WhatsApp, Telefone, Copiar)
          if (hasPhone) ...[
            Row(
              children: [
                Icon(
                  AppIcons.phone,
                  size: AppSpacing.icon20,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const Gap(AppSpacing.space8),
                Expanded(
                  child: Text(
                    customerPhone!,
                    style: context.textTheme.bodyMedium,
                  ),
                ),
                if (onCall != null) ...[
                  AppIconButton(
                    icon: AppIcons.phone,
                    iconColor: Colors.blue,
                    visualDensity: VisualDensity.compact,
                    size: AppIconButtonSize.medium,
                    tooltip: 'Ligar',
                    onPressed: onCall,
                  ),
                ],
                if (onWhatsApp != null) ...[
                  AppIconButton(
                    icon: AppIcons.chat,
                    iconColor: Colors.green,
                    visualDensity: VisualDensity.compact,
                    size: AppIconButtonSize.medium,
                    tooltip: 'WhatsApp',
                    onPressed: onWhatsApp,
                  ),
                ],
              ],
            ),
          ],

          // Observações
          if (hasObservations) ...[
            const Gap(AppSpacing.space4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  AppIcons.editNote,
                  size: AppSpacing.icon24,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const Gap(AppSpacing.space8),
                Expanded(
                  child: Text(
                    'Obs: $observations',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
