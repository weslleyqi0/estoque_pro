import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/users_viewmodel.dart';
import 'package:estoque_pro/app/features/users/presentation/widgets/card_user_info.dart';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CardUserExpandedContent extends StatelessWidget {
  final UsersViewModel viewModel;
  final UserEntity user;
  final UserRole currentUserRole;
  final String currentUserId;
  final IconData? icon;
  final Color? color;

  const CardUserExpandedContent({
    super.key,
    required this.viewModel,
    required this.user,
    required this.currentUserRole,
    required this.currentUserId,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final canEditTarget = viewModel.canEditUser(user);
    final isSelf = user.uid == currentUserId;

    return Column(
      children: [
        Divider(
          thickness: 2,
          height: AppSpacing.space32,
          color: context.colorScheme.onSurface.withValues(alpha: 0.05),
        ),
        if (user.role == UserRole.owner)
          CardUserInfo(
            user: user,
            title: 'Proprietário do Sistema',
            mensage: isSelf
                ? 'Você possui acesso total como Dono.'
                : 'O dono possui acesso total e não pode ser editado ou removido por outros usuários.',
            icon: icon,
            color: color,
          ),
        if (user.role == UserRole.admin && isSelf)
          CardUserInfo(
            user: user,
            title: 'Administrador',
            mensage: 'Você possui acesso como Administrador. Para alterar seu nome, use o botão de edição.',
            icon: icon,
            color: color,
          ),
        if (user.role != UserRole.owner && !isSelf && canEditTarget)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSwitchTitle(
                title: 'Status da Conta',
                subtitle: 'Ativar ou desativar acesso do usuário',
                titleStyle: context.textTheme.titleLarge,
                value: user.isActive,
                onChanged: (value) => viewModel.toggleUserActive(user, value),
              ),
              const Gap(AppSpacing.space24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Função',
                    style: context.textTheme.titleLarge,
                  ),
                  const Gap(AppSpacing.space8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppButton(
                        onPressed: () => viewModel.updateUserRole(user, UserRole.seller),
                        icon: AppIcons.shoppingBag,
                        variant: user.role == UserRole.admin ? AppButtonVariant.outlined : AppButtonVariant.primary,
                        label: 'Vendedor',
                      ),
                      const Gap(AppSpacing.space8),
                      Expanded(
                        child: AppButton(
                          label: 'Administrador',
                          onPressed: () => viewModel.updateUserRole(user, UserRole.admin),
                          icon: AppIcons.shieldPerson,
                          variant: user.role == UserRole.seller ? AppButtonVariant.outlined : AppButtonVariant.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(AppSpacing.space16),
              if (user.role == UserRole.seller && user.isActive) ...[
                const Gap(AppSpacing.space24),
                Text(
                  'Permissões',
                  style: context.textTheme.titleLarge,
                ),
                const Gap(AppSpacing.space8),
                Text(
                  'Controle o que este vendedor pode acessar e modificar no sistema.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const Gap(AppSpacing.space16),
                ...UserPermission.values.asMap().entries.map((entry) {
                  final index = entry.key;
                  final permission = entry.value;

                  final isLast = index == UserPermission.values.length - 1;

                  return Column(
                    children: [
                      AppSwitchTitle(
                        title: permission.title,
                        subtitle: permission.description,
                        value: user.permissions.contains(permission),
                        onChanged: (_) => viewModel.toggleUserPermission(user, permission),
                      ),
                      if (!isLast)
                        Divider(
                          thickness: 2,
                          height: AppSpacing.space24,
                          color: context.colorScheme.onSurface.withValues(alpha: 0.05),
                        ),
                    ],
                  );
                }),
              ],
            ],
          ),
      ],
    );
  }
}
