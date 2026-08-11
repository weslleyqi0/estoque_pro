import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/cart_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/cart_bottom_sheet.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_products_list_sliver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewSalePage extends StatefulWidget {
  final SaleEntity? initialSale;

  const NewSalePage({
    super.key,
    this.initialSale,
  });

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  final _productsViewModel = getIt<ProductsViewModel>();
  final _cartViewModel = getIt<CartViewModel>();
  final _sheetController = DraggableScrollableController();

  static const double _collapsedSize = 0.12;
  static const double _expandedSize = 1.0;

  @override
  void initState() {
    super.initState();
    _productsViewModel.listenAll();
    if (widget.initialSale != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cartViewModel.loadSale(widget.initialSale!, _productsViewModel.products);
      });
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
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
        final authVM = getIt<AuthViewModel>();
        final currentUser = authVM.currentUser;
        final userId = currentUser?.uid ?? '';
        final userName = currentUser?.name ?? 'Vendedor';

        await _cartViewModel.saveInProgressToFirebase(
          userId: userId,
          userName: userName,
          availableProducts: _productsViewModel.products,
        );

        if (context.mounted) {
          AppSnackbar.success(context, 'Venda em andamento salva com sucesso!');
        }
        return true;
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.error(context, e.toString().replaceAll('Exception: ', ''));
        }
        return false;
      }
    } else {
      _cartViewModel.clearCart();
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_productsViewModel, _cartViewModel]),
      builder: (context, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;

            if (_isCartExpanded) {
              _collapseCart();
              return;
            }

            if (_cartViewModel.items.isNotEmpty) {
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
                      onChanged: _productsViewModel.setSearchQuery,
                    ),

                    SaleProductsListSliver(
                      productsViewModel: _productsViewModel,
                      cartViewModel: _cartViewModel,
                    ),
                  ],
                ),
              ),

              CartBottomSheet(
                cartViewModel: _cartViewModel,
                availableProducts: _productsViewModel.products,
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
