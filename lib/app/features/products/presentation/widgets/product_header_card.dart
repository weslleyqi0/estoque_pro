import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProductHeaderCard extends StatelessWidget {
  final ProductEntity product;

  const ProductHeaderCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.space16),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: AppSpacing.borderRadius16,
                border: Border.all(color: context.colorScheme.outline, width: 1),
              ),
              clipBehavior: Clip.hardEdge,
              child: product.imgUrl.isNotEmpty
                  ? Image.network(
                      product.imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Symbols.broken_image_rounded, size: 48),
                      ),
                    )
                  : const Center(
                      child: Icon(Symbols.image_rounded, size: 48),
                    ),
            ),
            const Gap(AppSpacing.space12),
            Expanded(
              child: SizedBox(
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: context.textTheme.titleLarge?.copyWith(),
                    ),
                    Text(
                      'R\$ ${product.price.toStringAsFixed(2)}',
                      style: context.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.space16),
        if (product.description.isNotEmpty) ...[
          Text('Descrição', style: context.textTheme.titleMedium),
          const Gap(AppSpacing.space8),
          Text(product.description, style: context.textTheme.bodyMedium),
          const Gap(AppSpacing.space16),
        ],
      ],
    );
  }
}
