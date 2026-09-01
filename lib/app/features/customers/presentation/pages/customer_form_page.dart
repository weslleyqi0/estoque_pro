import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/utils/cpf_input_formatter.dart';
import 'package:estoque_pro/app/core/utils/phone_input_formatter.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/presentation/viewmodels/customers_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomerFormPage extends StatefulWidget {
  final CustomersFormViewModel Function() viewModelFactory;
  final CustomerEntity? customer;

  const CustomerFormPage({
    super.key,
    required this.viewModelFactory,
    this.customer,
  });

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final CustomersFormViewModel viewModel;
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cpfController;
  late final TextEditingController _phoneController;
  bool _isActive = true;
  CustomerEntity? _currentCustomer;

  bool get _isEditing => _currentCustomer != null;

  @override
  void initState() {
    super.initState();
    viewModel = widget.viewModelFactory();
    _currentCustomer = widget.customer;
    _nameController = TextEditingController(text: _currentCustomer?.name ?? '');
    _addressController = TextEditingController(text: _currentCustomer?.address ?? '');
    _cpfController = TextEditingController(text: _currentCustomer?.cpf ?? '');
    _phoneController = TextEditingController(text: _currentCustomer?.phone ?? '');
    _isActive = _currentCustomer?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final customer = CustomerEntity(
      id: _currentCustomer?.id ?? '',
      name: _nameController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      cpf: _cpfController.text.trim().isEmpty ? null : _cpfController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      isActive: _isActive,
    );

    if (_isEditing) {
      await viewModel.updateCustomerCommand.execute(customer);
      if (viewModel.updateCustomerCommand.isSuccess && mounted) {
        Navigator.pop(context);
      }
    } else {
      await viewModel.saveCustomerCommand.execute(customer);
      if (viewModel.saveCustomerCommand.isSuccess && mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _delete() async {
    if (_currentCustomer == null) return;

    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Excluir cliente',
      content: 'Tem certeza que deseja excluir o cliente "${_currentCustomer!.name}"?',
      confirmLabel: 'Excluir',
      cancelLabel: 'Cancelar',
      confirmColor: AppColors.error,
    );

    if (confirmed == true && mounted) {
      await viewModel.deleteCustomerCommand.execute(_currentCustomer!.id);
      if (viewModel.deleteCustomerCommand.isSuccess && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_isEditing ? 'Editar Cliente' : 'Novo Cliente'),
        actions: [
          AppIconButton(
            icon: AppIcons.save,
            onPressed: () => _save(),
          ),
          if (_currentCustomer != null)
            AppIconButton(
              icon: AppIcons.delete,
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
              label: 'Nome do Cliente',
              hint: 'Ex: Supermercado Silva ou Maria Oliveira',
              required: true,
              controller: _nameController,
            ),
            const Gap(AppSpacing.space16),
            AppTextfield(
              label: 'Endereço',
              hint: 'Ex: Rua das Flores, 123 - Centro',
              controller: _addressController,
            ),
            const Gap(AppSpacing.space16),
            AppTextfield(
              label: 'CPF',
              hint: '000.000.000-00',
              controller: _cpfController,
              keyboardType: TextInputType.number,
              inputFormatters: [CpfInputFormatter()],
            ),
            const Gap(AppSpacing.space16),
            AppTextfield(
              label: 'Telefone / WhatsApp',
              hint: '(00) 00000-0000',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [PhoneInputFormatter()],
            ),
            const Gap(AppSpacing.space24),
            AppSwitchTitle(
              title: 'Cliente Ativo',
              subtitle: 'Permite selecionar este cliente no sistema',
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            const Gap(AppSpacing.space32),
            ListenableBuilder(
              listenable: Listenable.merge([
                viewModel.saveCustomerCommand,
                viewModel.updateCustomerCommand,
              ]),
              builder: (context, _) {
                final isLoading =
                    viewModel.saveCustomerCommand.isRunning ||
                    viewModel.updateCustomerCommand.isRunning;
                return AppButton.primary(
                  label: _isEditing ? 'Salvar Alterações' : 'Salvar Cliente',
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
