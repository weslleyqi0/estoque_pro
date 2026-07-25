import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

class InactivePage extends StatelessWidget {
  final AuthViewModel viewModel;

  const InactivePage({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Symbols.block,
                size: 100,
                color: context.colorScheme.error,
                weight: 700,
              ),
              const Gap(AppSpacing.space4),
              Text(
                'Conta Inativa',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.error,
                ),
              ),
              const Gap(AppSpacing.space12),
              Text(
                'Esta conta foi desativada pelo administrador. Você não pode acessar o sistema ou realizar operações no momento.',
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge,
              ),
              const Spacer(),
              ListenableBuilder(
                listenable: viewModel.logoutCommand,
                builder: (context, _) {
                  return AppButton(
                    onPressed: () => viewModel.logoutCommand.execute(),
                    label: 'Sair da Conta',
                    isLoading: viewModel.logoutCommand.isRunning,
                    isFullWidth: true,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
