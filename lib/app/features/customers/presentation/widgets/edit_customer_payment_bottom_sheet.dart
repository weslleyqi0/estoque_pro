import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EditCustomerPaymentBottomSheet extends StatefulWidget {
  final CustomerPaymentEntity payment;
  final CustomerDebtsViewModel debtsViewModel;
  final String customerName;

  const EditCustomerPaymentBottomSheet({
    super.key,
    required this.payment,
    required this.debtsViewModel,
    this.customerName = '',
  });

  static Future<bool?> show({
    required BuildContext context,
    required CustomerPaymentEntity payment,
    required CustomerDebtsViewModel debtsViewModel,
    String customerName = '',
  }) {
    return AppBottomSheet.show<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditCustomerPaymentBottomSheet(
        payment: payment,
        debtsViewModel: debtsViewModel,
        customerName: customerName,
      ),
    );
  }

  @override
  State<EditCustomerPaymentBottomSheet> createState() => _EditCustomerPaymentBottomSheetState();
}

class _EditCustomerPaymentBottomSheetState extends State<EditCustomerPaymentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late PaymentMethod _selectedPaymentMethod;
  bool _isLoading = false;
  bool _isFullyExpanded = true;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: CurrencyInputFormatter.formatDouble(widget.payment.amount),
    );
    _notesController = TextEditingController(text: widget.payment.notes);
    _selectedPaymentMethod = widget.payment.paymentMethod;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _getParsedAmount() {
    final cleanText = _amountController.text.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(cleanText) ?? 0.0;
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _getParsedAmount();
    if (amount <= 0) {
      AppSnackbar.warning(context, 'Informe um valor maior que zero.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedPayment = widget.payment.copyWith(
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        notes: _notesController.text.trim(),
      );

      await widget.debtsViewModel.updatePayment(updatedPayment);

      if (mounted) {
        Navigator.pop(context, true);
        AppSnackbar.success(
          context,
          'Pagamento atualizado com sucesso!',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.error(context, 'Erro ao atualizar pagamento: $e');
      }
    }
  }

  void _confirmCancelPayment() async {
    final reason = await AppDialog.show<String>(
      context: context,
      builder: (ctx) => _CancelPaymentDialog(amount: widget.payment.amount),
    );

    if (reason == null || reason.trim().isEmpty || !mounted) return;

    setState(() => _isLoading = true);

    try {
      await widget.debtsViewModel.cancelPayment(
        widget.payment.id,
        reason: reason.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        AppSnackbar.success(
          context,
          'Pagamento cancelado com sucesso. O valor retornou para a dívida.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.error(context, 'Erro ao cancelar pagamento: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = widget.payment.isCancelled;
    final availableMethods = [
      PaymentMethod.dinheiro,
      PaymentMethod.pix,
      PaymentMethod.debito,
      PaymentMethod.credito,
    ];

    final day = widget.payment.createdAt.day.toString().padLeft(2, '0');
    final month = widget.payment.createdAt.month.toString().padLeft(2, '0');
    final year = widget.payment.createdAt.year;
    final hour = widget.payment.createdAt.hour.toString().padLeft(2, '0');
    final minute = widget.payment.createdAt.minute.toString().padLeft(2, '0');
    final formattedDate = '$day/$month/$year às $hour:$minute';

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        final isFullyExpanded = notification.extent >= 0.99;
        if (_isFullyExpanded != isFullyExpanded) {
          setState(() {
            _isFullyExpanded = isFullyExpanded;
          });
        }
        return false;
      },
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 1.0,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return SafeArea(
            top: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Fixo no Topo
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.space16,
                    right: AppSpacing.space16,
                    top: _isFullyExpanded ? AppSpacing.appBarHeight : AppSpacing.space12,
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: context.colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Gap(AppSpacing.space12),

                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isCancelled ? 'Detalhes do Pagamento' : 'Editar Pagamento',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CloseButton(onPressed: () => Navigator.pop(context, false)),
                        ],
                      ),
                      const Gap(AppSpacing.space8),
                      const Divider(),
                    ],
                  ),
                ),

                // Corpo com Scroll
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: AppSpacing.space16,
                      right: AppSpacing.space16,
                      top: AppSpacing.space8,
                      bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.space24,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card de Informações
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.space12),
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppSpacing.radius12),
                              border: Border.all(
                                color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.space8),
                                      decoration: BoxDecoration(
                                        color: (isCancelled ? AppColors.error : AppColors.success).withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(AppSpacing.radius8),
                                      ),
                                      child: Icon(
                                        isCancelled ? AppIcons.block : AppIcons.checkCircle,
                                        color: isCancelled ? AppColors.error : AppColors.success,
                                        size: AppSpacing.icon24,
                                      ),
                                    ),
                                    const Gap(AppSpacing.space12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.customerName.isNotEmpty
                                                ? widget.customerName
                                                : widget.payment.customerName,
                                            style: context.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Registrado em $formattedDate',
                                            style: context.textTheme.bodySmall?.copyWith(
                                              color: context.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isCancelled)
                                      const AppTag(
                                        title: 'Cancelado',
                                        color: AppColors.error,
                                        icon: AppIcons.block,
                                      ),
                                  ],
                                ),
                                const Gap(AppSpacing.space8),
                                const Divider(),
                                const Gap(AppSpacing.space4),
                                Row(
                                  children: [
                                    Icon(
                                      AppIcons.shieldPerson,
                                      size: AppSpacing.icon16,
                                      color: context.colorScheme.onSurfaceVariant,
                                    ),
                                    const Gap(AppSpacing.space8),
                                    Text(
                                      'Operador: ${widget.payment.userName.isNotEmpty ? widget.payment.userName : "Operador"}',
                                      style: context.textTheme.bodySmall?.copyWith(
                                        color: context.colorScheme.onSurfaceVariant,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          if (isCancelled) ...[
                            const Gap(AppSpacing.space16),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.space12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSpacing.radius12),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(AppIcons.warning, color: AppColors.error, size: AppSpacing.icon20),
                                      const Gap(AppSpacing.space8),
                                      Expanded(
                                        child: Text(
                                          'Este pagamento foi cancelado. O valor de ${CurrencyInputFormatter.formatCurrency(widget.payment.amount)} foi estornado para a dívida do cliente.',
                                          style: context.textTheme.bodySmall?.copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (widget.payment.cancellationReason != null &&
                                      widget.payment.cancellationReason!.isNotEmpty) ...[
                                    const Gap(AppSpacing.space8),
                                    const Divider(),
                                    const Gap(AppSpacing.space4),
                                    Text(
                                      'Motivo do cancelamento:',
                                      style: context.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                      ),
                                    ),
                                    const Gap(2),
                                    Text(
                                      widget.payment.cancellationReason!,
                                      style: context.textTheme.bodySmall?.copyWith(
                                        color: context.colorScheme.onSurface,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ] else ...[
                            const Gap(AppSpacing.space16),

                            // Campo de Valor Pago
                            Text(
                              'Valor do Pagamento',
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(AppSpacing.space8),
                            AppTextfield(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [CurrencyInputFormatter(includeSymbol: false)],
                              prefixText: 'R\$ ',
                              hint: '0,00',
                              validator: (value) {
                                final parsed = _getParsedAmount();
                                if (parsed <= 0) {
                                  return 'Informe um valor válido maior que zero';
                                }
                                return null;
                              },
                            ),

                            const Gap(AppSpacing.space16),

                            // Forma de Pagamento
                            Text(
                              'Forma de Pagamento',
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(AppSpacing.space8),
                            Wrap(
                              spacing: AppSpacing.space8,
                              runSpacing: AppSpacing.space4,
                              children: availableMethods.map((method) {
                                final isSelected = _selectedPaymentMethod == method;
                                return ChoiceChip(
                                  label: Text(method.label),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _selectedPaymentMethod = method);
                                    }
                                  },
                                  selectedColor: context.colorScheme.primary.withValues(alpha: 0.2),
                                  labelStyle: TextStyle(
                                    color: isSelected ? context.colorScheme.primary : context.colorScheme.onSurface,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                );
                              }).toList(),
                            ),

                            const Gap(AppSpacing.space16),

                            // Observações
                            Text(
                              'Observações (Opcional)',
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(AppSpacing.space8),
                            AppTextfield(
                              controller: _notesController,
                              hint: 'Ex: Pagamento referente à venda de sábado...',
                              maxLines: 2,
                            ),

                            const Gap(AppSpacing.space24),

                            // Botão Salvar Alterações
                            AppButton(
                              label: 'Salvar Alterações',
                              icon: AppIcons.check,
                              isLoading: _isLoading,
                              isFullWidth: true,
                              onPressed: _saveChanges,
                            ),

                            const Gap(AppSpacing.space12),

                            // Botão Cancelar Pagamento
                            AppButton.outlined(
                              label: 'Cancelar Pagamento',
                              icon: AppIcons.block,
                              isFullWidth: true,
                              onPressed: _isLoading ? null : _confirmCancelPayment,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CancelPaymentDialog extends StatefulWidget {
  final double amount;

  const _CancelPaymentDialog({required this.amount});

  @override
  State<_CancelPaymentDialog> createState() => _CancelPaymentDialogState();
}

class _CancelPaymentDialogState extends State<_CancelPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadius24,
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space20,
        vertical: AppSpacing.space48,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.widthOf(context)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cancelar Pagamento?',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(AppSpacing.space12),
                Text(
                  'Tem certeza que deseja cancelar este pagamento de ${CurrencyInputFormatter.formatCurrency(widget.amount)}?\n\n'
                  'O valor voltará para a dívida do cliente e o cancelamento ficará registrado no histórico.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(AppSpacing.space16),
                Text(
                  'Motivo do Cancelamento *',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(AppSpacing.space8),
                AppTextfield(
                  controller: _reasonController,
                  hint: 'Ex: Lançamento em duplicidade, estorno...',
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o motivo do cancelamento.';
                    }
                    return null;
                  },
                ),
                const Gap(AppSpacing.space20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: AppSpacing.space40,
                      child: AppButton.text(
                        onPressed: () => Navigator.pop(context),
                        label: 'Voltar',
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                      ),
                    ),
                    const Gap(AppSpacing.space8),
                    SizedBox(
                      height: AppSpacing.space40,
                      child: AppButton.text(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context, _reasonController.text.trim());
                          }
                        },
                        label: 'Confirmar Cancelamento',
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                        textStyle: context.textTheme.bodyLarge?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
