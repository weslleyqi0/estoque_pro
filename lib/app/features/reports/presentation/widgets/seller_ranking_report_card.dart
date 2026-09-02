import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/seller_ranking_item_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class SellerRankingReportCard extends StatelessWidget {
  final List<SellerRankingItemEntity> sellerRanking;

  const SellerRankingReportCard({
    super.key,
    required this.sellerRanking,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final hasData = sellerRanking.isNotEmpty;
    final totalAmountAll = sellerRanking.fold<double>(0.0, (sum, s) => sum + s.totalAmount);
    final totalSalesAll = sellerRanking.fold<int>(0, (sum, s) => sum + s.salesCount);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header unificado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.space12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radius8),
                ),
                child: Icon(
                  Icons.leaderboard_outlined,
                  color: Colors.amber.shade800,
                  size: AppSpacing.icon20,
                ),
              ),
              const Gap(AppSpacing.space12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ranking por Vendedor',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    hasData
                        ? '${sellerRanking.length} ${sellerRanking.length == 1 ? 'vendedor' : 'vendedores'} • $totalSalesAll vendas'
                        : 'Desempenho da equipe de vendas',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Gap(AppSpacing.space16),

          if (!hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 36,
                      color: context.colorScheme.outline.withValues(alpha: 0.4),
                    ),
                    const Gap(AppSpacing.space8),
                    Text(
                      'Nenhuma venda registrada no período selecionado',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sellerRanking.length,
              separatorBuilder: (context, index) => const Divider(height: AppSpacing.space16),
              itemBuilder: (context, index) {
                final seller = sellerRanking[index];
                final position = index + 1;
                final sharePercent = totalAmountAll > 0 ? (seller.totalAmount / totalAmountAll) * 100 : 0.0;

                return _SellerRankingRow(
                  position: position,
                  seller: seller,
                  currency: currency,
                  sharePercent: sharePercent,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SellerRankingRow extends StatelessWidget {
  final int position;
  final SellerRankingItemEntity seller;
  final NumberFormat currency;
  final double sharePercent;

  const _SellerRankingRow({
    required this.position,
    required this.seller,
    required this.currency,
    required this.sharePercent,
  });

  Color _getPositionColor(BuildContext context) {
    return switch (position) {
      1 => Colors.amber.shade700,
      2 => Colors.blueGrey.shade400,
      3 => Colors.brown.shade400,
      _ => context.colorScheme.onSurface.withValues(alpha: 0.5),
    };
  }

  @override
  Widget build(BuildContext context) {
    final posColor = _getPositionColor(context);
    final isTopThree = position <= 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Badge de Posição
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isTopThree ? posColor.withValues(alpha: 0.15) : context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radius8),
                border: isTopThree ? Border.all(color: posColor.withValues(alpha: 0.3)) : null,
              ),
              child: Text(
                '$positionº',
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isTopThree ? posColor : context.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),

            const Gap(AppSpacing.space12),

            // Nome do Vendedor e Quantidade de Vendas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller.userName,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${seller.salesCount} ${seller.salesCount == 1 ? 'venda' : 'vendas'}',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            const Gap(AppSpacing.space8),

            // Valor faturado e porcentagem do total
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currency.format(seller.totalAmount),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
                  ),
                ),
                Text(
                  '${sharePercent.toStringAsFixed(0)}% do total',
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),

        const Gap(AppSpacing.space4),

        // Barra de progresso visual de participação com pontas arredondadas
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radius8),
          child: LinearProgressIndicator(
            value: (sharePercent / 100).clamp(0.0, 1.0),
            minHeight: 8,
            borderRadius: BorderRadius.circular(AppSpacing.radius8),
            backgroundColor: context.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              isTopThree ? posColor : context.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}
