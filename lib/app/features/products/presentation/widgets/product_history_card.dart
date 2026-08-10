import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/product_history_item.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProductHistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ProductHistoryEntity> history;
  final VoidCallback? onViewAll;
  final bool showEmptyMessage;

  const ProductHistoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.history,
    this.onViewAll,
    this.showEmptyMessage = false,
  });

  @override
  Widget build(BuildContext context) {
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
                    color: context.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                  child: Icon(
                    AppIcons.history,
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
                      title,
                      style: context.textTheme.titleMedium,
                    ),
                    Text(
                      subtitle,
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

          if (history.isEmpty && showEmptyMessage) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space48, horizontal: AppSpacing.space24),
              child: Column(
                children: [
                  Icon(
                    AppIcons.history,
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

          for (int i = 0; i < history.length; i++)
            ProductHistoryItem(
              history: history[i],
              isLast: i == history.length - 1,
            ),

          if (onViewAll != null) ...[
            InkWell(
              onTap: onViewAll,
              overlayColor: WidgetStatePropertyAll(context.colorScheme.primary.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSpacing.radius16),
                bottomRight: Radius.circular(AppSpacing.radius16),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.space20),
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    top: BorderSide(color: context.colorScheme.outline, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ver todas as movimentações',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
