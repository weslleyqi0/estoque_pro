import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/report_card_type.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/reports_summary_entity.dart';
import 'package:estoque_pro/app/features/reports/presentation/viewmodels/report_cards_order_viewmodel.dart';
import 'package:estoque_pro/app/features/reports/presentation/viewmodels/reports_viewmodel.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/customers_debt_report_card.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/daily_sales_summary_section.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/deliveries_report_card.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/report_period_selector.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/sales_comparison_chart.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/sales_module_report_card.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/seller_ranking_report_card.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/stock_report_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ReportsPage extends StatefulWidget {
  final ReportsViewModel Function() viewModelFactory;
  final ReportCardsOrderViewModel Function()? orderViewModelFactory;

  const ReportsPage({
    super.key,
    required this.viewModelFactory,
    this.orderViewModelFactory,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late final ReportsViewModel _viewModel;
  late final ReportCardsOrderViewModel _orderViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModelFactory();
    _orderViewModel = widget.orderViewModelFactory?.call() ?? getIt<ReportCardsOrderViewModel>();
    _viewModel.listenAll();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_viewModel, _orderViewModel]),
      builder: (context, _) {
        final summary = _viewModel.summary;
        final period = _viewModel.period;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Relatórios & Métricas'),
            centerTitle: true,
            actions: [
              AppIconButton.primary(
                icon: AppIcons.tune,
                tooltip: 'Personalizar cards',
                visualDensity: VisualDensity.compact,
                iconColor: context.colorScheme.onSurface,
                onPressed: () => context.push(AppRoutes.reportCardsSettings),
              ),
              AppIconButton.primary(
                icon: Icons.refresh,
                tooltip: 'Atualizar dados',
                visualDensity: VisualDensity.compact,
                iconColor: context.colorScheme.onSurface,
                onPressed: () => _viewModel.listenAll(),
              ),
              const Gap(AppSpacing.space8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80.0),
              child: Container(
                padding: const EdgeInsets.only(bottom: AppSpacing.space8),
                color: context.isDark
                    ? context.colorScheme.surfaceContainerLow
                    : context.colorScheme.surfaceContainerHighest,
                child: ReportPeriodSelector(
                  period: period,
                  onPeriodSelected: (type) => _viewModel.setPeriodType(type),
                  onCustomRangeSelected: (start, end) => _viewModel.setCustomRange(start, end),
                ),
              ),
            ),
          ),
          body: _buildBody(context, summary),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ReportsSummaryEntity? summary,
  ) {
    if (_viewModel.isLoading && summary == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_viewModel.error != null && summary == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const Gap(AppSpacing.space16),
              Text(
                'Não foi possível carregar os relatórios.',
                style: context.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const Gap(AppSpacing.space8),
              Text(
                '${_viewModel.error}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(AppSpacing.space16),
              AppButton(
                label: 'Tentar novamente',
                onPressed: () => _viewModel.listenAll(),
              ),
            ],
          ),
        ),
      );
    }

    if (summary == null) {
      return const SizedBox.shrink();
    }

    final orderedCards = _orderViewModel.visibleCards;

    if (orderedCards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.visibility_off_outlined,
                size: 48,
                color: context.colorScheme.outline.withValues(alpha: 0.5),
              ),
              const Gap(AppSpacing.space12),
              Text(
                'Nenhum card visível',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(AppSpacing.space4),
              Text(
                'Todos os cards de relatórios foram ocultados nas configurações.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Gap(AppSpacing.space16),
              FilledButton.tonalIcon(
                icon: const Icon(AppIcons.tune, size: 18),
                label: const Text('Personalizar cards'),
                onPressed: () => context.push(AppRoutes.reportCardsSettings),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _viewModel.listenAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final cardType in orderedCards) ...[
              _buildCard(cardType, summary),
              const Gap(AppSpacing.space16),
            ],
            const Gap(AppSpacing.space16),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(ReportCardType type, ReportsSummaryEntity summary) {
    return switch (type) {
      ReportCardType.salesComparison => SalesComparisonChart(
        points: summary.sales.chartPoints,
        currentLabel: _viewModel.period.type.label,
        previousLabel: _viewModel.period.type.previousLabel,
        currentTotal: summary.sales.totalSales,
        previousTotal: summary.sales.previousTotalSales,
      ),
      ReportCardType.salesSummary => DailySalesSummarySection(
        salesReport: summary.sales,
        periodName: _viewModel.period.type.label,
      ),
      ReportCardType.salesPerformance => SalesModuleReportCard(
        salesReport: summary.sales,
      ),
      ReportCardType.stock => StockReportCard(
        stockReport: summary.stock,
      ),
      ReportCardType.customersDebt => CustomersDebtReportCard(
        customersDebtReport: summary.customersDebt,
      ),
      ReportCardType.deliveries => DeliveriesReportCard(
        deliveriesReport: summary.deliveries,
      ),
      ReportCardType.sellerRanking => SellerRankingReportCard(
        sellerRanking: summary.sales.sellerRanking,
      ),
    };
  }
}
