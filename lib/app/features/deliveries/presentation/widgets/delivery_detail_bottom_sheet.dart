import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/widgets/delivery_recipient_card.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/widgets/delivery_status_banner.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/widgets/edit_delivery_bottom_sheet.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/payment_delivery_schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryDetailBottomSheet extends StatelessWidget {
  final DeliveryEntity delivery;
  final DeliveriesViewModel viewModel;

  const DeliveryDetailBottomSheet({
    super.key,
    required this.delivery,
    required this.viewModel,
  });

  static Future<void> show({
    required BuildContext context,
    required DeliveryEntity delivery,
    required DeliveriesViewModel viewModel,
  }) {
    return AppBottomSheet.show(
      context: context,
      isScrollControlled: true,
      builder: (_) => DeliveryDetailBottomSheet(
        delivery: delivery,
        viewModel: viewModel,
      ),
    );
  }

  void _editDelivery(BuildContext context) async {
    final result = await EditDeliveryBottomSheet.show(
      context: context,
      delivery: delivery,
      viewModel: viewModel,
    );
    if (result == true && context.mounted) {
      Navigator.pop(context);
    }
  }

  void _reschedule(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = delivery.scheduledAt.isAfter(now) ? delivery.scheduledAt : now;

    final pickedDateTime = await AppDateTimePicker.show(
      context: context,
      title: 'Reagendar Entrega',
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      invalidTimeMessage: 'Fora do nosso horário de entrega',
      is24HourMode: true,
      isShowSeconds: false,
      minutesInterval: 10,
    );

    if (pickedDateTime == null || !context.mounted) return;

    await viewModel.rescheduleDelivery(delivery, pickedDateTime);

    if (context.mounted) {
      Navigator.pop(context);
      AppSnackbar.success(
        context,
        'Entrega reagendada para ${DateFormat('dd/MM/yyyy HH:mm').format(pickedDateTime)}',
      );
    }
  }

  void _updateStatus(BuildContext context, DeliveryStatus status) async {
    await viewModel.updateDeliveryStatus(delivery.id, status);
    if (context.mounted) {
      Navigator.pop(context);
      AppSnackbar.success(
        context,
        status == DeliveryStatus.completed
            ? 'Entrega finalizada com sucesso!'
            : status == DeliveryStatus.inProgress
            ? 'Entrega iniciada!'
            : 'Status da entrega atualizado!',
      );
    }
  }

  void _cancelDelivery(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar entrega?'),
        content: const Text('Tem certeza que deseja cancelar esta entrega?'),
        actions: [
          AppButton.text(
            label: 'Não',
            onPressed: () => Navigator.pop(ctx, false),
          ),
          AppButton.text(
            label: 'Sim, cancelar',
            textStyle: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.error, fontWeight: .bold),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await viewModel.updateDeliveryStatus(delivery.id, DeliveryStatus.cancelled);
      if (context.mounted) {
        Navigator.pop(context);
        AppSnackbar.info(context, 'Entrega cancelada.');
      }
    }
  }

  void _deleteDelivery(BuildContext context) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Excluir Entrega',
      content: 'Deseja realmente excluir permanentemente a entrega da venda ${delivery.saleNumber}?',
      confirmLabel: 'Excluir',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await viewModel.deleteDelivery(delivery.id);
        if (context.mounted) {
          Navigator.pop(context);
          AppSnackbar.success(context, 'Entrega excluída com sucesso!');
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.error(context, 'Erro ao excluir entrega: ${e.toString()}');
        }
      }
    }
  }

  void _openMap(BuildContext context) async {
    final address = delivery.customerAddress.trim();
    if (address.isEmpty) {
      AppSnackbar.warning(context, 'Endereço não informado.');
      return;
    }

    try {
      final marker = MapLauncher.marker(LocationSearch(address));
      final supportedMaps = await marker.getSupportedMaps();
      final installedMaps = supportedMaps.where((m) => m.isInstalled).toList();

      if (installedMaps.length > 1 && context.mounted) {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext ctx) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        'Abrir no mapa',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    for (final map in installedMaps)
                      ListTile(
                        onTap: () {
                          Navigator.pop(ctx);
                          marker.show(map: map.mapType);
                        },
                        title: Text(map.displayName),
                        leading: const Icon(AppIcons.locationOn),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        await marker.show();
      }
    } catch (_) {
      final encodedAddress = Uri.encodeComponent(address);
      final mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
      if (await canLaunchUrl(mapUri)) {
        await launchUrl(mapUri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        AppSnackbar.warning(context, 'Não foi possível abrir o mapa.');
      }
    }
  }

  void _callPhone(BuildContext context) async {
    final phone = delivery.customerPhone?.replaceAll(RegExp(r'\D'), '');
    if (phone == null || phone.trim().isEmpty) {
      AppSnackbar.warning(context, 'Telefone não informado.');
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    try {
      final launched = await launchUrl(uri);
      if (!launched && context.mounted) {
        AppSnackbar.warning(context, 'Não foi possível iniciar a ligação.');
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.warning(context, 'Não foi possível iniciar a ligação.');
      }
    }
  }

  void _openWhatsApp(BuildContext context) async {
    final phone = delivery.customerPhone?.replaceAll(RegExp(r'\D'), '');
    if (phone == null || phone.trim().isEmpty) {
      AppSnackbar.warning(context, 'WhatsApp/Telefone não informado.');
      return;
    }

    final formattedPhone = phone.length <= 11 ? '55$phone' : phone;

    final message = '';
    final whatsappUri = Uri.parse('https://wa.me/$formattedPhone?text=$message');

    try {
      final launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        AppSnackbar.warning(context, 'Não foi possível abrir o WhatsApp.');
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.warning(context, 'Não foi possível abrir o WhatsApp.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = delivery.effectiveStatus;
    final scheduledFormatted = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(delivery.scheduledAt);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(
                    top: AppSpacing.space16,
                    bottom: AppSpacing.space12,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Entrega Venda ${delivery.saleNumber}',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Agendada para $scheduledFormatted',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: delivery.isDelayed ? AppColors.error : context.colorScheme.onSurfaceVariant,
                              fontWeight: delivery.isDelayed ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (effectiveStatus != DeliveryStatus.completed && effectiveStatus != DeliveryStatus.cancelled) ...[
                      AppIconButton(
                        size: AppIconButtonSize.large,
                        icon: AppIcons.edit,
                        iconColor: context.colorScheme.primary,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Editar Entrega',
                        onPressed: () => _editDelivery(context),
                      ),
                    ],
                    if (effectiveStatus == DeliveryStatus.cancelled || effectiveStatus == DeliveryStatus.completed) ...[
                      AppIconButton(
                        size: AppIconButtonSize.large,
                        icon: AppIcons.delete,
                        iconColor: context.colorScheme.error,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Excluir Entrega',
                        onPressed: () => _deleteDelivery(context),
                      ),
                    ],
                    CloseButton(onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),

              const Divider(height: AppSpacing.space20),

              // Scrollable Details
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                  children: [
                    // --- Status Banner ---
                    DeliveryStatusBanner(
                      status: effectiveStatus,
                      isDelayed: delivery.isDelayed,
                      scheduledAt: delivery.scheduledAt,
                    ),

                    const Gap(AppSpacing.space16),

                    // --- Agendamento da Entrega ---
                    Text(
                      'Agendamento',
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Gap(AppSpacing.space8),
                    PaymentDeliveryScheduleCard(
                      scheduledDate: delivery.scheduledAt,
                      onTap: effectiveStatus != DeliveryStatus.completed && effectiveStatus != DeliveryStatus.cancelled
                          ? () => _reschedule(context)
                          : () {},
                    ),

                    const Gap(AppSpacing.space16),

                    // --- Dados do Cliente e Endereço ---
                    Text(
                      'Destinatário & Endereço',
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Gap(AppSpacing.space8),
                    DeliveryRecipientCard(
                      customerName: delivery.customerName,
                      customerPhone: delivery.customerPhone,
                      customerAddress: delivery.customerAddress,
                      observations: delivery.observations,
                      onOpenMap: () => _openMap(context),
                      onCall: () => _callPhone(context),
                      onWhatsApp: () => _openWhatsApp(context),
                    ),

                    const Gap(AppSpacing.space16),

                    // --- Itens da Venda ---
                    Text(
                      'Itens para Entrega (${delivery.totalItems})',
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Gap(AppSpacing.space8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: delivery.items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = delivery.items[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.space12,
                            right: AppSpacing.space8,
                            top: AppSpacing.space8,
                            bottom: AppSpacing.space8,
                          ),
                          child: Text(
                            '${item.quantity}x ${item.productName}',
                            style: context.textTheme.bodyMedium,
                          ),
                        );
                      },
                    ),

                    const Gap(AppSpacing.space24),
                  ],
                ),
              ),

              // Bottom Actions
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (effectiveStatus == DeliveryStatus.pending) ...[
                      AppButton(
                        label: 'Iniciar Entrega (Em andamento)',
                        icon: AppIcons.play,
                        isFullWidth: true,
                        onPressed: () => _updateStatus(context, DeliveryStatus.inProgress),
                      ),
                      const Gap(AppSpacing.space8),
                    ],
                    if (effectiveStatus == DeliveryStatus.inProgress ||
                        effectiveStatus == DeliveryStatus.delayed ||
                        effectiveStatus == DeliveryStatus.pending) ...[
                      AppButton(
                        label: 'Marcar como Entregue',
                        icon: AppIcons.check,
                        backgroundColor: Colors.green,
                        isFullWidth: true,
                        onPressed: () => _updateStatus(context, DeliveryStatus.completed),
                      ),
                      const Gap(AppSpacing.space8),
                    ],
                    if (effectiveStatus != DeliveryStatus.completed && effectiveStatus != DeliveryStatus.cancelled) ...[
                      Row(
                        children: [
                          Expanded(
                            child: AppButton.outlined(
                              label: 'Cancelar',
                              icon: AppIcons.close,
                              borderColor: context.colorScheme.error,
                              backgroundColor: context.colorScheme.error.withValues(alpha: 0.1),
                              onPressed: () => _cancelDelivery(context),
                            ),
                          ),
                          const Gap(AppSpacing.space8),
                          Expanded(
                            child: AppButton.outlined(
                              label: 'Reagendar',
                              icon: AppIcons.calendarClock,
                              onPressed: () => _reschedule(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (effectiveStatus == DeliveryStatus.cancelled || effectiveStatus == DeliveryStatus.completed) ...[
                      AppButton.outlined(
                        label: 'Excluir Entrega',
                        icon: AppIcons.delete,
                        borderColor: context.colorScheme.error,
                        backgroundColor: context.colorScheme.error.withValues(alpha: 0.1),
                        isFullWidth: true,
                        onPressed: () => _deleteDelivery(context),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
