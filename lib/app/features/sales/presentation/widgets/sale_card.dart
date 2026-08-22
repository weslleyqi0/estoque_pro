import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/domain/entities/sale_entity.dart';
import 'package:estoque_pro/app/features/sales/presentation/viewmodels/sales_viewmodel.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_card/sale_card_actions.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_card/sale_card_edit_history.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_card/sale_card_expanded_items.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_card/sale_card_header.dart';
import 'package:estoque_pro/app/features/sales/presentation/widgets/sale_card/sale_card_summary.dart';
import 'package:flutter/material.dart';

class SaleCard extends StatelessWidget {
  final SaleEntity sale;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final AuthViewModel authViewModel;
  final SalesViewModel salesViewModel;

  const SaleCard({
    super.key,
    required this.sale,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.authViewModel,
    required this.salesViewModel,
  });

  @override
  Widget build(BuildContext context) {
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
              padding: const .only(left: AppSpacing.space16, right: AppSpacing.space4, top: AppSpacing.space16),
              child: SaleCardHeader(sale: sale, authViewModel: authViewModel),
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
                  SaleCardSummary(sale: sale, isExpanded: isExpanded),
                  if (isExpanded) ...[
                    SaleCardExpandedItems(sale: sale),
                    SaleCardEditHistory(
                      sale: sale,
                      authViewModel: authViewModel,
                    ),
                    SaleCardActions(
                      sale: sale,
                      authViewModel: authViewModel,
                      salesViewModel: salesViewModel,
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
