import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

class CardUserHeader extends StatelessWidget {
  final UserEntity user;
  final String currentUserId;
  final Color? color;
  final IconData? icon;
  final bool isExpanded;
  final void Function()? onExpanded;

  const CardUserHeader({
    super.key,
    required this.user,
    required this.currentUserId,
    this.color,
    this.icon,
    this.onExpanded,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = user.isActive ? AppColors.successDark : AppColors.error;

    return GestureDetector(
      onTap: onExpanded,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: .all(AppSpacing.space12),
                decoration: BoxDecoration(
                  borderRadius: AppSpacing.borderRadius12,
                  color: color?.withValues(alpha: 0.2),
                ),
                child: Icon(
                  Symbols.person,
                  color: color,
                  size: AppSpacing.icon48,
                  weight: 400,
                ),
              ),
              Gap(AppSpacing.space12),
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    user.name,
                    style: context.textTheme.titleMedium?.copyWith(height: 0.9),
                  ),
                  Text(
                    user.email,
                    style: context.textTheme.bodySmall,
                  ),
                  Gap(AppSpacing.space4),
                  Row(
                    children: [
                      AppTag(
                        title: user.role.title,
                        icon: icon,
                        color: color,
                      ),
                      Gap(AppSpacing.space8),
                      AppTag(
                        title: user.isActive ? 'Ativo' : 'Desativado',
                        icon: user.isActive ? Symbols.check_circle_rounded : Symbols.block_rounded,
                        color: activeColor,
                      ),
                      if (user.uid == currentUserId) ...[
                        Gap(AppSpacing.space8),
                        AppTag(
                          title: 'Você',
                          icon: Symbols.person,
                          color: color,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: onExpanded,
            icon: Icon(
              isExpanded ? Symbols.keyboard_arrow_up_rounded : Symbols.keyboard_arrow_down_rounded,
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              size: AppSpacing.icon32,
            ),
          ),
        ],
      ),
    );
  }
}
