import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/widgets/suppliers_item.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SupplierBottomSheet extends StatefulWidget {
  final SuppliersViewModel suppliersVM;
  final void Function(ProductSupplierEntity supplier) onSupplierSelected;
  final bool canManageSuppliers;

  const SupplierBottomSheet({
    super.key,
    required this.suppliersVM,
    required this.onSupplierSelected,
    this.canManageSuppliers = true,
  });

  static Future<void> show({
    required BuildContext context,
    required SuppliersViewModel suppliersVM,
    required void Function(ProductSupplierEntity supplier) onSupplierSelected,
    bool canManageSuppliers = true,
  }) {
    return AppBottomSheet.show(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SupplierBottomSheet(
          suppliersVM: suppliersVM,
          onSupplierSelected: onSupplierSelected,
          canManageSuppliers: canManageSuppliers,
        );
      },
    );
  }

  @override
  State<SupplierBottomSheet> createState() => _SupplierBottomSheetState();
}

class _SupplierBottomSheetState extends State<SupplierBottomSheet> {
  @override
  void initState() {
    super.initState();
    widget.suppliersVM.listenAll();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: AppSpacing.space16, bottom: AppSpacing.space16),
                    decoration: BoxDecoration(
                      color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: AppSpacing.space8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fornecedores',
                        style: context.textTheme.titleMedium,
                      ),
                      if (widget.canManageSuppliers)
                        TextButton.icon(
                          onPressed: () => context.push(AppRoutes.supplierForm),
                          icon: const Icon(AppIcons.add, size: AppSpacing.icon24, weight: 600),
                          label: Text(
                            'Novo',
                            style: context.textTheme.titleSmall?.copyWith(color: context.colorScheme.primary),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListenableBuilder(
                    listenable: widget.suppliersVM,
                    builder: (context, _) {
                      if (widget.suppliersVM.state == SuppliersLoadState.loading) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.space24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (widget.suppliersVM.suppliers.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.space24),
                          child: Center(child: Text('Nenhum fornecedor cadastrado.')),
                        );
                      }
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: widget.suppliersVM.suppliers.length,
                        itemBuilder: (context, index) {
                          final sup = widget.suppliersVM.suppliers[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                            child: SuppliersItem(
                              supplier: sup,
                              showProductsTag: false,
                              onTap: () {
                                widget.onSupplierSelected(ProductSupplierEntity(id: sup.id, name: sup.name));
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
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
