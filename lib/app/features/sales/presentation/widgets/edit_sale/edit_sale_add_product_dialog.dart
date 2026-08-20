import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';

class EditSaleAddProductDialog extends StatelessWidget {
  final List<ProductEntity> products;
  final ValueChanged<ProductEntity> onSelectProduct;

  const EditSaleAddProductDialog({
    super.key,
    required this.products,
    required this.onSelectProduct,
  });

  static Future<void> show({
    required BuildContext context,
    required List<ProductEntity> products,
    required ValueChanged<ProductEntity> onSelectProduct,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.94,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => EditSaleAddProductDialog(
          products: products,
          onSelectProduct: onSelectProduct,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Adicionar Produto',
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, index) {
              final product = products[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: product.imgUrl.isNotEmpty ? NetworkImage(product.imgUrl) : null,
                  child: product.imgUrl.isEmpty ? const Icon(Icons.inventory_2_outlined) : null,
                ),
                title: Text(product.name),
                subtitle: Text(
                  'Estoque: ${product.stock} • ${CurrencyInputFormatter.formatCurrency(product.price)}',
                ),
                onTap: () => onSelectProduct(product),
              );
            },
          ),
        ),
      ],
    );
  }
}
