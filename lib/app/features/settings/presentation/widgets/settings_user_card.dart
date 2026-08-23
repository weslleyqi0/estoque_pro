import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/presentation/extensions/user_role_ui_extension.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SettingsUserCard extends StatelessWidget {
  final AuthViewModel authViewModel;

  const SettingsUserCard({
    super.key,
    required this.authViewModel,
  });

  String _getUserInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authViewModel,
      builder: (context, _) {
        final currentUser = authViewModel.currentUser;
        final authenticatedUser = authViewModel.authenticatedUser;
        final name = currentUser?.name ?? authenticatedUser?.displayName ?? 'Usuário';
        final email = currentUser?.email ?? authenticatedUser?.email ?? 'Sem e-mail';
        final role = currentUser?.role ?? UserRole.seller;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space12,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: AppSpacing.borderRadius16,
            border: Border.all(
              color: context.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: AppSpacing.space24,
                backgroundColor: context.colorScheme.primary,
                child: Text(
                  _getUserInitials(name),
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Gap(AppSpacing.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      email,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Wrap(
                      spacing: AppSpacing.space8,
                      runSpacing: AppSpacing.space4,
                      children: [
                        AppTag(
                          title: role.title,
                          icon: role.icon,
                          color: role.color(context),
                        ),
                        if (currentUser?.isActive ?? true)
                          const AppTag(
                            title: 'Ativo',
                            icon: AppIcons.checkCircle,
                            color: AppColors.success,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
