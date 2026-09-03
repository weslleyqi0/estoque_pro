import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_viewmodel.dart';
import 'package:estoque_pro/app/features/deliveries/domain/entities/delivery_entity.dart';
import 'package:estoque_pro/app/features/deliveries/presentation/viewmodels/deliveries_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/edit_sale_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_card/sale_card_actions.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_card/sale_card_edit_history.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_card/sale_card_expanded_items.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_card/sale_card_header.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_card/sale_card_summary.dart';
import 'package:flutter/material.dart';

class SaleCard extends StatelessWidget {
  final SaleEntity sale;
  final DeliveryEntity? delivery;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final AuthViewModel authViewModel;
  final SalesViewModel salesViewModel;
  final DeliveriesViewModel deliveriesViewModel;
  final EditSaleViewModel Function()? editSaleViewModelFactory;
  final CustomersViewModel Function()? customersViewModelFactory;
  final CustomerDebtsViewModel Function()? debtsViewModelFactory;

  const SaleCard({
    super.key,
    required this.sale,
    this.delivery,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.authViewModel,
    required this.salesViewModel,
    required this.deliveriesViewModel,
    this.editSaleViewModelFactory,
    this.customersViewModelFactory,
    this.debtsViewModelFactory,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDelivery = delivery ?? salesViewModel.getDeliveryForSale(sale.id, sale.saleNumber);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.space12),
      color: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        side: BorderSide(
          color: isExpanded ? context.colorScheme.primary : context.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onToggleExpand,
        overlayColor: WidgetStateProperty.all(context.colorScheme.primary.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        child: Column(
          children: [
            Padding(
              padding: const .only(left: AppSpacing.space16, right: AppSpacing.space8, top: AppSpacing.space16),
              child: SaleCardHeader(
                sale: sale,
                delivery: effectiveDelivery,
                authViewModel: authViewModel,
                deliveriesViewModel: deliveriesViewModel,
                editSaleViewModelFactory: editSaleViewModelFactory,
                customersViewModelFactory: customersViewModelFactory,
                debtsViewModelFactory: debtsViewModelFactory,
              ),
            ),
            Padding(
              padding: const .only(
                left: AppSpacing.space16,
                right: AppSpacing.space16,
                top: AppSpacing.space4,
                bottom: AppSpacing.space16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SaleCardSummary(
                    sale: sale,
                    delivery: effectiveDelivery,
                    isExpanded: isExpanded,
                  ),
                  if (isExpanded) ...[
                    SaleCardExpandedItems(sale: sale),
                    SaleCardEditHistory(
                      sale: sale,
                      authViewModel: authViewModel,
                    ),
                    SaleCardActions(
                      sale: sale,
                      delivery: effectiveDelivery,
                      authViewModel: authViewModel,
                      salesViewModel: salesViewModel,
                      editSaleViewModelFactory: editSaleViewModelFactory,
                      customersViewModelFactory: customersViewModelFactory,
                      debtsViewModelFactory: debtsViewModelFactory,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
