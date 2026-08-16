import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sheets/cart_bottom_sheet.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_products_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewSalePage extends StatefulWidget {
  final ProductsViewModel productsViewModel;
  final CartViewModel Function() cartViewModelFactory;
  final AuthViewModel authViewModel;
  final SaleEntity? initialSale;

  const NewSalePage({
    super.key,
    required this.productsViewModel,
    required this.cartViewModelFactory,
    required this.authViewModel,
    this.initialSale,
  });

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  late final CartViewModel cartViewModel;
  final _sheetController = DraggableScrollableController();

  static const double _collapsedSize = 0.12;
  static const double _expandedSize = 1.0;

  EdgeInsets get _snackbarMargin => EdgeInsets.only(
    bottom: _collapsedSize * MediaQuery.of(context).size.height + 16,
    left: AppSpacing.space16,
    right: AppSpacing.space16,
  );

  @override
  void initState() {
    super.initState();
    cartViewModel = widget.cartViewModelFactory();
    widget.productsViewModel.listenAll();
    if (widget.initialSale != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cartViewModel.loadSale(widget.initialSale!, widget.productsViewModel.products);
        widget.productsViewModel.clearLowStockFilter();
        widget.productsViewModel.setSearchQuery('', notify: false);
      });
    }
  }

  @override
  void dispose() {
    cartViewModel.dispose();
    _sheetController.dispose();
    widget.productsViewModel.setSearchQuery('', notify: false);
    widget.productsViewModel.clearLowStockFilter(notify: false);
    super.dispose();
  }

  bool get _isCartExpanded {
    if (!_sheetController.isAttached) return false;
    return _sheetController.size > (_collapsedSize + _expandedSize) / 2;
  }

  void _collapseCart() {
    if (!_sheetController.isAttached) return;
    _sheetController.animateTo(
      _collapsedSize,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<bool> _showSaveDraftDialog(BuildContext context) async {
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Salvar venda em andamento?',
      content: 'Você possui itens no carrinho. Deseja salvar a venda em andamento antes de sair?',
      confirmLabel: 'Salvar',
      cancelLabel: 'Descartar',
      cancelColor: AppColors.error,
    );

    if (confirmed == null) return false;

    if (confirmed) {
      try {
        final currentUser = widget.authViewModel.currentUser;
        final userId = currentUser?.uid ?? '';
        final userName = currentUser?.name ?? 'Vendedor';

        await cartViewModel.saveInProgressToFirebase(
          userId: userId,
          userName: userName,
          availableProducts: widget.productsViewModel.products,
        );

        if (context.mounted) {
          AppSnackbar.success(
            context,
            'Venda em andamento salva com sucesso!',
          );
        }
        return true;
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.error(
            context,
            e.toString().replaceAll('Exception: ', ''),
          );
        }
        return false;
      }
    } else {
      cartViewModel.clearCart();
      return true;
    }
  }

  void _openBarcodeScanner() async {
    final scannedCode = await context.push<String>(AppRoutes.saleScanner);
    if (scannedCode == null || scannedCode.isEmpty || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final matchedProduct = widget.productsViewModel.findProductByBarcode(scannedCode);
      if (matchedProduct == null) {
        AppSnackbar.error(
          context,
          margin: _snackbarMargin,
          'Produto não localizado com o código: $scannedCode',
        );
        return;
      }

      final previousQty = cartViewModel.getQuantityInCart(matchedProduct.id);
      final added = cartViewModel.addProduct(matchedProduct);
      if (added) {
        final currentQty = cartViewModel.getQuantityInCart(matchedProduct.id);
        final message = previousQty > 0
            ? '${matchedProduct.name} (x$currentQty no carrinho)'
            : '${matchedProduct.name} adicionado ao carrinho!';
        AppSnackbar.success(
          context,
          margin: _snackbarMargin,
          message,
        );
      } else {
        _showInsufficientStockToast(matchedProduct.name, matchedProduct.stock);
      }
    });
  }

  void _showInsufficientStockToast(String productName, int availableStock) {
    final message = availableStock <= 0
        ? 'Produto "$productName" sem estoque disponível.'
        : 'Estoque insuficiente para "$productName". Disponível em estoque: $availableStock';

    AppToast.warning(message);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.productsViewModel, cartViewModel]),
      builder: (context, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;

            if (_isCartExpanded) {
              _collapseCart();
              return;
            }

            if (cartViewModel.items.isNotEmpty) {
              final shouldPop = await _showSaveDraftDialog(context);
              if (shouldPop && context.mounted) {
                context.pop();
              }
              return;
            }

            if (context.mounted) {
              context.pop();
            }
          },
          child: Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  title: const Text('Nova Venda'),
                  centerTitle: true,
                ),
                body: CustomScrollView(
                  slivers: [
                    AppFloatingSearch(
                      hint: 'Buscar por nome, categoria, fornecedor ou código...',
                      initialValue: widget.productsViewModel.searchQuery,
                      onChanged: widget.productsViewModel.setSearchQuery,
                      trailing: Tooltip(
                        message: 'Abrir leitor de código de barras',
                        child: InkWell(
                          onTap: _openBarcodeScanner,
                          child: Container(
                            height: 68,
                            width: 68,
                            decoration: BoxDecoration(
                              color: context.colorScheme.primary,
                              borderRadius: BorderRadius.circular(AppSpacing.radius16),
                              border: .all(color: context.colorScheme.primary, width: 1.0),
                            ),
                            child: Icon(
                              AppIcons.barcodeScanner,
                              color: context.colorScheme.surface,
                              size: AppSpacing.icon32,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SaleProductsListSliver(
                      productsViewModel: widget.productsViewModel,
                      cartViewModel: cartViewModel,
                    ),
                  ],
                ),
              ),

              CartBottomSheet(
                cartViewModel: cartViewModel,
                authViewModel: widget.authViewModel,
                availableProducts: widget.productsViewModel.products,
                controller: _sheetController,
                onSaleSuccess: () {
                  AppSnackbar.success(context, 'Venda realizada com sucesso!');
                  context.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
