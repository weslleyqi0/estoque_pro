import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final hasPhone = customerPhone != null && customerPhone!.trim().isNotEmpty;
    final hasAddress = customerAddress.trim().isNotEmpty;
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
              if (hasAddress) ...[
                AppIconButton(
                  icon: AppIcons.directions,
                  iconColor: context.colorScheme.primary,
                  visualDensity: VisualDensity.compact,
                  size: AppIconButtonSize.medium,
                  tooltip: 'Abrir no Maps',
                  onPressed:
                      onOpenMap ??
                      () {
                        Clipboard.setData(ClipboardData(text: customerAddress));
                        AppSnackbar.info(context, 'Endereço copiado para buscar no mapa');
                      },
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
                AppIconButton(
                  icon: AppIcons.phone,
                  iconColor: Colors.blue,
                  visualDensity: VisualDensity.compact,
                  size: AppIconButtonSize.medium,
                  tooltip: 'Ligar',
                  onPressed:
                      onCall ??
                      () {
                        Clipboard.setData(ClipboardData(text: customerPhone!));
                        AppSnackbar.info(context, 'Telefone copiado para discagem');
                      },
                ),
                AppIconButton(
                  icon: AppIcons.chat,
                  iconColor: Colors.green,
                  visualDensity: VisualDensity.compact,
                  size: AppIconButtonSize.medium,
                  tooltip: 'WhatsApp',
                  onPressed:
                      onWhatsApp ??
                      () {
                        Clipboard.setData(ClipboardData(text: customerPhone!));
                        AppSnackbar.info(context, 'Telefone copiado para WhatsApp');
                      },
                ),
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
