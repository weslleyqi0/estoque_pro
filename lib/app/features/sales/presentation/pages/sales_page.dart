import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sales_list_sliver.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sales_status_tabs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SalesPage extends StatefulWidget {
  final SalesViewModel viewModel;
  final AuthViewModel authViewModel;
  final SalesFilterTab? initialTab;

  const SalesPage({
    super.key,
    required this.viewModel,
    required this.authViewModel,
    this.initialTab,
  });

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  @override
  void initState() {
    super.initState();
    if (widget.initialTab != null) {
      widget.viewModel.setSelectedTab(widget.initialTab!);
    }
    widget.viewModel.listenAll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.setSearchQuery('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Vendas'),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: Container(
                padding: const EdgeInsets.only(bottom: AppSpacing.space12),
                color: context.isDark
                    ? context.colorScheme.surfaceContainerLow
                    : context.colorScheme.surfaceContainerHighest,
                child: SalesStatusTabs(viewModel: widget.viewModel),
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
              if (widget.viewModel.sales.isNotEmpty)
                AppFloatingSearch(
                  hint: 'Pesquisar por número, cliente, vendedor ou produto...',
                  initialValue: widget.viewModel.searchQuery,
                  onChanged: widget.viewModel.setSearchQuery,
                ),
              SalesListSliver(
                viewModel: widget.viewModel,
                authViewModel: widget.authViewModel,
              ),
            ],
          ),
        );
      },
    );
  }
}
