import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

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
                AppIcons.lockPerson,
                size: 80,
                color: context.colorScheme.error,
                weight: 600,
              ),
              const Gap(AppSpacing.space24),
              Text(
                'Acesso Negado',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.error,
                ),
              ),
              const Gap(AppSpacing.space12),
              Text(
                'Você não tem as permissões necessárias para acessar esta página. Entre em contato com o administrador.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              AppButton(
                onPressed: () => context.go('/home'),
                label: 'Voltar para o Início',
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
