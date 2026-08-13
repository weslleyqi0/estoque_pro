import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/cart_bottom_sheet.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_products_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewSalePage extends StatefulWidget {
  final ProductsViewModel productsViewModel;
  final CartViewModel cartViewModel;
  final AuthViewModel authViewModel;
  final SaleEntity? initialSale;

  const NewSalePage({
    super.key,
    required this.productsViewModel,
    required this.cartViewModel,
    required this.authViewModel,
    this.initialSale,
  });

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
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
    widget.productsViewModel.listenAll();
    if (widget.initialSale != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.cartViewModel.loadSale(widget.initialSale!, widget.productsViewModel.products);
        widget.productsViewModel.clearLowStockFilter();
        widget.productsViewModel.setSearchQuery('', notify: false);
      });
    }
  }

  @override
  void dispose() {
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

        await widget.cartViewModel.saveInProgressToFirebase(
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
      widget.cartViewModel.clearCart();
      return true;
    }
  }

  void _openBarcodeScanner() async {
    final scannedCode = await context.push<String>(AppRoutes.saleScanner);
    if (scannedCode == null || scannedCode.isEmpty || !mounted) return;

    final matchedProduct = widget.productsViewModel.findProductByBarcode(scannedCode);
    if (matchedProduct == null) {
      AppSnackbar.error(
        context,
        margin: _snackbarMargin,
        'Produto não localizado com o código: $scannedCode',
      );
      return;
    }

    final added = widget.cartViewModel.addProduct(matchedProduct);
    if (added) {
      AppSnackbar.success(
        context,
        margin: _snackbarMargin,
        '${matchedProduct.name} adicionado ao carrinho!',
      );
    } else {
      AppSnackbar.error(
        context,
        margin: _snackbarMargin,
        'Estoque insuficiente para adicionar ${matchedProduct.name}.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.productsViewModel, widget.cartViewModel]),
      builder: (context, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;

            if (_isCartExpanded) {
              _collapseCart();
              return;
            }

            if (widget.cartViewModel.items.isNotEmpty) {
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
                      cartViewModel: widget.cartViewModel,
                    ),
                  ],
                ),
              ),

              CartBottomSheet(
                cartViewModel: widget.cartViewModel,
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
