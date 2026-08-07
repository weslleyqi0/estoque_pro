import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/widgets/suppliers_item.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SupplierBottomSheet extends StatelessWidget {
  final SuppliersViewModel suppliersVM;
  final void Function(ProductSupplierEntity supplier) onSupplierSelected;

  const SupplierBottomSheet({
    super.key,
    required this.suppliersVM,
    required this.onSupplierSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required SuppliersViewModel suppliersVM,
    required void Function(ProductSupplierEntity supplier) onSupplierSelected,
  }) {
    return AppBottomSheet.show(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SupplierBottomSheet(
          suppliersVM: suppliersVM,
          onSupplierSelected: onSupplierSelected,
        );
      },
    );
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
                      TextButton.icon(
                        onPressed: () => context.push(AppRoutes.supplierForm),
                        icon: const Icon(Symbols.add_rounded, size: AppSpacing.icon24, weight: 600),
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
                    listenable: suppliersVM,
                    builder: (context, _) {
                      if (suppliersVM.state == SuppliersLoadState.loading) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.space24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (suppliersVM.suppliers.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.space24),
                          child: Center(child: Text('Nenhum fornecedor cadastrado.')),
                        );
                      }
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: suppliersVM.suppliers.length,
                        itemBuilder: (context, index) {
                          final sup = suppliersVM.suppliers[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                            child: SuppliersItem(
                              supplier: sup,
                              showProductsTag: false,
                              onTap: () {
                                onSupplierSelected(ProductSupplierEntity(id: sup.id, name: sup.name));
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
