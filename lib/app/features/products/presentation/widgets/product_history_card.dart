import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_history_item.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProductHistoryCard extends StatelessWidget {
  final ProductEntity product;

  const ProductHistoryCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final sortedHistory = List.from(product.history)..sort((a, b) => b.date.compareTo(a.date));

    return Card(
      color: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadius16,
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16, horizontal: AppSpacing.space12),
            decoration: BoxDecoration(
              border: BorderDirectional(
                bottom: BorderSide(color: context.colorScheme.outline, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space12),
                  decoration: BoxDecoration(
                    borderRadius: AppSpacing.borderRadius16,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Symbols.history_rounded,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                    size: AppSpacing.icon24,
                    weight: 900,
                  ),
                ),
                const Gap(AppSpacing.space12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Histórico de Movimentações',
                      style: context.textTheme.titleMedium,
                    ),
                    Text(
                      '${sortedHistory.length} registro(s)',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.space4),

          if (sortedHistory.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space48, horizontal: AppSpacing.space24),
              child: Column(
                children: [
                  Icon(
                    Symbols.history_rounded,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                    size: AppSpacing.icon40,
                    weight: 400,
                  ),
                  Text(
                    'Nenhuma movimentação registrada.',
                    style: context.textTheme.bodyLarge,
                  ),
                  const Gap(AppSpacing.space4),
                  Text(
                    'As movimentações aparecerão aqui após\nvendas ou ajustes de estoque',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],

          ...sortedHistory.take(5).map((h) {
            return ProductHistoryItem(history: h);
          }),

          if (sortedHistory.isNotEmpty && sortedHistory.length > 5) ...[
            InkWell(
              onTap: () {},
              overlayColor: WidgetStatePropertyAll(context.colorScheme.primary.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSpacing.radius16),
                bottomRight: Radius.circular(AppSpacing.radius16),
              ),
              child: Row(
                mainAxisAlignment: .center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.space20, horizontal: AppSpacing.space12),
                    child: Text(
                      'Ver todas as movimentações',
                      style: context.textTheme.titleMedium?.copyWith(color: context.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
