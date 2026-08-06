import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_form_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/stock_adjustment_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late final ProductsViewModel _viewModel;
  late final ProductsFormViewModel _formViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProductsViewModel>();
    _formViewModel = getIt<ProductsFormViewModel>();
  }

  ProductEntity get _currentProduct {
    return _viewModel.products.firstWhere(
      (p) => p.id == widget.product.id,
      orElse: () => widget.product,
    );
  }

  Future<void> _adjustStock(ProductHistoryAction action, int quantity, String note) async {
    final product = _currentProduct;

    int newStock = product.stock;
    if (action == ProductHistoryAction.add) {
      newStock += quantity;
    } else {
      newStock = (newStock - quantity).clamp(0, 999999);
    }

    final currentUser = getIt<AuthViewModel>().currentUser;

    final newHistory = [
      ProductHistoryEntity(
        action: action,
        quantity: quantity,
        date: DateTime.now(),
        note: note,
        userName: currentUser?.name,
      ),
      ...product.history,
    ];

    final updatedProduct = product.copyWith(
      stock: newStock,
      isActive: newStock == 0 ? false : product.isActive,
      history: newHistory,
      updatedAt: DateTime.now(),
    );

    await _formViewModel.updateProductCommand.execute(updatedProduct);
  }

  Future<void> _adjustStatus(bool isActive) async {
    final product = _currentProduct;
    if (product.stock == 0 && isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não é possível ativar um produto sem estoque.')),
      );
      return;
    }

    final updatedProduct = product.copyWith(
      isActive: isActive,
      updatedAt: DateTime.now(),
    );

    await _formViewModel.updateProductCommand.execute(updatedProduct);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final product = _currentProduct;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes do Produto'),
            actions: [
              AppIconButton(
                icon: Symbols.edit_rounded,
                //backgroundColor: context.colorScheme.primaryContainer.withValues(alpha: 0.2),
                onPressed: () => context.push(AppRoutes.productForm, extra: product),
              ),
              const Gap(AppSpacing.space8),
            ],
          ),
          floatingActionButton: AppFloatingActionButton(
            tooltip: 'Ajustar Estoque',
            icon: Symbols.inventory_rounded,
            onPressed: () {
              StockAdjustmentBottomSheet.show(context, product, _adjustStock);
            },
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.space16),
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
                        mainAxisAlignment: .spaceBetween,
                        crossAxisAlignment: .start,
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

              // Descrição
              if (product.description.isNotEmpty) ...[
                Text('Descrição', style: context.textTheme.titleMedium),
                const Gap(AppSpacing.space8),
                Text(product.description, style: context.textTheme.bodyMedium),
                const Gap(AppSpacing.space24),
              ],

              AppSwitchTitle(
                title: 'Produto Ativo',
                subtitle: 'Disponível para venda',
                value: product.isActive,
                onChanged: _adjustStatus,
              ),
              const Gap(AppSpacing.space24),

              // Informações do Produto
              Card(
                elevation: 0,
                color: context.colorScheme.surfaceContainerLow,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    children: [
                      _buildInfoRow(context, 'Código de Barras', product.barcode.isEmpty ? '-' : product.barcode),
                      const Gap(AppSpacing.space12),
                      _buildInfoRow(
                        context,
                        'Estoque Atual',
                        '${product.stock} un.',
                        isWarning: product.stock < product.minStock,
                      ),
                      const Gap(AppSpacing.space12),
                      _buildInfoRow(context, 'Estoque Mínimo', '${product.minStock} un.'),
                      const Gap(AppSpacing.space12),
                      _buildInfoRow(
                        context,
                        'Categorias',
                        product.categories.isEmpty ? '-' : product.categories.map((c) => c.name).join(', '),
                      ),
                      const Gap(AppSpacing.space12),
                      _buildInfoRow(context, 'Fornecedor', product.supplier?.name ?? '-'),
                      if (product.updatedAt != null) ...[
                        const Gap(AppSpacing.space12),
                        _buildInfoRow(
                          context,
                          'Última Atualização',
                          DateFormat('dd/MM/yyyy HH:mm').format(product.updatedAt!),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Gap(AppSpacing.space32),

              // Histórico
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Histórico de Movimentações', style: context.textTheme.titleMedium),
                  if (product.history.isNotEmpty)
                    TextButton(
                      //onPressed: () => context.push(AppRoutes.productHistory, extra: product),
                      onPressed: () {},
                      child: const Text('Ver Todos'),
                    ),
                ],
              ),
              const Gap(AppSpacing.space8),

              if (product.history.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.space32),
                    child: Text('Nenhuma movimentação registrada.'),
                  ),
                )
              else
                Builder(
                  builder: (context) {
                    final sortedHistory = List.from(product.history)..sort((a, b) => b.date.compareTo(a.date));

                    return Column(
                      children: sortedHistory.take(5).map<Widget>((h) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.space8),
                          elevation: 0,
                          color: context.colorScheme.surfaceContainerLowest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: context.colorScheme.outlineVariant),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: h.action == ProductHistoryAction.add
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                h.action == ProductHistoryAction.add
                                    ? Symbols.arrow_upward_rounded
                                    : Symbols.arrow_downward_rounded,
                                color: h.action == ProductHistoryAction.add ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              '${h.action == ProductHistoryAction.add ? "Entrada" : "Saída"} de ${h.quantity} un.',
                              style: context.textTheme.titleSmall,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm').format(h.date),
                                      style: context.textTheme.labelMedium?.copyWith(
                                        color: context.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    if (h.userName != null && h.userName!.isNotEmpty) ...[
                                      const Gap(AppSpacing.space8),
                                      Icon(
                                        Symbols.person_rounded,
                                        size: 14,
                                        color: context.colorScheme.onSurfaceVariant,
                                      ),
                                      const Gap(AppSpacing.space4),
                                      Text(
                                        h.userName!,
                                        style: context.textTheme.labelMedium?.copyWith(
                                          color: context.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (h.note.isNotEmpty) ...[
                                  const Gap(AppSpacing.space4),
                                  Text(
                                    h.note,
                                    style: context.textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

              const Gap(AppSpacing.space56), // Espaço pro FAB
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isWarning = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(AppSpacing.space16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: context.textTheme.titleSmall?.copyWith(
              color: isWarning ? context.colorScheme.error : null,
              fontWeight: isWarning ? FontWeight.bold : null,
            ),
          ),
        ),
      ],
    );
  }
}
