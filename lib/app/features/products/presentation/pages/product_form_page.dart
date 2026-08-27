import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/core/utils/string_extensions.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_form_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/categories_bottom_sheet.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/supplier_bottom_sheet.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ProductFormPage extends StatefulWidget {
  final ProductEntity? product;
  final ProductsFormViewModel viewModel;
  final CategoriesViewModel categoriesVM;
  final SuppliersViewModel suppliersVM;
  final AuthViewModel authViewModel;

  const ProductFormPage({
    super.key,
    this.product,
    required this.viewModel,
    required this.categoriesVM,
    required this.suppliersVM,
    required this.authViewModel,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  ProductsFormViewModel get _viewModel => widget.viewModel;
  CategoriesViewModel get _categoriesVM => widget.categoriesVM;
  SuppliersViewModel get _suppliersVM => widget.suppliersVM;
  AuthViewModel get _authViewModel => widget.authViewModel;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _imgUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _minStockController = TextEditingController();
  final _initialStockController = TextEditingController(text: '0');

  bool get _canViewCostPrice => _authViewModel.currentUser?.hasPermission(UserPermission.editProducts) ?? false;

  @override
  void initState() {
    super.initState();

    _viewModel.init(widget.product);

    _setToForm();

    _loadDependencies();
  }

  void _loadDependencies() {
    _categoriesVM.listenAll();
    _suppliersVM.listenAll();
  }

  void _setToForm() {
    final currentProduct = widget.product;
    if (currentProduct == null) return;

    _nameController.text = currentProduct.name;
    _imgUrlController.text = currentProduct.imgUrl;
    _descriptionController.text = currentProduct.description;
    _barcodeController.text = currentProduct.barcode;

    String initialPrice = CurrencyInputFormatter.formatCurrency(currentProduct.price);
    _priceController.text = initialPrice;

    String initialCostPrice = CurrencyInputFormatter.formatCurrency(currentProduct.costPrice);
    _costPriceController.text = initialCostPrice;

    _minStockController.text = currentProduct.minStock.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imgUrlController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _minStockController.dispose();
    _initialStockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final price = _priceController.text.toDoubleOr();
    final costPrice = _costPriceController.text.toDoubleOr();
    final minStock = _minStockController.text.toIntOr();

    final success = await _viewModel.saveForm(
      name: _nameController.text,
      imgUrl: _imgUrlController.text,
      description: _descriptionController.text,
      barcode: _barcodeController.text,
      price: price,
      costPrice: costPrice,
      minStock: minStock,
      initialStock: _initialStockController.text.toIntOr(),
    );

    if (success && mounted) {
      context.pop();
    } else if (mounted) {
      final error = _viewModel.isEditing ? _viewModel.updateProductCommand.error : _viewModel.saveProductCommand.error;

      if (error != null) {
        AppSnackbar.error(context, error.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _scanBarcode() async {
    final scannedCode = await context.push<String>(AppRoutes.saleScanner);
    if (scannedCode != null && mounted) {
      _barcodeController.text = scannedCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_viewModel.isEditing ? 'Editar Produto' : 'Novo Produto'),
        actions: [
          AppIconButton(
            icon: AppIcons.save,
            tooltip: 'Salvar',
            onPressed: () => _save(),
          ),
          const Gap(AppSpacing.space8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          children: [
            ValueListenableBuilder(
              valueListenable: _imgUrlController,
              builder: (context, value, _) {
                final url = value.text.trim();
                return Center(
                  child: AppNetworkImage(
                    imageUrl: url,
                    size: 200,
                    fit: BoxFit.contain,
                    placeholderIcon: url.isNotEmpty ? AppIcons.brokenImage : AppIcons.image,
                    placeholderIconSize: 48,
                  ),
                );
              },
            ),
            const Gap(AppSpacing.space16),

            Text('Identificação', style: context.textTheme.labelLarge),
            const Gap(AppSpacing.space8),
            AppTextfield(
              label: 'Nome do Produto',
              hint: 'Ex: Camiseta Básica',
              required: true,
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                return null;
              },
            ),
            const Gap(AppSpacing.space16),

            AppTextfield(
              label: 'URL da Imagem',
              hint: 'https://exemplo.com/imagem.png',
              controller: _imgUrlController,
              suffixIcon: Icons.link,
            ),
            const Gap(AppSpacing.space16),

            AppTextfield(
              label: 'Código de Barras',
              hint: '7891234567890',
              controller: _barcodeController,
              suffixIcon: AppIcons.barcodeScanner,
              onSuffixIconPressed: _scanBarcode,
            ),
            const Gap(AppSpacing.space16),

            AppTextfield(
              label: 'Descrição',
              hint: 'Detalhes do produto...',
              controller: _descriptionController,
            ),
            const Gap(AppSpacing.space16),

            Text('Preços & Valores', style: context.textTheme.labelLarge),
            const Gap(AppSpacing.space8),
            Row(
              children: [
                if (_canViewCostPrice) ...[
                  Expanded(
                    child: AppTextfield(
                      label: 'Preço de Custo',
                      hint: 'R\$ 0,00',
                      textAlign: TextAlign.center,
                      controller: _costPriceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                    ),
                  ),
                ],
                const Gap(AppSpacing.space16),
                Expanded(
                  child: AppTextfield(
                    label: 'Preço de Venda',
                    hint: 'R\$ 0,00',
                    required: true,
                    textAlign: TextAlign.center,
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyInputFormatter()],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Obrigatório';
                      if (value.toDoubleOr() <= 0) return 'Inválido';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.space8),

            if (_canViewCostPrice) ...[
              ListenableBuilder(
                listenable: Listenable.merge([_priceController, _costPriceController]),
                builder: (context, _) {
                  final salePrice = _priceController.text.toDoubleOr();
                  final costPrice = _costPriceController.text.toDoubleOr();
                  final profit = salePrice - costPrice;
                  final margin = salePrice > 0 ? (profit / salePrice) * 100 : 0.0;
                  final isPositive = profit >= 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space12,
                      vertical: AppSpacing.space8,
                    ),
                    decoration: BoxDecoration(
                      color: (isPositive ? context.colorScheme.primary : context.colorScheme.error).withValues(
                        alpha: 0.08,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radius8),
                      border: Border.all(
                        color: (isPositive ? context.colorScheme.primary : context.colorScheme.error).withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lucro Unitário Estimado:',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${CurrencyInputFormatter.formatCurrency(profit)} (${margin.toStringAsFixed(1)}%)',
                          style: context.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isPositive ? context.colorScheme.primary : context.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Gap(AppSpacing.space16),
            ] else ...[
              const Gap(AppSpacing.space8),
            ],

            Text('Estoque', style: context.textTheme.labelLarge),
            const Gap(AppSpacing.space8),
            Row(
              children: [
                if (!_viewModel.isEditing) ...[
                  Expanded(
                    child: AppTextfield(
                      label: 'Estoque Inicial',
                      hint: '0',
                      required: true,
                      textAlign: TextAlign.center,
                      controller: _initialStockController,
                      keyboardType: TextInputType.number,
                      prefixIcon: AppIcons.remove,
                      onPrefixIconPressed: () {
                        int val = _initialStockController.text.toIntOr();
                        if (val > 0) {
                          _initialStockController.text = (val - 1).toString();
                        }
                      },
                      suffixIcon: AppIcons.add,
                      onSuffixIconPressed: () {
                        int val = _initialStockController.text.toIntOr();
                        _initialStockController.text = (val + 1).toString();
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Obrigatório';
                        if (int.tryParse(value) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const Gap(AppSpacing.space16),
                ],
                Expanded(
                  child: AppTextfield(
                    label: 'Estoque Mínimo',
                    hint: '0',
                    required: true,
                    textAlign: TextAlign.center,
                    controller: _minStockController,
                    keyboardType: TextInputType.number,
                    prefixIcon: AppIcons.remove,
                    onPrefixIconPressed: () {
                      int val = _minStockController.text.toIntOr();
                      if (val > 0) {
                        _minStockController.text = (val - 1).toString();
                      }
                    },
                    suffixIcon: AppIcons.add,
                    onSuffixIconPressed: () {
                      int val = _minStockController.text.toIntOr();
                      _minStockController.text = (val + 1).toString();
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Obrigatório';
                      if (int.tryParse(value) == null) return 'Inválido';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.space24),

            Text('Relacionamentos', style: context.textTheme.labelLarge),
            const Gap(AppSpacing.space8),
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                final categories = _viewModel.selectedCategories;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(AppIcons.stacks, size: AppSpacing.icon40),
                  title: const Text('Categorias'),
                  subtitle: Text(
                    categories.isEmpty ? 'Nenhuma selecionada' : categories.map((e) => e.name).join(', '),
                  ),
                  trailing: const Icon(AppIcons.chevronRight),
                  onTap: () {
                    final canManageCategories =
                        _authViewModel.currentUser?.hasPermission(UserPermission.manageCategories) ?? false;
                    CategoriesBottomSheet.show(
                      context: context,
                      categoriesVM: _categoriesVM,
                      initialSelectedCategories: categories,
                      canManageCategories: canManageCategories,
                      onCategoriesChanged: (newCategories) {
                        _viewModel.setCategories(newCategories);
                      },
                    );
                  },
                );
              },
            ),
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                final supplier = _viewModel.selectedSupplier;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(AppIcons.localShipping, size: AppSpacing.icon40),
                  title: const Text('Fornecedor'),
                  subtitle: Text(supplier?.name ?? 'Nenhum selecionado'),
                  trailing: const Icon(AppIcons.chevronRight),
                  onTap: () {
                    final canManageSuppliers =
                        _authViewModel.currentUser?.hasPermission(UserPermission.manageSuppliers) ?? false;
                    SupplierBottomSheet.show(
                      context: context,
                      suppliersVM: _suppliersVM,
                      canManageSuppliers: canManageSuppliers,
                      onSupplierSelected: (sup) {
                        _viewModel.setSupplier(sup);
                      },
                    );
                  },
                );
              },
            ),
            const Gap(AppSpacing.space24),

            ListenableBuilder(
              listenable: Listenable.merge([
                _viewModel,
                _viewModel.saveProductCommand,
                _viewModel.updateProductCommand,
              ]),
              builder: (context, _) {
                final isLoading = _viewModel.saveProductCommand.isRunning || _viewModel.updateProductCommand.isRunning;
                return AppButton.primary(
                  label: _viewModel.isEditing ? 'Salvar Alterações' : 'Salvar Produto',
                  isFullWidth: true,
                  isLoading: isLoading,
                  onPressed: _save,
                );
              },
            ),
            const Gap(AppSpacing.space32),
          ],
        ),
      ),
    );
  }
}
