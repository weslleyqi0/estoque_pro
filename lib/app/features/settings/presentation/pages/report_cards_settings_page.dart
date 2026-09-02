import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/reports/presentation/viewmodels/report_cards_order_viewmodel.dart';
import 'package:estoque_pro/app/features/settings/presentation/widgets/report_card_reorder_tile.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ReportCardsSettingsPage extends StatelessWidget {
  final ReportCardsOrderViewModel Function() viewModelFactory;

  const ReportCardsSettingsPage({
    super.key,
    required this.viewModelFactory,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = viewModelFactory();
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final cards = viewModel.cards;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Cards de Relatórios'),
            actions: [
              IconButton(
                icon: const Icon(AppIcons.refresh),
                tooltip: 'Restaurar Padrão',
                onPressed: () async {
                  await viewModel.resetToDefault();
                  if (context.mounted) {
                    AppSnackbar.info(context, 'Ordem padrão restaurada.');
                  }
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space16,
                    AppSpacing.space12,
                    AppSpacing.space16,
                    AppSpacing.space8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.space12),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radius12),
                      border: Border.all(
                        color: context.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.info,
                          color: context.colorScheme.primary,
                          size: AppSpacing.icon20,
                        ),
                        const Gap(AppSpacing.space12),
                        Expanded(
                          child: Text(
                            'Arraste os itens para reorganizar a ordem de exibição dos cards na tela de relatórios.',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                      vertical: AppSpacing.space8,
                    ),
                    itemCount: cards.length,
                    onReorderItem: (oldIndex, newIndex) {
                      viewModel.reorder(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final item = cards[index];
                      return ReportCardReorderTile(
                        key: ValueKey(item.id),
                        item: item,
                        index: index,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
