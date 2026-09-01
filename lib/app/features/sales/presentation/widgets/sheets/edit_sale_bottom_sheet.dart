import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_bottom_sheet.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_edit_reason.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_item_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/edit_sale_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/edit_sale/edit_sale_footer.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/edit_sale/edit_sale_header.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/edit_sale/edit_sale_item_card.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/edit_sale/edit_sale_reason_selector.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class EditSaleBottomSheet extends StatefulWidget {
  final SaleEntity sale;
  final AuthViewModel authViewModel;
  final EditSaleViewModel Function() viewModelFactory;
  final CustomersViewModel Function()? customersViewModelFactory;
  final CustomerDebtsViewModel Function()? debtsViewModelFactory;

  const EditSaleBottomSheet({
    super.key,
    required this.sale,
    required this.authViewModel,
    required this.viewModelFactory,
    this.customersViewModelFactory,
    this.debtsViewModelFactory,
  });

  static Future<void> show(
    BuildContext context,
    SaleEntity sale, {
    required AuthViewModel authViewModel,
    required EditSaleViewModel Function() viewModelFactory,
    CustomersViewModel Function()? customersViewModelFactory,
    CustomerDebtsViewModel Function()? debtsViewModelFactory,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditSaleBottomSheet(
        sale: sale,
        authViewModel: authViewModel,
        viewModelFactory: viewModelFactory,
        customersViewModelFactory: customersViewModelFactory,
        debtsViewModelFactory: debtsViewModelFactory,
      ),
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
    _viewModel = widget.viewModelFactory()..initWithSale(widget.sale);
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
    super.dispose();
  }

  bool get _canCancel {
    final currentUser = widget.authViewModel.currentUser;
    if (currentUser == null || !currentUser.isActive) return false;
    return currentUser.hasPermission(UserPermission.cancelCompletedSales);
  }

  void _selectCustomer(BuildContext context) {
    if (widget.customersViewModelFactory == null || widget.debtsViewModelFactory == null) return;
    final customersVM = widget.customersViewModelFactory!();
    final debtsVM = widget.debtsViewModelFactory!();
    final canManageCustomers = widget.authViewModel.currentUser?.hasPermission(UserPermission.managerCustomer) ?? false;

    CustomerBottomSheet.show(
      context: context,
      customersVM: customersVM,
      debtsViewModel: debtsVM,
      authViewModel: widget.authViewModel,
      canManageCustomers: canManageCustomers,
      onCustomerSelected: (customer) {
        _viewModel.setCustomer(id: customer.id, name: customer.name);
      },
    );
  }

  void _onSave(BuildContext context) async {
    final currentUser = widget.authViewModel.currentUser;
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
    final currentUser = widget.authViewModel.currentUser;
    if (currentUser == null) return;

    if (!_canCancel) {
      AppToast.error('Você não possui permissão para cancelar vendas.');
      return;
    }

    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Cancelar Venda',
      content:
          'Deseja realmente cancelar a Venda ${widget.sale.saleNumber}?\n\n'
          '⚠️ Atenção: Todos os produtos desta venda retornarão automaticamente ao estoque.',
      confirmLabel: 'Sim, Cancelar Venda',
      cancelLabel: 'Voltar',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final comment = _commentController.text.trim();
      final result = await _viewModel.cancelSale(
        currentUser: currentUser,
        reason: 'Cancelamento',
        comment: comment.isNotEmpty ? comment : null,
      );

      if (context.mounted) {
        if (result.isSuccess) {
          AppToast.success('Venda cancelada com sucesso!');
          Navigator.of(context).pop();
        } else {
          AppToast.error(
            result.error?.toString().replaceAll('Exception: ', '') ?? 'Erro ao cancelar venda.',
          );
        }
      }
    }
  }

  void _onCancelEdit(BuildContext context) async {
    if (_viewModel.hasChanges) {
      final confirmed = await AppDialog.showConfirmation(
        context: context,
        title: 'Descartar alterações?',
        content: 'Você possui alterações não salvas na edição. Deseja descartá-las?',
        confirmLabel: 'Descartar',
        cancelLabel: 'Continuar editando',
        isDestructive: true,
      );
      if (confirmed == true && context.mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showAddProductDialog(BuildContext context) async {
    final selectedProduct = await context.push<ProductEntity>(
      AppRoutes.productSelect,
      extra: 'Adicionar Produto na Venda',
    );

    if (selectedProduct != null && mounted) {
      final isAlreadyInDraft = _viewModel.draftItems.any(
        (i) => i.productId == selectedProduct.id,
      );

      final currentStock = selectedProduct.stock;
      final existingDraftItem = _viewModel.draftItems.firstWhere(
        (i) => i.productId == selectedProduct.id,
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
        (i) => i.productId == selectedProduct.id,
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
        _showInsufficientStockToast(selectedProduct.name, currentStock);
        return;
      }

      _viewModel.addItem(selectedProduct, 1);

      if (isAlreadyInDraft) {
        AppToast.info(
          'O produto "${selectedProduct.name}" já estava na lista. A quantidade foi incrementada.',
        );
      }
    }
  }

  void _showSwapProductDialog(BuildContext context, SaleItemEntity item) async {
    final selectedProduct = await context.push<ProductEntity>(
      AppRoutes.productSelect,
      extra: 'Substituir "${item.productName}"',
    );

    if (selectedProduct != null && mounted) {
      final isAlreadyInDraft = _viewModel.draftItems.any(
        (i) => i.productId == selectedProduct.id && i.productId != item.productId,
      );

      final existingDraftItem = _viewModel.draftItems.firstWhere(
        (i) => i.productId == selectedProduct.id,
        orElse: () => const SaleItemEntity(
          productId: '',
          productName: '',
          productImgUrl: '',
          unitPrice: 0,
          quantity: 0,
        ),
      );

      final targetQty = isAlreadyInDraft ? existingDraftItem.quantity + item.quantity : item.quantity;

      final currentStock = selectedProduct.stock;
      final origItem = widget.sale.items.firstWhere(
        (i) => i.productId == selectedProduct.id,
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
        _showInsufficientStockToast(selectedProduct.name, currentStock);
        return;
      }

      _viewModel.swapItem(item, selectedProduct, item.quantity);

      if (isAlreadyInDraft) {
        AppToast.info(
          'O produto "${selectedProduct.name}" já estava na lista. As quantidades foram somadas.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return PopScope(
          canPop: !_viewModel.hasChanges,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _onCancelEdit(context);
            }
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radius24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EditSaleHeader(
                    sale: widget.sale,
                    onClose: () => _onCancelEdit(context),
                  ),
                  const Divider(height: 1),

                  // Scrollable content body
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.space16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card do Cliente
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.space12),
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppSpacing.radius12),
                              border: Border.all(
                                color: context.colorScheme.outlineVariant.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.space8),
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppSpacing.radius8),
                                  ),
                                  child: Icon(
                                    AppIcons.person,
                                    color: context.colorScheme.primary,
                                    size: AppSpacing.icon20,
                                  ),
                                ),
                                const Gap(AppSpacing.space12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cliente da Venda',
                                        style: context.textTheme.labelSmall?.copyWith(
                                          color: context.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        _viewModel.selectedCustomerName?.isNotEmpty == true
                                            ? _viewModel.selectedCustomerName!
                                            : 'Cliente não vinculado (Venda Balcão)',
                                        style: context.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: _viewModel.selectedCustomerName?.isNotEmpty == true
                                              ? null
                                              : context.colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: AppSpacing.space32,
                                  child: AppButton.text(
                                    onPressed: () => _selectCustomer(context),
                                    label: _viewModel.selectedCustomerName?.isNotEmpty == true ? 'Trocar' : 'Vincular',
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(AppSpacing.space16),

                          Text(
                            'Itens da Venda em Rascunho',
                            style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Gap(AppSpacing.space8),
                          if (_viewModel.draftItems.isEmpty)
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
                            ..._viewModel.draftItems.map(
                              (item) => EditSaleItemCard(
                                item: item,
                                onDecrease: () => _viewModel.updateQuantity(item, item.quantity - 1),
                                onIncrease: () => _increaseItemQuantity(item),
                                onSwap: () => _showSwapProductDialog(context, item),
                                onRemove: () => _viewModel.removeItem(item),
                              ),
                            ),
                          const Gap(AppSpacing.space8),
                          AppButton.outlined(
                            onPressed: () => _showAddProductDialog(context),
                            icon: AppIcons.add,
                            label: 'Adicionar Novo Produto',
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
              ),
            ),
          ),
        );
      },
    );
  }
}
