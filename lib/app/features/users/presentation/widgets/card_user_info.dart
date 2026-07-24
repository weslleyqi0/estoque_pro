import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CardUserInfo extends StatelessWidget {
  final UserEntity user;
  final String title;
  final String mensage;
  final IconData? icon;
  final Color? color;

  const CardUserInfo({
    super.key,
    required this.user,
    required this.title,
    required this.mensage,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(bottom: AppSpacing.space4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.2),
          borderRadius: AppSpacing.borderRadius16,
        ),
        child: Padding(
          padding: const .symmetric(vertical: AppSpacing.space12, horizontal: AppSpacing.space16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: AppSpacing.icon28,
                    weight: 700,
                  ),
                  Gap(AppSpacing.space8),
                  Text(
                    title,
                    style: context.textTheme.titleLarge?.copyWith(color: color),
                  ),
                ],
              ),
              Gap(AppSpacing.space8),
              Text(
                mensage,
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
