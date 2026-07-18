import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class LoginPage extends StatefulWidget {
  final AuthViewModel viewModel;

  const LoginPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthViewModel get viewModel => widget.viewModel;
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const .all(AppSpacing.radius16),
        child: ListenableBuilder(
          listenable: viewModel.loginCommand,
          builder: (context, _) {
            final hasError = viewModel.loginCommand.isFailure;
            final errorMsg = hasError ? viewModel.loginCommand.error.toString().replaceAll('Exception: ', '') : null;

            return Column(
              mainAxisAlignment: .center,
              children: [
                AppTextfield(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Digite seu email',
                  filled: true,
                  required: true,
                ),
                Gap(AppSpacing.radius8),
                AppTextfield(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Digite sua senha',
                  filled: true,
                  required: true,
                  showPasswordToggle: true,
                  obscureText: true,
                ),
                Gap(AppSpacing.radius24),
                AppButton(
                  onPressed: () {
                    viewModel.loginCommand.execute((
                      email: _emailController.text,
                      password: _passwordController.text,
                    ));
                  },
                  label: 'Login',
                  isLoading: viewModel.loginCommand.isRunning,
                  isFullWidth: true,
                ),
                if (hasError) ...[
                  Gap(AppSpacing.radius16),
                  Text(
                    errorMsg ?? '',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: .center,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
