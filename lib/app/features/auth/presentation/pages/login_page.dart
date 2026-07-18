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
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const .all(AppSpacing.radius16),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Form(
              key: _emailFormKey,
              child: AppTextfield(
                controller: _emailController,
                label: 'Email',
                hint: 'Digite seu email',
                filled: true,
                required: true,
              ),
            ),
            Gap(AppSpacing.radius8),
            Form(
              key: _passwordFormKey,
              child: AppTextfield(
                controller: _passwordController,
                label: 'Password',
                hint: 'Digite sua senha',
                filled: true,
                required: true,
                showPasswordToggle: true,
                obscureText: true,
              ),
            ),
            Gap(AppSpacing.radius24),
            ListenableBuilder(
              listenable: viewModel.loginCommand,
              builder: (context, _) {
                return AppButton(
                  //onPressed: () => viewModel.loginCommand.execute,
                  onPressed: () {
                    viewModel.loginCommand.execute(
                      (_emailController.text, _passwordController.text),
                    );
                  },
                  isLoading: viewModel.loginCommand.isRunning,
                  isFullWidth: true,
                  child: const Text('Login'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
