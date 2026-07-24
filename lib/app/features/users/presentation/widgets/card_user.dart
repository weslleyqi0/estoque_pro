import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/users_viewmodel.dart';
import 'package:estoque_pro/app/features/users/presentation/widgets/card_user_expanded_content.dart';
import 'package:estoque_pro/app/features/users/presentation/widgets/card_user_header.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class CardUser extends StatelessWidget {
  final UsersViewModel viewModel;
  final UserEntity user;
  final bool isExpanded;
  final void Function()? onExpanded;

  const CardUser({
    super.key,
    required this.viewModel,
    required this.user,
    this.isExpanded = false,
    this.onExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = user.role == UserRole.owner
        ? context.colorScheme.onSurface
        : (user.role == UserRole.admin ? const Color(0xFF0057C9) : const Color(0xFF790098));

    final roleIcon = user.role == UserRole.owner
        ? Symbols.crown
        : (user.role == UserRole.admin ? Symbols.shield_person : Symbols.shopping_bag_rounded);

    return Padding(
      padding: .symmetric(vertical: AppSpacing.space4, horizontal: AppSpacing.space16),
      child: Container(
        padding: .symmetric(vertical: AppSpacing.space16, horizontal: AppSpacing.space16),
        decoration: BoxDecoration(
          color: context.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: AppSpacing.borderRadius12,
          border: .all(
            color: context.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            CardUserHeader(
              user: user,
              icon: roleIcon,
              color: roleColor,
              isExpanded: isExpanded,
              onExpanded: onExpanded,
            ),
            if (isExpanded)
              CardUserExpandedContent(
                viewModel: viewModel,
                user: user,
                icon: roleIcon,
                color: roleColor,
              ),
          ],
        ),
      ),
    );
  }
}
