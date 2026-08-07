import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_history_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_form_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/info_row.dart';
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

        final maxProgress = product.minStock > 0 ? (product.minStock * 2).toDouble() : 10.0;
        final rawProgress = maxProgress > 0 ? product.stock / maxProgress : 0.0;

        final Color statusColor;
        final IconData statusIcon;
        final String statusText;

        if (rawProgress <= 0.0) {
          statusColor = AppColors.error;
          statusIcon = Symbols.error_rounded;
          statusText = 'Sem Estoque';
        } else if (rawProgress < 0.25) {
          statusColor = AppColors.error;
          statusIcon = Symbols.info_rounded;
          statusText = 'Estoque Crítico';
        } else if (rawProgress < 0.50) {
          statusColor = AppColors.warning;
          statusIcon = Symbols.info_rounded;
          statusText = 'Estoque Baixo';
        } else {
          statusColor = AppColors.success;
          statusIcon = Symbols.check_circle_rounded;
          statusText = 'Estoque OK';
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes do Produto'),
            actions: [
              AppIconButton(
                icon: Symbols.edit_rounded,
                onPressed: () => context.push(AppRoutes.productForm, extra: product),
              ),
              const Gap(AppSpacing.space8),
            ],
          ),
          body: ListView(
            padding: const .all(AppSpacing.space16),
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
                const Gap(AppSpacing.space16),
              ],

              // Status do Produto
              Text('Status do Produto', style: context.textTheme.titleMedium),
              const Gap(AppSpacing.space8),
              Card(
                color: context.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadius16,
                  side: BorderSide(color: context.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const .all(AppSpacing.space12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.space12),
                        decoration: BoxDecoration(
                          borderRadius: AppSpacing.borderRadius12,
                          color: product.isActive
                              ? AppColors.success.withValues(alpha: 0.1)
                              : context.colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          Symbols.power_settings_new_rounded,
                          color: product.isActive
                              ? AppColors.success
                              : context.colorScheme.onSurface.withValues(alpha: 0.5),
                          size: AppSpacing.icon32,
                          weight: 900,
                        ),
                      ),
                      const Gap(AppSpacing.space12),
                      Flexible(
                        child: AppSwitchTitle(
                          title: product.isActive ? 'Produto Ativo' : 'Produto Desativado',
                          subtitle: product.isActive ? 'Disponível para venda' : 'Indisponível para venda',
                          value: product.isActive,
                          onChanged: _adjustStatus,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(AppSpacing.space16),

              // Status do Estoque
              Text('Status do Estoque', style: context.textTheme.titleMedium),
              const Gap(AppSpacing.space8),
              Card(
                elevation: 0,
                color: statusColor.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadius24,
                  side: BorderSide(color: statusColor),
                ),
                borderOnForeground: true,
                child: Padding(
                  padding: const .all(AppSpacing.space12),
                  child: Row(
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: AppSpacing.icon40,
                        weight: 500,
                      ),
                      const Gap(AppSpacing.space8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              statusText,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: statusColor,
                              ),
                            ),
                            Text(
                              'Em estoque: ${product.stock} un. / Mínimo: ${product.minStock} un.',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(AppSpacing.space8),
                      AppButton(
                        onPressed: () => StockAdjustmentBottomSheet.show(context, product, _adjustStock),
                        backgroundColor: AppColors.surfaceLight,
                        borderRadius: AppSpacing.borderRadius24,
                        child: Text(
                          'Ajustar',
                          style: context.textTheme.titleMedium?.copyWith(color: AppColors.textPrimaryLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(AppSpacing.space16),

              // Informações do Produto
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
              const Gap(AppSpacing.space16),

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
}
