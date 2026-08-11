import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sales_list_sliver.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sales_status_tabs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final _viewModel = getIt<SalesViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.listenAll();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Vendas'),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: Container(
                padding: const EdgeInsets.only(bottom: AppSpacing.space12),
                color: context.colorScheme.surfaceContainerHighest,
                child: SalesStatusTabs(
                  viewModel: _viewModel,
                ),
              ),
            ),
          ),
          floatingActionButton: AppFloatingActionButton(
            tooltip: 'Iniciar Nova Venda',
            icon: AppIcons.add,
            onPressed: () => context.push(AppRoutes.newSale),
          ),
          body: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              if (_viewModel.sales.isNotEmpty)
                AppFloatingSearch(
                  hint: 'Pesquisar por número, cliente, vendedor ou produto...',
                  initialValue: _viewModel.searchQuery,
                  onChanged: _viewModel.setSearchQuery,
                ),
              SalesListSliver(viewModel: _viewModel),
            ],
          ),
        );
      },
    );
  }
}
