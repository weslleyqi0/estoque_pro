import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_reason.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/edit_sale_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/edit_sale/edit_sale_add_product_dialog.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/edit_sale/edit_sale_footer.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/edit_sale/edit_sale_header.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/edit_sale/edit_sale_item_card.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/edit_sale/edit_sale_reason_selector.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/edit_sale/edit_sale_swap_product_dialog.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EditSaleBottomSheet extends StatefulWidget {
  final SaleEntity sale;

  const EditSaleBottomSheet({
    super.key,
    required this.sale,
  });

  static Future<void> show(BuildContext context, SaleEntity sale) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditSaleBottomSheet(sale: sale),
    );
  }

  @override
  State<EditSaleBottomSheet> createState() => _EditSaleBottomSheetState();
}

class _EditSaleBottomSheetState extends State<EditSaleBottomSheet> {
  late final EditSaleViewModel _viewModel;
  late final TextEditingController _commentController;
  Map<String, ProductEntity> _productsMap = {};

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<EditSaleViewModel>()..initWithSale(widget.sale);
    _commentController = TextEditingController(text: _viewModel.comment);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _viewModel.loadProducts();
    if (mounted) {
      setState(() {
        _productsMap = {for (var p in products) p.id: p};
      });
    }
  }

  void _showInsufficientStockToast(String productName, int availableStock) {
    AppToast.warning(
      'Estoque insuficiente para "$productName". Disponível em estoque: $availableStock',
    );
  }

  void _increaseItemQuantity(SaleItemEntity item) {
    final targetQty = item.quantity + 1;

    final origItem = widget.sale.items.firstWhere(
      (i) => i.productId == item.productId,
      orElse: () => const SaleItemEntity(
        productId: '',
        productName: '',
        productImgUrl: '',
        unitPrice: 0,
        quantity: 0,
      ),
    );

    final delta = targetQty - origItem.quantity;
    final product = _productsMap[item.productId];
    final currentInventoryStock = product?.stock ?? 0;

    if (delta > currentInventoryStock) {
      _showInsufficientStockToast(item.productName, currentInventoryStock);
      return;
    }

    _viewModel.updateQuantity(item, targetQty);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  bool get _canCancel {
    final currentUser = getIt<AuthViewModel>().currentUser;
    if (currentUser == null || !currentUser.isActive) return false;
    if (currentUser.role == UserRole.owner || currentUser.role == UserRole.admin) return true;
    return currentUser.hasPermission(UserPermission.cancelCompletedSales);
  }

  void _onSave(BuildContext context) async {
    final currentUser = getIt<AuthViewModel>().currentUser;
    if (currentUser == null) return;

    _viewModel.setComment(_commentController.text.trim());
    final result = await _viewModel.saveEdit(currentUser: currentUser);

    if (context.mounted) {
      if (result.isSuccess) {
        AppToast.success('Edição salva com sucesso!');
        Navigator.of(context).pop();
      } else {
        AppToast.error(
          result.error?.toString().replaceAll('Exception: ', '') ?? 'Erro ao salvar edição',
        );
      }
    }
  }

  void _onCancelSale(BuildContext context) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Cancelar Venda Finalizada',
      content:
          'Tem certeza que deseja cancelar a Venda ${widget.sale.saleNumber}? Todos os itens retornarão ao estoque.',
      confirmLabel: 'Sim, Cancelar',
      cancelLabel: 'Voltar',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final currentUser = getIt<AuthViewModel>().currentUser;
      if (currentUser == null) return;

      final result = await _viewModel.cancelSale(
        currentUser: currentUser,
        comment: _commentController.text.trim(),
      );

      if (context.mounted) {
        if (result.isSuccess) {
          AppSnackbar.success(context, 'Venda cancelada e estoque estornado com sucesso!');
          Navigator.of(context).pop();
        } else {
          AppSnackbar.error(
            context,
            result.error?.toString().replaceAll('Exception: ', '') ?? 'Erro ao cancelar venda',
          );
        }
      }
    }
  }

  void _showAddProductDialog(BuildContext context) async {
    final products = _viewModel.products.isNotEmpty ? _viewModel.products : await _viewModel.loadProducts();

    if (!context.mounted) return;

    EditSaleAddProductDialog.show(
      context: context,
      products: products,
      onSelectProduct: (product) {
        final currentStock = product.stock;
        final existingDraftItem = _viewModel.draftItems.firstWhere(
          (i) => i.productId == product.id,
          orElse: () => const SaleItemEntity(
            productId: '',
            productName: '',
            productImgUrl: '',
            unitPrice: 0,
            quantity: 0,
          ),
        );
        final targetQty = existingDraftItem.quantity + 1;
        final origItem = widget.sale.items.firstWhere(
          (i) => i.productId == product.id,
          orElse: () => const SaleItemEntity(
            productId: '',
            productName: '',
            productImgUrl: '',
            unitPrice: 0,
            quantity: 0,
          ),
        );
        final delta = targetQty - origItem.quantity;

        if (delta > currentStock) {
          _showInsufficientStockToast(product.name, currentStock);
          return;
        }

        _viewModel.addItem(product, 1);
        Navigator.pop(context);
      },
    );
  }

  void _showSwapProductDialog(BuildContext context, SaleItemEntity item) async {
    final products = _viewModel.products.isNotEmpty ? _viewModel.products : await _viewModel.loadProducts();

    if (!context.mounted) return;

    EditSaleSwapProductDialog.show(
      context: context,
      targetItem: item,
      products: products,
      onSwapWithProduct: (product) {
        final currentStock = product.stock;
        final targetQty = item.quantity;
        final origItem = widget.sale.items.firstWhere(
          (i) => i.productId == product.id,
          orElse: () => const SaleItemEntity(
            productId: '',
            productName: '',
            productImgUrl: '',
            unitPrice: 0,
            quantity: 0,
          ),
        );
        final delta = targetQty - origItem.quantity;

        if (delta > currentStock) {
          _showInsufficientStockToast(product.name, currentStock);
          return;
        }

        _viewModel.swapItem(item, product, item.quantity);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radius24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final items = _viewModel.draftItems;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EditSaleHeader(sale: widget.sale),
                const Divider(height: 1),

                // Scrollable content body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Itens da Venda em Rascunho',
                          style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Gap(AppSpacing.space8),
                        if (items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
                            child: Center(
                              child: Text(
                                'Nenhum item restante na venda.',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          )
                        else
                          ...items.map(
                            (item) => EditSaleItemCard(
                              item: item,
                              onDecrease: () => _viewModel.updateQuantity(item, item.quantity - 1),
                              onIncrease: () => _increaseItemQuantity(item),
                              onSwap: () => _showSwapProductDialog(context, item),
                              onRemove: () => _viewModel.removeItem(item),
                            ),
                          ),
                        const Gap(AppSpacing.space8),
                        OutlinedButton.icon(
                          onPressed: () => _showAddProductDialog(context),
                          icon: const Icon(AppIcons.add),
                          label: const Text('Adicionar Novo Produto'),
                        ),
                        const Divider(height: AppSpacing.space24),
                        EditSaleReasonSelector(
                          reasons: SaleEditReason.values,
                          selectedReason: _viewModel.selectedReason,
                          onReasonSelected: _viewModel.setReason,
                        ),
                        const Gap(AppSpacing.space12),
                        TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            labelText: 'Observação da Edição (Opcional)',
                            hintText: 'Ex: Cliente trocou o tamanho / Devolução parcial',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                EditSaleFooter(
                  originalTotal: widget.sale.total,
                  newTotal: _viewModel.newTotal,
                  canCancel: _canCancel,
                  isSaving: _viewModel.isSaving,
                  hasChanges: _viewModel.hasChanges,
                  onCancelSale: () => _onCancelSale(context),
                  onSaveEdit: () => _onSave(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
