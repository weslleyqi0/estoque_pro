import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/info_row.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ProductInfoCard extends StatelessWidget {
  final ProductEntity product;
  final double rawProgress;
  final Color statusColor;

  const ProductInfoCard({
    super.key,
    required this.product,
    required this.rawProgress,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informações do Produto', style: context.textTheme.titleMedium),
        const Gap(AppSpacing.space8),
        Card(
          color: context.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadius16,
            side: BorderSide(color: context.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: Column(
              children: [
                InfoRow(
                  label: 'Código de Barras',
                  value: product.barcode.isEmpty ? '-' : product.barcode,
                ),
                const Gap(AppSpacing.space12),
                InfoRow(
                  label: 'Estoque Atual',
                  value: '${product.stock} un.',
                  warningColor: rawProgress < 0.50 ? statusColor : null,
                ),
                const Gap(AppSpacing.space12),
                InfoRow(
                  label: 'Estoque Mínimo',
                  value: '${product.minStock} un.',
                ),
                const Gap(AppSpacing.space12),
                InfoRow(
                  label: 'Categorias',
                  value: product.categories.isEmpty ? '-' : product.categories.map((c) => c.name).join(', '),
                ),
                const Gap(AppSpacing.space12),
                InfoRow(
                  label: 'Fornecedor',
                  value: product.supplier?.name ?? '-',
                ),
                if (product.updatedAt != null) ...[
                  const Gap(AppSpacing.space12),
                  InfoRow(
                    label: 'Última Atualização',
                    value: DateFormat('dd/MM/yyyy HH:mm').format(product.updatedAt!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
