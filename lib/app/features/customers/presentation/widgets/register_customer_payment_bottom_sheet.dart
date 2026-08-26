import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class RegisterCustomerPaymentBottomSheet extends StatefulWidget {
  final CustomerEntity customer;
  final double currentDebt;
  final CustomerDebtsViewModel debtsViewModel;
  final AuthViewModel authViewModel;

  const RegisterCustomerPaymentBottomSheet({
    super.key,
    required this.customer,
    required this.currentDebt,
    required this.debtsViewModel,
    required this.authViewModel,
  });

  static Future<bool?> show({
    required BuildContext context,
    required CustomerEntity customer,
    required double currentDebt,
    required CustomerDebtsViewModel debtsViewModel,
    required AuthViewModel authViewModel,
  }) {
    return AppBottomSheet.show<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RegisterCustomerPaymentBottomSheet(
        customer: customer,
        currentDebt: currentDebt,
        debtsViewModel: debtsViewModel,
        authViewModel: authViewModel,
      ),
    );
  }

  @override
  State<RegisterCustomerPaymentBottomSheet> createState() => _RegisterCustomerPaymentBottomSheetState();
}

class _RegisterCustomerPaymentBottomSheetState extends State<RegisterCustomerPaymentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.dinheiro;
  bool _isLoading = false;
  bool _isFullyExpanded = true;

  @override
  void initState() {
    super.initState();
    // Inicia com o valor total da dívida pré-preenchido
    if (widget.currentDebt > 0) {
      _amountController.text = CurrencyInputFormatter.formatDouble(widget.currentDebt);
    }
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

  void _payFullAmount() {
    setState(() {
      _amountController.text = CurrencyInputFormatter.formatDouble(widget.currentDebt);
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _getParsedAmount();
    if (amount <= 0) {
      AppSnackbar.warning(context, 'Informe um valor maior que zero.');
      return;
    }

    final currentUser = widget.authViewModel.currentUser;
    final userId = currentUser?.uid ?? '';
    final userName = currentUser?.name ?? 'Operador';

    setState(() => _isLoading = true);

    try {
      await widget.debtsViewModel.registerPayment(
        customerId: widget.customer.id,
        customerName: widget.customer.name,
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        notes: _notesController.text,
        userId: userId,
        userName: userName,
      );

      if (mounted) {
        Navigator.pop(context, true);
        AppSnackbar.success(
          context,
          'Pagamento de ${CurrencyInputFormatter.formatCurrency(amount)} registrado com sucesso!',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.error(context, 'Erro ao registrar pagamento: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableMethods = [
      PaymentMethod.dinheiro,
      PaymentMethod.pix,
      PaymentMethod.debito,
      PaymentMethod.credito,
    ];

    final currentUser = widget.authViewModel.currentUser;

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
                // Header Fixo
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
                            'Registrar Pagamento',
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
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Info Card: Cliente & Dívida Atual
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.space12),
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppSpacing.radius12),
                              border: Border.all(
                                color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.space8),
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppSpacing.radius8),
                                  ),
                                  child: Icon(
                                    AppIcons.person,
                                    color: context.colorScheme.primary,
                                    size: AppSpacing.icon24,
                                  ),
                                ),
                                const Gap(AppSpacing.space12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.customer.name,
                                        style: context.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Débito atual: ${CurrencyInputFormatter.formatCurrency(widget.currentDebt)}',
                                        style: context.textTheme.bodySmall?.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.currentDebt > 0)
                                  TextButton.icon(
                                    onPressed: _payFullAmount,
                                    icon: const Icon(AppIcons.checkCircle, size: AppSpacing.icon16),
                                    label: const Text('Total'),
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const Gap(AppSpacing.space16),

                          // Campo de Valor Pago
                          Text(
                            'Valor a Abater / Pagar',
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

                          const Gap(AppSpacing.space12),

                          // Identificação do Operador
                          Row(
                            children: [
                              Icon(
                                AppIcons.shieldPerson,
                                size: AppSpacing.icon16,
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              const Gap(AppSpacing.space8),
                              Text(
                                'Registrado por: ${currentUser?.name ?? "Operador atual"}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),

                          const Gap(AppSpacing.space24),

                          // Botão Confirmar
                          AppButton(
                            label: 'Confirmar Pagamento',
                            icon: AppIcons.check,
                            isLoading: _isLoading,
                            onPressed: _submit,
                          ),
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
