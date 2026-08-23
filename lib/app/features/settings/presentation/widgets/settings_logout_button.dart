import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';

class SettingsLogoutButton extends StatelessWidget {
  final AuthViewModel authViewModel;

  const SettingsLogoutButton({
    super.key,
    required this.authViewModel,
  });

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await AppDialog.showConfirmation(
      context: context,
      title: 'Sair da Conta',
      content: 'Tem certeza de que deseja encerrar a sessão no aplicativo?',
      confirmLabel: 'Sair',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );

    if (confirm == true && context.mounted) {
      await authViewModel.logoutCommand.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space12,
        ),
        child: ListenableBuilder(
          listenable: authViewModel.logoutCommand,
          builder: (context, _) {
            final isLoggingOut = authViewModel.logoutCommand.isRunning;
            return AppButton.outlined(
              label: 'Sair da Conta',
              icon: AppIcons.logout,
              isFullWidth: true,
              borderColor: context.colorScheme.error,
              backgroundColor: context.colorScheme.error.withValues(alpha: 0.08),
              isLoading: isLoggingOut,
              textStyle: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
              onPressed: isLoggingOut ? null : () => _handleLogout(context),
            );
          },
        ),
      ),
    );
  }
}
