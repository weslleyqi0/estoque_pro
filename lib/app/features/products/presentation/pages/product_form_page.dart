import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/core/utils/currency_input_formatter.dart';
import 'package:estoque_pro/app/core/utils/string_extensions.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:estoque_pro/app/features/products/domain/entities/product_entity.dart';
import 'package:estoque_pro/app/features/products/presentation/viewmodels/products_form_viewmodel.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/categories_bottom_sheet.dart';
import 'package:estoque_pro/app/features/products/presentation/widgets/supplier_bottom_sheet.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProductFormPage extends StatefulWidget {
  final ProductEntity? product;

  const ProductFormPage({
    super.key,
    this.product,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _viewModel = getIt<ProductsFormViewModel>();
  final _categoriesVM = getIt<CategoriesViewModel>();
  final _suppliersVM = getIt<SuppliersViewModel>();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _imgUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _minStockController = TextEditingController();
  final _initialStockController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();

    _viewModel.init(widget.product);

    _setToForm();

    _loadDependencies();
  }

  void _loadDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_categoriesVM.state == CategoriesLoadState.idle) {
        _categoriesVM.listenAll();
      }

      if (_suppliersVM.state == SuppliersLoadState.idle) {
        _suppliersVM.listenAll();
      }
    });
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

    _minStockController.text = currentProduct.minStock.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imgUrlController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _minStockController.dispose();
    _initialStockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final price = _priceController.text.toDoubleOr();
    final minStock = _minStockController.text.toIntOr();

    final success = await _viewModel.saveForm(
      name: _nameController.text,
      imgUrl: _imgUrlController.text,
      description: _descriptionController.text,
      barcode: _barcodeController.text,
      price: price,
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

  Future<void> _delete() async {
    final confirm = await AppDialog.showConfirmation(
      context: context,
      title: 'Excluir Produto',
      content: 'Tem certeza que deseja excluir este produto? Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      isDestructive: true,
    );

    if (confirm == true) {
      final success = await _viewModel.deleteCurrentProduct();
      if (success && mounted) {
        context.go(AppRoutes.products);
        AppSnackbar.success(context, 'Produto excluído com sucesso!');
      }
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
            icon: Symbols.save_rounded,
            onPressed: () => _save(),
          ),
          if (_viewModel.isEditing)
            AppIconButton(
              icon: Symbols.delete,
              iconColor: context.colorScheme.error,
              onPressed: () => _delete(),
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
                return Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSpacing.space16),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: url.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(Symbols.broken_image_rounded, size: 48),
                          ),
                        )
                      : const Center(
                          child: Icon(Symbols.image_rounded, size: 48),
                        ),
                );
              },
            ),
            const Gap(AppSpacing.space16),
            AppTextfield(
              label: 'URL da Imagem',
              hint: 'https://...',
              controller: _imgUrlController,
              keyboardType: TextInputType.url,
            ),
            const Gap(AppSpacing.space24),

            AppTextfield(
              label: 'Nome do Produto',
              hint: 'Nome',
              required: true,
              controller: _nameController,
              keyboardType: TextInputType.name,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Nome é obrigatório';
                return null;
              },
            ),
            const Gap(AppSpacing.space16),

            AppTextfield(
              label: 'Código de Barras',
              hint: '1234567890123',
              controller: _barcodeController,
              keyboardType: TextInputType.number,
            ),
            const Gap(AppSpacing.space16),

            AppTextArea(
              label: 'Descrição',
              hint: 'Detalhes do produto...',
              controller: _descriptionController,
            ),
            const Gap(AppSpacing.space16),

            AppTextfield(
              label: 'Preço',
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
            const Gap(AppSpacing.space16),

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
                      prefixIcon: Symbols.remove,
                      onPrefixIconPressed: () {
                        int val = _initialStockController.text.toIntOr();
                        if (val > 0) {
                          _initialStockController.text = (val - 1).toString();
                        }
                      },
                      suffixIcon: Symbols.add,
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
                    prefixIcon: Symbols.remove,
                    onPrefixIconPressed: () {
                      int val = _minStockController.text.toIntOr();
                      if (val > 0) {
                        _minStockController.text = (val - 1).toString();
                      }
                    },
                    suffixIcon: Symbols.add,
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
                  leading: const Icon(Symbols.stacks_rounded, size: AppSpacing.icon40),
                  title: const Text('Categorias'),
                  subtitle: Text(
                    categories.isEmpty ? 'Nenhuma selecionada' : categories.map((e) => e.name).join(', '),
                  ),
                  trailing: const Icon(Symbols.chevron_right_rounded),
                  onTap: () {
                    CategoriesBottomSheet.show(
                      context: context,
                      categoriesVM: _categoriesVM,
                      initialSelectedCategories: categories,
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
                  leading: const Icon(Symbols.local_shipping_rounded, size: AppSpacing.icon40),
                  title: const Text('Fornecedor'),
                  subtitle: Text(supplier?.name ?? 'Nenhum selecionado'),
                  trailing: const Icon(Symbols.chevron_right_rounded),
                  onTap: () {
                    SupplierBottomSheet.show(
                      context: context,
                      suppliersVM: _suppliersVM,
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
                _viewModel.saveProductCommand,
                _viewModel.updateProductCommand,
                _viewModel.deleteProductCommand,
              ]),
              builder: (context, _) {
                final isLoading = _viewModel.saveProductCommand.isRunning || _viewModel.updateProductCommand.isRunning;
                return Column(
                  children: [
                    AppButton.primary(
                      label: _viewModel.isEditing ? 'Salvar Alterações' : 'Salvar Produto',
                      isFullWidth: true,
                      isLoading: isLoading,
                      onPressed: _save,
                    ),
                    if (_viewModel.isEditing) ...[
                      const Gap(AppSpacing.space16),
                      AppButton.outlined(
                        label: 'Excluir Produto',
                        isFullWidth: true,
                        isLoading: _viewModel.deleteProductCommand.isRunning,
                        onPressed: _delete,
                      ),
                    ],
                  ],
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
