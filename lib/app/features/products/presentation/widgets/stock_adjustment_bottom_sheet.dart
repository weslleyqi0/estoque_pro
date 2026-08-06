import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

class StockAdjustmentBottomSheet extends StatefulWidget {
  final ProductEntity product;
  final Function(ProductHistoryAction action, int quantity, String note) onConfirm;

  const StockAdjustmentBottomSheet({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context,
    ProductEntity product,
    Function(ProductHistoryAction action, int quantity, String note) onConfirm,
  ) {
    return AppBottomSheet.show(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StockAdjustmentBottomSheet(product: product, onConfirm: onConfirm),
      ),
    );
  }

  @override
  State<StockAdjustmentBottomSheet> createState() => _StockAdjustmentBottomSheetState();
}

class _StockAdjustmentBottomSheetState extends State<StockAdjustmentBottomSheet> {
  int _adjustQty = 0;
  final _noteController = TextEditingController();

  void _increment() {
    setState(() {
      _adjustQty++;
    });
  }

  void _decrement() {
    setState(() {
      if (widget.product.stock + _adjustQty > 0) {
        _adjustQty--;
      }
    });
  }

  void _confirm() {
    if (_adjustQty == 0) {
      Navigator.pop(context);
      return;
    }

    final action = _adjustQty > 0 ? ProductHistoryAction.add : ProductHistoryAction.remove;
    widget.onConfirm(action, _adjustQty.abs(), _noteController.text.trim());
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ajustar Estoque',
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.space8),
            Text(
              'Estoque atual: ${widget.product.stock}',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.space32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: _decrement,
                  icon: const Icon(Symbols.remove_rounded),
                  iconSize: 32,
                  padding: const EdgeInsets.all(AppSpacing.space12),
                ),
                const Gap(AppSpacing.space24),
                SizedBox(
                  width: 100,
                  child: Text(
                    _adjustQty > 0 ? '+ $_adjustQty' : (_adjustQty < 0 ? '- ${_adjustQty.abs()}' : '0'),
                    style: context.textTheme.displaySmall?.copyWith(
                      color: _adjustQty > 0
                          ? Colors.green
                          : (_adjustQty < 0 ? context.colorScheme.error : context.colorScheme.onSurface),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Gap(AppSpacing.space24),
                IconButton.filledTonal(
                  onPressed: _increment,
                  icon: const Icon(Symbols.add_rounded),
                  iconSize: 32,
                  padding: const EdgeInsets.all(AppSpacing.space12),
                ),
              ],
            ),
            const Gap(AppSpacing.space32),
            AppTextfield(
              label: 'Motivo (Opcional)',
              hint: 'Ex: Contagem de estoque, perda, etc.',
              controller: _noteController,
            ),
            const Gap(AppSpacing.space32),
            Row(
              children: [
                Expanded(
                  child: AppButton.text(
                    label: 'Cancelar',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Gap(AppSpacing.space16),
                Expanded(
                  child: AppButton.primary(
                    label: 'Confirmar',
                    onPressed: _adjustQty != 0 ? _confirm : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
