import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/report_period.dart';
import 'package:estoque_pro/app/features/reports/presentation/viewmodels/reports_viewmodel.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/customers_debt_report_card.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/daily_sales_summary_section.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/deliveries_report_card.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/report_period_selector.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/sales_comparison_chart.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/sales_module_report_card.dart';
import 'package:estoque_pro/app/features/reports/presentation/widgets/stock_report_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ReportsPage extends StatefulWidget {
  final ReportsViewModel Function() viewModelFactory;

  const ReportsPage({
    super.key,
    required this.viewModelFactory,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late final ReportsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModelFactory();
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
      listenable: _viewModel,
      builder: (context, _) {
        final summary = _viewModel.summary;
        final period = _viewModel.period;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Relatórios & Métricas'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Atualizar dados',
                onPressed: () => _viewModel.listenAll(),
              ),
              const Gap(AppSpacing.space8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(92.0),
              child: Container(
                padding: const EdgeInsets.only(bottom: AppSpacing.space12),
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
    dynamic summary,
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
            // 1. Gráfico Comparativo de Vendas (Atual na cor Primary, Anterior em Outline cinza)
            SalesComparisonChart(
              points: summary.sales.chartPoints,
              currentLabel: _viewModel.period.type.label,
              previousLabel: _viewModel.period.type.previousLabel,
              currentTotal: summary.sales.totalSales,
              previousTotal: summary.sales.previousTotalSales,
            ),

            const Gap(AppSpacing.space20),

            // 3. Resumo Financeiro de Vendas (Total, Lucro, Custo, Fiados, Cartão, Dinheiro)
            DailySalesSummarySection(
              salesReport: summary.sales,
              periodName: _viewModel.period.type.label,
            ),

            const Gap(AppSpacing.space20),

            // 4. Card Modular: Produtos & Estoque (Estoque baixo, vazios, custo investido, lucro)
            StockReportCard(
              stockReport: summary.stock,
            ),

            const Gap(AppSpacing.space16),

            // 5. Card Modular: Desempenho de Vendas (Ticket médio, descontos, margem)
            SalesModuleReportCard(
              salesReport: summary.sales,
            ),

            const Gap(AppSpacing.space16),

            // 6. Card Modular: Clientes & Fiados (Clientes em débito, saldo a receber)
            CustomersDebtReportCard(
              customersDebtReport: summary.customersDebt,
            ),

            const Gap(AppSpacing.space16),

            // 7. Card Modular: Entregas (Pendentes, atrasadas, concluídas)
            DeliveriesReportCard(
              deliveriesReport: summary.deliveries,
            ),

            const Gap(AppSpacing.space32),
          ],
        ),
      ),
    );
  }
}
