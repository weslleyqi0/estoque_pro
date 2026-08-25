import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/widgets/deliveries_list_sliver.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/widgets/deliveries_status_tabs.dart';
import 'package:flutter/material.dart';

class DeliveriesPage extends StatefulWidget {
  final DeliveriesViewModel Function() viewModelFactory;
  final AuthViewModel authViewModel;
  final DeliveryFilterTab? initialTab;

  const DeliveriesPage({
    super.key,
    required this.viewModelFactory,
    required this.authViewModel,
    this.initialTab,
  });

  @override
  State<DeliveriesPage> createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage> {
  late final DeliveriesViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = widget.viewModelFactory();
    if (widget.initialTab != null) {
      viewModel.setSelectedTab(widget.initialTab!);
    }
    viewModel.listenAll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.setSearchQuery('');
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Entregas'),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: Container(
                padding: const EdgeInsets.only(bottom: AppSpacing.space12),
                color: context.isDark
                    ? context.colorScheme.surfaceContainerLow
                    : context.colorScheme.surfaceContainerHighest,
                child: DeliveriesStatusTabs(viewModel: viewModel),
              ),
            ),
          ),
          body: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              if (viewModel.deliveries.isNotEmpty)
                AppFloatingSearch(
                  hint: 'Buscar por cliente, venda, endereço...',
                  initialValue: viewModel.searchQuery,
                  onChanged: viewModel.setSearchQuery,
                ),
              DeliveriesListSliver(viewModel: viewModel),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      },
    );
  }
}
