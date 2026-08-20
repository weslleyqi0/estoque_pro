import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
            AppNetworkImage(
              imageUrl: product.imgUrl,
              size: 130,
              placeholderIcon: AppIcons.image,
              isGrayscale: !product.isActive,
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
                      CurrencyInputFormatter.formatCurrency(product.price),
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
