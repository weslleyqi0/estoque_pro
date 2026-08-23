import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/user_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class UserFormPage extends StatefulWidget {
  final UserFormViewModel viewModel;
  final UserEntity? user;

  const UserFormPage({
    super.key,
    required this.viewModel,
    this.user,
  });

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  UserEntity? _currentUser;

  bool get _isEditing => _currentUser != null;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _nameController = TextEditingController(text: _currentUser?.name ?? '');
    _emailController = TextEditingController(text: _currentUser?.email ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isEditing) {
      final updatedUser = _currentUser!.copyWith(
        name: _nameController.text.trim(),
      );

      await widget.viewModel.updateUserCommand.execute(updatedUser);

      if (widget.viewModel.updateUserCommand.isSuccess && mounted) {
        AppSnackbar.success(context, 'Usuário atualizado com sucesso!');
        Navigator.pop(context);
      } else if (widget.viewModel.updateUserCommand.isFailure && mounted) {
        final error = widget.viewModel.updateUserCommand.error.toString().replaceAll('Exception: ', '');
        AppSnackbar.error(context, error);
      }
    } else {
      final data = (
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: UserRole.seller,
      );

      await widget.viewModel.createUserCommand.execute(data);

      if (widget.viewModel.createUserCommand.isSuccess && mounted) {
        AppSnackbar.success(context, 'Funcionário cadastrado com sucesso!');
        Navigator.pop(context);
      } else if (widget.viewModel.createUserCommand.isFailure && mounted) {
        final error = widget.viewModel.createUserCommand.error.toString().replaceAll('Exception: ', '');
        AppSnackbar.error(context, error);
      }
    }
  }

  Future<void> _delete() async {
    if (_currentUser == null) return;

    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'Excluir Funcionário',
      content:
          'Tem certeza que deseja remover o usuário "${_currentUser!.name}" do sistema?\nEsta ação não poderá ser desfeita.',
      confirmLabel: 'Sim, Excluir',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );

    if (confirmed == true) {
      await widget.viewModel.deleteUserCommand.execute(_currentUser!.uid);

      if (widget.viewModel.deleteUserCommand.isSuccess && mounted) {
        AppSnackbar.success(context, 'Funcionário excluído com sucesso.');
        Navigator.pop(context);
      } else if (widget.viewModel.deleteUserCommand.isFailure && mounted) {
        final error = widget.viewModel.deleteUserCommand.error.toString().replaceAll('Exception: ', '');
        AppSnackbar.error(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = _isEditing && widget.viewModel.canDelete(_currentUser!);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_isEditing ? 'Editar Funcionário' : 'Novo Funcionário'),
        actions: [
          if (canDelete)
            AppIconButton(
              icon: AppIcons.delete,
              iconColor: context.colorScheme.error,
              tooltip: 'Excluir funcionário',
              onPressed: _delete,
            ),
          const Gap(AppSpacing.space4),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextfield(
                        label: 'Nome Completo',
                        hint: 'Ex: João da Silva',
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
                      const Gap(AppSpacing.space24),
                      AppTextfield(
                        label: 'E-mail',
                        hint: 'usuario@empresa.com',
                        required: true,
                        enabled: !_isEditing,
                        readOnly: _isEditing,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'E-mail é obrigatório';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Informe um e-mail válido';
                          }
                          return null;
                        },
                      ),
                      if (!_isEditing) ...[
                        const Gap(AppSpacing.space24),
                        AppTextfield(
                          label: 'Senha de Acesso',
                          hint: 'Mínimo de 6 caracteres',
                          required: true,
                          controller: _passwordController,
                          obscureText: true,
                          showPasswordToggle: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Senha é obrigatória';
                            }
                            if (value.trim().length < 6) {
                              return 'A senha deve ter no mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space16),
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    widget.viewModel.createUserCommand,
                    widget.viewModel.updateUserCommand,
                  ]),
                  builder: (context, _) {
                    final isLoading =
                        widget.viewModel.createUserCommand.isRunning || widget.viewModel.updateUserCommand.isRunning;
                    return AppButton.primary(
                      label: _isEditing ? 'Salvar Alterações' : 'Cadastrar Funcionário',
                      isFullWidth: true,
                      isLoading: isLoading,
                      onPressed: _save,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
