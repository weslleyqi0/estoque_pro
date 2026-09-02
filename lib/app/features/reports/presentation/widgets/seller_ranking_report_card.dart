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

  void _showAllSellersSheet(
    BuildContext context,
    int totalSalesAll,
    double totalAmountAll,
    NumberFormat currency,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SellerRankingFullSheet(
        sellerRanking: sellerRanking,
        totalSalesAll: totalSalesAll,
        totalAmountAll: totalAmountAll,
        currency: currency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final hasData = sellerRanking.isNotEmpty;
    final totalAmountAll = sellerRanking.fold<double>(0.0, (sum, s) => sum + s.totalAmount);
    final totalSalesAll = sellerRanking.fold<int>(0, (sum, s) => sum + s.salesCount);

    final displaySellers = sellerRanking.length > 3 ? sellerRanking.take(3).toList() : sellerRanking;

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: hasData ? () => _showAllSellersSheet(context, totalSalesAll, totalAmountAll, currency) : null,
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
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
                  Expanded(
                    child: Column(
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
                  ),
                  if (hasData)
                    AppIconButton.primary(
                      icon: Icons.arrow_forward_ios,
                      size: AppIconButtonSize.small,
                      iconColor: context.colorScheme.onSurface.withValues(alpha: 0.6),
                      tooltip: 'Ver todos os vendedores',
                      onPressed: () => _showAllSellersSheet(context, totalSalesAll, totalAmountAll, currency),
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
              else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displaySellers.length,
                  separatorBuilder: (context, index) => const Divider(height: AppSpacing.space16),
                  itemBuilder: (context, index) {
                    final seller = displaySellers[index];
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
                if (sellerRanking.length > 3) ...[
                  const Gap(AppSpacing.space12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ver todos os ${sellerRanking.length} vendedores',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(AppSpacing.space4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: context.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerRankingFullSheet extends StatelessWidget {
  final List<SellerRankingItemEntity> sellerRanking;
  final int totalSalesAll;
  final double totalAmountAll;
  final NumberFormat currency;

  const _SellerRankingFullSheet({
    required this.sellerRanking,
    required this.totalSalesAll,
    required this.totalAmountAll,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radius24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(AppSpacing.space8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(AppSpacing.space8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ranking de Vendedores',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${sellerRanking.length} vendedores • $totalSalesAll vendas (${currency.format(totalAmountAll)})',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                AppIconButton.primary(
                  icon: AppIcons.close,
                  size: AppIconButtonSize.small,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: AppSpacing.space16),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space16,
                AppSpacing.space8,
                AppSpacing.space16,
                AppSpacing.space24,
              ),
              shrinkWrap: true,
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

  Color? _getPositionColor() {
    if (seller.salesCount == 0 || seller.totalAmount == 0) {
      return null;
    }
    return switch (position) {
      1 => const Color(0xFFFFC420),
      2 => const Color(0xFF93A9B4),
      3 => const Color(0xFFA1610D),
      _ => null, // Cor neutra para posições além do pódio ou sem vendas
    };
  }

  @override
  Widget build(BuildContext context) {
    final posColor = _getPositionColor();
    final isTopThree = posColor != null;
    final neutralBg = context.colorScheme.surfaceContainerHighest;
    final neutralBorder = context.colorScheme.outlineVariant.withValues(alpha: 0.5);
    final neutralText = context.colorScheme.onSurface.withValues(alpha: 0.7);

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
                color: isTopThree ? posColor!.withValues(alpha: 0.15) : neutralBg,
                borderRadius: BorderRadius.circular(AppSpacing.radius8),
                border: Border.all(
                  color: isTopThree ? posColor!.withValues(alpha: 0.3) : neutralBorder,
                ),
              ),
              child: Text(
                '$positionº',
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isTopThree ? posColor : neutralText,
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
              isTopThree ? posColor! : context.colorScheme.outlineVariant,
            ),
          ),
        ),
      ],
    );
  }
}
