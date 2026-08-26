import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customer_debts_viewmodel.dart';
import 'package:estoque_pro/app/features/customers/presentation/widgets/customer_statement_list.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomerAllStatementsBottomSheet extends StatefulWidget {
  final CustomerEntity customer;
  final CustomerDebtsViewModel debtsViewModel;

  const CustomerAllStatementsBottomSheet({
    super.key,
    required this.customer,
    required this.debtsViewModel,
  });

  static Future<void> show({
    required BuildContext context,
    required CustomerEntity customer,
    required CustomerDebtsViewModel debtsViewModel,
  }) {
    return AppBottomSheet.show(
      context: context,
      isScrollControlled: true,
      builder: (_) => CustomerAllStatementsBottomSheet(
        customer: customer,
        debtsViewModel: debtsViewModel,
      ),
    );
  }

  @override
  State<CustomerAllStatementsBottomSheet> createState() => _CustomerAllStatementsBottomSheetState();
}

class _CustomerAllStatementsBottomSheetState extends State<CustomerAllStatementsBottomSheet> {
  bool _isFullyExpanded = true;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        final isFullyExpanded = notification.extent >= 0.99;
        if (_isFullyExpanded != isFullyExpanded) {
          setState(() {
            _isFullyExpanded = isFullyExpanded;
          });
        }
        return false;
      },
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 1.0,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return ListenableBuilder(
            listenable: widget.debtsViewModel,
            builder: (context, _) {
              final statement = widget.debtsViewModel.getCustomerStatement(widget.customer.id);

              return SafeArea(
                top: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Fixo no Topo
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.space16,
                        right: AppSpacing.space16,
                        top: _isFullyExpanded ? AppSpacing.appBarHeight : AppSpacing.space12,
                      ),
                      child: Column(
                        children: [
                          // Handle bar
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
                          const Gap(AppSpacing.space12),

                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Todas as Movimentações',
                                      style: context.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.customer.name,
                                      style: context.textTheme.bodyMedium?.copyWith(
                                        color: context.colorScheme.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              CloseButton(onPressed: () => Navigator.pop(context)),
                            ],
                          ),
                          const Gap(AppSpacing.space8),
                          const Divider(),
                        ],
                      ),
                    ),

                    // Corpo com Scroll
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.only(
                          left: AppSpacing.space16,
                          right: AppSpacing.space16,
                          top: AppSpacing.space8,
                          bottom: AppSpacing.space24,
                        ),
                        child: CustomerStatementList(
                          statementItems: statement,
                          customerName: widget.customer.name,
                          debtsViewModel: widget.debtsViewModel,
                          showViewAll: false,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
