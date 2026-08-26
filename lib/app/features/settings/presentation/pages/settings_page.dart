import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:estoque_pro/app/features/settings/presentation/viewmodels/theme_viewmodel.dart';
import 'package:estoque_pro/app/features/settings/presentation/widgets/settings_biometric_tile.dart';
import 'package:estoque_pro/app/features/settings/presentation/widgets/settings_logout_button.dart';
import 'package:estoque_pro/app/features/settings/presentation/widgets/settings_section.dart';
import 'package:estoque_pro/app/features/settings/presentation/widgets/settings_theme_tile.dart';
import 'package:estoque_pro/app/features/settings/presentation/widgets/settings_tile.dart';
import 'package:estoque_pro/app/features/settings/presentation/widgets/settings_user_card.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  final AuthViewModel authViewModel;
  final BiometricViewModel biometricViewModel;
  final ThemeViewModel themeViewModel;

  const SettingsPage({
    super.key,
    required this.authViewModel,
    required this.biometricViewModel,
    required this.themeViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authViewModel,
      builder: (context, _) {
        final currentUser = authViewModel.currentUser;
        final role = currentUser?.role ?? UserRole.seller;
        final isManager = role == UserRole.owner || role == UserRole.admin;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Configurações'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space16,
                vertical: AppSpacing.space12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsUserCard(authViewModel: authViewModel),
                  const Gap(AppSpacing.space24),
                  SettingsSection(
                    title: 'Segurança & Acesso',
                    children: [
                      SettingsBiometricTile(
                        biometricViewModel: biometricViewModel,
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.space24),
                  SettingsSection(
                    title: 'Preferências',
                    children: [
                      SettingsTile(
                        icon: AppIcons.grid,
                        iconColor: AppColors.primary,
                        title: 'Atalhos da Tela Inicial',
                        subtitle: 'Personalizar a ordem dos botões na Home',
                        onTap: () => context.push(AppRoutes.homeShortcutsSettings),
                      ),
                      const Gap(AppSpacing.space8),
                      SettingsThemeTile(themeViewModel: themeViewModel),
                    ],
                  ),
                  if (isManager) ...[
                    const Gap(AppSpacing.space24),
                    SettingsSection(
                      title: 'Gerenciamento',
                      children: [
                        SettingsTile(
                          icon: AppIcons.supervisorAccount,
                          iconColor: Colors.blueGrey,
                          title: 'Gerenciar Usuários',
                          subtitle: 'Equipe, cargos e permissões',
                          onTap: () => context.push(AppRoutes.users),
                        ),
                      ],
                    ),
                  ],
                  const Gap(AppSpacing.space24),
                  SettingsSection(
                    title: 'Sobre o Sistema',
                    children: [
                      SettingsTile(
                        icon: AppIcons.store,
                        iconColor: AppColors.primary,
                        title: 'Estoque Pro',
                        subtitle: 'Gestão simplificada de estoque e vendas',
                        trailing: Text(
                          'v1.0.0',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.space32),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SettingsLogoutButton(
            authViewModel: authViewModel,
          ),
        );
      },
    );
  }
}
