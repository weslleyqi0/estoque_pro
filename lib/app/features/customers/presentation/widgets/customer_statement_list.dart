import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_payment_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_statement_item_entity.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/edit_customer_payment_bottom_sheet.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/payment_method.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sheets/digital_invoice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomerStatementList extends StatelessWidget {
  final List<CustomerStatementItemEntity> statementItems;
  final String customerName;
  final CustomerDebtsViewModel? debtsViewModel;
  final int? maxItems;
  final bool showViewAll;
  final VoidCallback? onViewAll;

  const CustomerStatementList({
    super.key,
    required this.statementItems,
    this.customerName = '',
    this.debtsViewModel,
    this.maxItems,
    this.showViewAll = true,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (statementItems.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.space24),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radius16),
          border: Border.all(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          children: [
            Icon(
              AppIcons.receiptLong,
              size: AppSpacing.icon40,
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const Gap(AppSpacing.space8),
            Text(
              'Nenhuma movimentação registrada',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(AppSpacing.space4),
            Text(
              'Compras a fiado e pagamentos aparecerão aqui.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final hasLimit = maxItems != null && maxItems! > 0 && statementItems.length > maxItems!;
    final displayedItems = hasLimit ? statementItems.take(maxItems!).toList() : statementItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hasLimit ? 'Últimas Movimentações' : 'Extrato de Movimentações',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${statementItems.length} ${statementItems.length == 1 ? "registro" : "registros"}',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.space8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedItems.length,
          separatorBuilder: (_, _) => const Gap(AppSpacing.space8),
          itemBuilder: (context, index) {
            final item = displayedItems[index];
            return _CompactStatementCard(
              item: item,
              customerName: customerName,
              debtsViewModel: debtsViewModel,
            );
          },
        ),
        if (hasLimit && showViewAll && onViewAll != null) ...[
          const Gap(AppSpacing.space12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewAll,
              icon: const Icon(AppIcons.receiptLong, size: AppSpacing.icon16),
              label: Text('Ver todas as movimentações (${statementItems.length})'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radius12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CompactStatementCard extends StatelessWidget {
  final CustomerStatementItemEntity item;
  final String customerName;
  final CustomerDebtsViewModel? debtsViewModel;

  const _CompactStatementCard({
    required this.item,
    required this.customerName,
    this.debtsViewModel,
  });

  void _openPurchaseInvoice(BuildContext context) {
    final sale = debtsViewModel?.getSaleById(item.saleId);
    if (sale != null) {
      DigitalInvoiceSheet.show(context, sale);
    } else {
      final fallbackSale = SaleEntity(
        id: item.saleId ?? item.id,
        saleNumber: item.saleNumber ?? 'FIADO',
        items: item.items,
        subtotal: item.amount,
        total: item.amount,
        paymentMethod: PaymentMethod.fiado,
        customerName: customerName,
        userId: '',
        userName: item.registeredByName,
        createdAt: item.date,
      );
      DigitalInvoiceSheet.show(context, fallbackSale);
    }
  }

  void _openEditPayment(BuildContext context) {
    if (debtsViewModel == null) return;

    final payment = item.payment ??
        CustomerPaymentEntity(
          id: item.id,
          customerId: '',
          customerName: customerName,
          amount: item.amount,
          paymentMethod: item.paymentMethod ?? PaymentMethod.dinheiro,
          notes: item.notes,
          userId: '',
          userName: item.registeredByName,
          createdAt: item.date,
          isCancelled: item.isCancelled,
          cancelledAt: item.payment?.cancelledAt,
          cancellationReason: item.cancellationReason,
        );

    EditCustomerPaymentBottomSheet.show(
      context: context,
      payment: payment,
      debtsViewModel: debtsViewModel!,
      customerName: customerName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final day = item.date.day.toString().padLeft(2, '0');
    final month = item.date.month.toString().padLeft(2, '0');
    final year = item.date.year;
    final hour = item.date.hour.toString().padLeft(2, '0');
    final minute = item.date.minute.toString().padLeft(2, '0');
    final formattedDate = '$day/$month/$year às $hour:$minute';

    final isPurchase = item.isPurchase;
    final isCancelled = item.isCancelled;

    Color accentColor;
    if (isCancelled) {
      accentColor = context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
    } else if (isPurchase) {
      accentColor = AppColors.error;
    } else {
      accentColor = AppColors.success;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isPurchase
            ? () => _openPurchaseInvoice(context)
            : () => _openEditPayment(context),
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        child: Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radius12),
            border: Border.all(
              color: isCancelled
                  ? AppColors.error.withValues(alpha: 0.2)
                  : context.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícone do Tipo
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space8),
                  decoration: BoxDecoration(
                    color: (isCancelled
                            ? AppColors.error
                            : accentColor)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radius8),
                  ),
                  child: Icon(
                    isCancelled
                        ? AppIcons.block
                        : (isPurchase ? AppIcons.shoppingBag : AppIcons.checkCircle),
                    color: isCancelled ? AppColors.error : accentColor,
                    size: AppSpacing.icon20,
                  ),
                ),
                const Gap(AppSpacing.space12),

                // Informações Centrais (Transição de Dívida + Detalhes)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Linha 1: Transição de Dívida (ex: R$ 1.000,00 ➝ R$ 850,00) + Valor da Movimentação
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${CurrencyInputFormatter.formatCurrency(item.previousDebt)} ➝ ${CurrencyInputFormatter.formatCurrency(item.newDebt)}',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isCancelled ? context.colorScheme.onSurfaceVariant : null,
                            ),
                          ),
                          Text(
                            '${isPurchase ? "+" : "-"} ${CurrencyInputFormatter.formatCurrency(item.amount)}',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                              decoration: isCancelled ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ],
                      ),
                      const Gap(2),

                      // Linha 2: Descrição da movimentação + Badge se cancelado
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.description,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                                decoration: isCancelled ? TextDecoration.lineThrough : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCancelled) ...[
                            const Gap(AppSpacing.space4),
                            const AppTag(
                              title: 'Cancelado',
                              color: AppColors.error,
                            ),
                          ],
                        ],
                      ),
                      const Gap(4),

                      // Linha 3: Data e Operador
                      Text(
                        '$formattedDate • Por: ${item.registeredByName.isNotEmpty ? item.registeredByName : "Operador"}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
