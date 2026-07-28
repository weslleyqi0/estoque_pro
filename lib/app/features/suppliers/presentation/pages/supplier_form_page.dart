import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/presentation/viewmodels/suppliers_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

class SupplierFormPage extends StatefulWidget {
  final SupplierEntity? supplier;

  const SupplierFormPage({
    super.key,
    this.supplier,
  });

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  final _viewModel = getIt<SuppliersFormViewmodel>();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cnpjController;
  late final TextEditingController _phoneController;
  bool _isActive = true;
  SupplierEntity? _currentSupplier;

  bool get _isEditing => _currentSupplier != null;

  @override
  void initState() {
    super.initState();
    _currentSupplier = widget.supplier;
    _nameController = TextEditingController(text: _currentSupplier?.name ?? '');
    _cnpjController = TextEditingController(text: _currentSupplier?.cnpj ?? '');
    _phoneController = TextEditingController(text: _currentSupplier?.phone ?? '');
    _isActive = _currentSupplier?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnpjController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final supplier = SupplierEntity(
      id: _currentSupplier?.id ?? '',
      name: _nameController.text.trim(),
      cnpj: _cnpjController.text.trim().isEmpty ? null : _cnpjController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      isActive: _isActive,
    );

    if (_isEditing) {
      await _viewModel.updateSupplierCommand.execute(supplier);
      if (_viewModel.updateSupplierCommand.isSuccess && mounted) {
        Navigator.pop(context);
      }
    } else {
      await _viewModel.saveSupplierCommand.execute(supplier);
      if (_viewModel.saveSupplierCommand.isSuccess && mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _delete() async {
    if (_currentSupplier == null) return;

    await _viewModel.deleteSupplierCommand.execute(_currentSupplier!.id);

    if (_viewModel.deleteSupplierCommand.isSuccess && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_isEditing ? 'Editar Fornecedor' : 'Novo Fornecedor'),
        actions: [
          AppIconButton(
            icon: Symbols.save_rounded,
            onPressed: () => _save(),
          ),
          if (_currentSupplier != null)
            AppIconButton(
              icon: Symbols.delete,
              onPressed: () => _delete(),
            ),
          const Gap(AppSpacing.space4),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          children: [
            AppTextfield(
              label: 'Nome',
              hint: 'Nome do fornecedor',
              required: true,
              controller: _nameController,
              keyboardType: TextInputType.name,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                return null;
              },
            ),
            const Gap(AppSpacing.space16),
            AppTextfield(
              label: 'CNPJ',
              hint: '00.000.000/0000-00',
              controller: _cnpjController,
              keyboardType: TextInputType.number,
              prefixIcon: Symbols.home_work_rounded,
            ),
            const Gap(AppSpacing.space16),
            AppTextfield(
              label: 'Telefone',
              hint: '(00) 00000-0000',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Symbols.phone,
            ),
            const Gap(AppSpacing.space24),
            AppSwitchTitle(
              title: 'Fornecedor Ativo',
              subtitle: 'Permite usar este fornecedor no sistema',
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            const Gap(AppSpacing.space32),
            ListenableBuilder(
              listenable: Listenable.merge([
                _viewModel.saveSupplierCommand,
                _viewModel.updateSupplierCommand,
              ]),
              builder: (context, _) {
                final isLoading =
                    _viewModel.saveSupplierCommand.isRunning || _viewModel.updateSupplierCommand.isRunning;
                return AppButton.primary(
                  label: _isEditing ? 'Salvar Alterações' : 'Salvar Fornecedor',
                  isFullWidth: true,
                  isLoading: isLoading,
                  onPressed: _save,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
