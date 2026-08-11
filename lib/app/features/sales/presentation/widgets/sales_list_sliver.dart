import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesListSliver extends StatelessWidget {
  final SalesViewModel viewModel;

  const SalesListSliver({
    super.key,
    required this.viewModel,
  });

  String _formatDateHeader(DateTime date) {
    final raw = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(date);
    final clean = raw.replaceAll('-feira', '');
    if (clean.isEmpty) return raw;
    return clean[0].toUpperCase() + clean.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    if (viewModel.state == SalesLoadState.loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.state == SalesLoadState.failure) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'Erro ao carregar vendas.',
            style: context.textTheme.bodyMedium?.copyWith(color: AppColors.error),
          ),
        ),
      );
    }

    if (viewModel.sales.isEmpty) {
      return const SliverFillRemaining(
        child: AppEmptyList(
          message: 'Nenhuma venda registrada.\nInicie uma nova venda tocando no botão "+".',
          icon: AppIcons.receipt,
          iconColor: Colors.green,
          iconSize: AppSpacing.icon48,
        ),
      );
    }

    final groupedSales = viewModel.groupedFilteredSales;

    if (groupedSales.isEmpty) {
      return const SliverFillRemaining(
        child: AppEmptyList(
          message: 'Nenhuma venda encontrada para essa pesquisa.',
          icon: AppIcons.searchOff,
          iconColor: Colors.grey,
          iconSize: AppSpacing.icon48,
        ),
      );
    }

    final slivers = <Widget>[];

    for (final entry in groupedSales.entries) {
      final salesCount = entry.value.length;
      final salesText = salesCount == 1 ? '1 venda' : '$salesCount vendas';

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const .only(
              left: AppSpacing.space16,
              right: AppSpacing.space16,
              top: AppSpacing.space12,
              bottom: AppSpacing.space8,
            ),
            child: Text(
              '${_formatDateHeader(entry.key)} • $salesText',
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: .w400,
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );

      slivers.add(
        SliverPadding(
          padding: const .symmetric(horizontal: AppSpacing.space16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final sale = entry.value[index];
                final isExpanded = viewModel.expandedSaleId == sale.id;

                return SaleCard(
                  sale: sale,
                  isExpanded: isExpanded,
                  onToggleExpand: () => viewModel.toggleExpand(sale.id),
                );
              },
              childCount: entry.value.length,
            ),
          ),
        ),
      );
    }

    slivers.add(
      const SliverToBoxAdapter(
        child: SizedBox(height: AppSpacing.space80),
      ),
    );

    return SliverMainAxisGroup(slivers: slivers);
  }
}
