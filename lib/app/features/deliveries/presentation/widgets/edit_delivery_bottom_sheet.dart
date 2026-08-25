import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_status.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/payment_delivery_schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EditDeliveryBottomSheet extends StatefulWidget {
  final DeliveryEntity delivery;
  final DeliveriesViewModel viewModel;

  const EditDeliveryBottomSheet({
    super.key,
    required this.delivery,
    required this.viewModel,
  });

  static Future<bool?> show({
    required BuildContext context,
    required DeliveryEntity delivery,
    required DeliveriesViewModel viewModel,
  }) {
    return AppBottomSheet.show<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditDeliveryBottomSheet(
        delivery: delivery,
        viewModel: viewModel,
      ),
    );
  }

  @override
  State<EditDeliveryBottomSheet> createState() => _EditDeliveryBottomSheetState();
}

class _EditDeliveryBottomSheetState extends State<EditDeliveryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _customerNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;

  late DateTime _scheduledDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(text: widget.delivery.customerName);
    _addressController = TextEditingController(text: widget.delivery.customerAddress);
    _phoneController = TextEditingController(text: widget.delivery.customerPhone ?? '');
    _notesController = TextEditingController(text: widget.delivery.observations);
    _scheduledDate = widget.delivery.scheduledAt;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initialDate = _scheduledDate.isAfter(now) ? _scheduledDate : now;

    final picked = await AppDateTimePicker.show(
      context: context,
      title: 'Data e Horário da Entrega',
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      minTime: const TimeOfDay(hour: 6, minute: 0),
      maxTime: const TimeOfDay(hour: 19, minute: 0),
      invalidTimeMessage: 'Fora do nosso horário de entrega (06:00 às 19:00)',
      is24HourMode: true,
      isShowSeconds: false,
      minutesInterval: 10,
    );

    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      AppSnackbar.error(context, 'Informe o endereço de entrega.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isFutureDate = _scheduledDate.isAfter(DateTime.now());
      final newStatus = widget.delivery.status == DeliveryStatus.delayed && isFutureDate
          ? DeliveryStatus.pending
          : widget.delivery.status;

      final updatedDelivery = widget.delivery.copyWith(
        customerName: _customerNameController.text.trim().isNotEmpty
            ? _customerNameController.text.trim()
            : widget.delivery.customerName,
        customerPhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        customerAddress: address,
        observations: _notesController.text.trim(),
        scheduledAt: _scheduledDate,
        status: newStatus,
      );

      await widget.viewModel.updateDelivery(updatedDelivery);

      if (mounted) {
        Navigator.pop(context, true);
        AppSnackbar.success(context, 'Entrega atualizada com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.error(context, 'Erro ao atualizar entrega: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(
                        top: AppSpacing.space16,
                        bottom: AppSpacing.space12,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space16,
                      0,
                      AppSpacing.space16,
                      AppSpacing.space8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.space8),
                          decoration: BoxDecoration(
                            color: context.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            AppIcons.edit,
                            color: context.colorScheme.onPrimaryContainer,
                            size: AppSpacing.icon20,
                          ),
                        ),
                        const Gap(AppSpacing.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Editar Entrega',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Venda #${widget.delivery.saleNumber}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(AppIcons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(AppSpacing.space16),
                      children: [
                        Text(
                          'Destinatário & Contato',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(AppSpacing.space8),
                        AppTextfield(
                          controller: _customerNameController,
                          label: 'Nome do Destinatário',
                          hint: 'Nome do cliente',
                          prefixIcon: AppIcons.person,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Informe o nome do destinatário';
                            }
                            return null;
                          },
                        ),
                        const Gap(AppSpacing.space12),
                        AppTextfield(
                          controller: _phoneController,
                          label: 'Telefone / WhatsApp (opcional)',
                          hint: '(00) 00000-0000',
                          prefixIcon: AppIcons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const Gap(AppSpacing.space16),
                        Text(
                          'Endereço de Entrega',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(AppSpacing.space8),
                        AppTextfield(
                          controller: _addressController,
                          label: 'Endereço Completo *',
                          hint: 'Rua, número, complemento, bairro...',
                          prefixIcon: AppIcons.homePin,
                          maxLines: 2,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Informe o endereço de entrega';
                            }
                            return null;
                          },
                        ),
                        const Gap(AppSpacing.space16),
                        Text(
                          'Agendamento',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(AppSpacing.space8),
                        PaymentDeliveryScheduleCard(
                          scheduledDate: _scheduledDate,
                          onTap: _pickDateTime,
                        ),
                        const Gap(AppSpacing.space16),
                        Text(
                          'Observações',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(AppSpacing.space8),
                        AppTextfield(
                          controller: _notesController,
                          hint: 'Instruções especiais de entrega (opcional)',
                          prefixIcon: AppIcons.editNote,
                          maxLines: 2,
                        ),
                        const Gap(AppSpacing.space24),
                        AppButton(
                          label: 'Salvar Alterações',
                          icon: AppIcons.check,
                          isFullWidth: true,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _onSave,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
