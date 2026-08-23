import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/discount_type.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/cart_summary_widget.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/discount_option_card.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/payment_method_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class PaymentSheet extends StatefulWidget {
  final CartViewModel cartViewModel;
  final AuthViewModel authViewModel;
  final List<ProductEntity> availableProducts;
  final VoidCallback onSaleSuccess;

  const PaymentSheet({
    super.key,
    required this.cartViewModel,
    required this.authViewModel,
    required this.availableProducts,
    required this.onSaleSuccess,
  });

  static Future<void> show({
    required BuildContext context,
    required CartViewModel cartViewModel,
    required AuthViewModel authViewModel,
    required List<ProductEntity> availableProducts,
    required VoidCallback onSaleSuccess,
  }) {
    return AppBottomSheet.show(
      context: context,
      builder: (_) => PaymentSheet(
        cartViewModel: cartViewModel,
        authViewModel: authViewModel,
        availableProducts: availableProducts,
        onSaleSuccess: onSaleSuccess,
      ),
    );
  }

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  final _discountController = TextEditingController();
  final _amountPaidController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.cartViewModel.discountValue > 0) {
      if (widget.cartViewModel.discountType == DiscountType.percent) {
        final val = widget.cartViewModel.discountValue;
        _discountController.text = val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
      } else {
        _discountController.text = CurrencyInputFormatter.formatCurrency(widget.cartViewModel.discountValue);
      }
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    _amountPaidController.dispose();
    super.dispose();
  }

  void _handleConfirm() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = widget.authViewModel.currentUser;

      if (currentUser == null) {
        throw Exception('Usuário não autenticado.');
      }

      await widget.cartViewModel.executeFinalize(
        userId: currentUser.uid,
        userName: currentUser.name,
        availableProducts: widget.availableProducts,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSaleSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.error(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.cartViewModel;

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final isCash = vm.paymentMethod == .dinheiro;
        final isFiado = vm.paymentMethod == .fiado;
        final canConfirm = vm.paymentMethod != null && (!isCash || vm.change >= 0);

        return SafeArea(
          top: true,
          bottom: false,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height - AppSpacing.space56,
            ),
            padding: .only(
              left: AppSpacing.space16,
              right: AppSpacing.space16,
              top: AppSpacing.space16,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.space24,
            ),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
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
                Row(
                  mainAxisAlignment: .spaceBetween,
                  crossAxisAlignment: .start,
                  children: [
                    Column(
                      crossAxisAlignment: .start,
                      children: [
                        const Gap(AppSpacing.space16),
                        Text(
                          'Finalizar Venda ',
                          style: context.textTheme.titleLarge?.copyWith(fontWeight: .bold),
                        ),
                        Text(
                          vm.saleNumber,
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    CloseButton(
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.space16),
                  child: Divider(),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          'Forma de Pagamento',
                          style: context.textTheme.titleMedium?.copyWith(fontWeight: .bold),
                        ),
                        const Gap(AppSpacing.space8),
                        Center(
                          child: Wrap(
                            spacing: AppSpacing.space8,
                            runSpacing: AppSpacing.space8,
                            children: PaymentMethod.values.map((method) {
                              final isSelected = vm.paymentMethod == method;
                              return PaymentMethodCard(
                                method: method,
                                isSelected: isSelected,
                                onTap: () {
                                  vm.setPaymentMethod(method);
                                  if (method == PaymentMethod.fiado) {
                                    _discountController.clear();
                                    vm.setDiscount(DiscountType.valueAmount, 0.0);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const Gap(AppSpacing.space16),

                        // 1.1 Dinheiro -> Valor recebido & Troco
                        if (isCash) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainerLow,
                              borderRadius: .circular(AppSpacing.radius12),
                            ),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                AppTextfield(
                                  controller: _amountPaidController,
                                  label: 'Valor Recebido',
                                  hint: 'R\$ 0,00',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [CurrencyInputFormatter()],
                                  onChanged: (val) {
                                    final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                                    final doubleVal = digits.isEmpty ? 0.0 : (double.parse(digits) / 100);
                                    vm.setAmountPaid(doubleVal);
                                  },
                                ),
                                const Gap(AppSpacing.space8),
                                Row(
                                  mainAxisAlignment: .spaceBetween,
                                  children: [
                                    Text(
                                      'Troco:',
                                      style: context.textTheme.titleMedium?.copyWith(fontWeight: .bold),
                                    ),
                                    Text(
                                      CurrencyInputFormatter.formatCurrency(vm.change.clamp(0.0, double.infinity)),
                                      style: context.textTheme.titleLarge?.copyWith(
                                        color: vm.change < 0 ? AppColors.error : Colors.green,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (vm.change < 0)
                                  Padding(
                                    padding: const .only(top: 4),
                                    child: Text(
                                      'Falta ${CurrencyInputFormatter.formatCurrency(vm.change.abs())} para completar o total.',
                                      style: context.textTheme.bodySmall?.copyWith(color: AppColors.error),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Gap(AppSpacing.space16),
                        ],

                        if (!isFiado) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: AppTextfield(
                                  controller: _discountController,
                                  label: 'Desconto',
                                  suffixText: vm.discountType == DiscountType.percent ? ' %' : null,
                                  hint: vm.discountType == DiscountType.valueAmount ? 'R\$ 0,00' : '0',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: vm.discountType == DiscountType.valueAmount
                                      ? [CurrencyInputFormatter()]
                                      : [FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*'))],
                                  onChanged: (val) {
                                    if (vm.discountType == DiscountType.valueAmount) {
                                      final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                                      final parsed = digits.isEmpty ? 0.0 : (double.parse(digits) / 100);
                                      vm.setDiscount(vm.discountType, parsed);
                                    } else {
                                      final parsed = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                                      vm.setDiscount(vm.discountType, parsed);
                                    }
                                  },
                                ),
                              ),
                              const Gap(AppSpacing.space8),
                              DiscountOptionCard(
                                label: 'R\$',
                                isSelected: vm.discountType == DiscountType.valueAmount,
                                onTap: () {
                                  final digits = _discountController.text.replaceAll(RegExp(r'[^0-9]'), '');
                                  final parsed = digits.isEmpty ? 0.0 : (double.parse(digits) / 100);
                                  _discountController.text =
                                      parsed > 0 ? CurrencyInputFormatter.formatCurrency(parsed) : '';
                                  vm.setDiscount(DiscountType.valueAmount, parsed);
                                },
                              ),
                              const Gap(AppSpacing.space8),
                              DiscountOptionCard(
                                label: '%',
                                isSelected: vm.discountType == DiscountType.percent,
                                onTap: () {
                                  final digits = _discountController.text.replaceAll(RegExp(r'[^0-9]'), '');
                                  final parsed = digits.isEmpty ? 0.0 : (double.parse(digits) / 100);
                                  _discountController.text = parsed > 0
                                      ? (parsed % 1 == 0 ? parsed.toInt().toString() : parsed.toStringAsFixed(1))
                                      : '';
                                  vm.setDiscount(DiscountType.percent, parsed);
                                },
                              ),
                            ],
                          ),
                          const Gap(AppSpacing.space16),
                        ],
                      ],
                    ),
                  ),
                ),

                const Gap(AppSpacing.space12),
                CartSummaryWidget(
                  subtotal: vm.subtotal,
                  discount: vm.calculatedDiscount,
                  total: vm.total,
                ),
                const Gap(AppSpacing.space16),

                AppButton(
                  label: _isLoading ? 'Finalizando...' : 'Confirmar Venda',
                  isFullWidth: true,
                  onPressed: canConfirm && !_isLoading ? _handleConfirm : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
