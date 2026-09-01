import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:estoque_pro/app/features/home/presentation/viewmodels/home_shortcuts_viewmodel.dart';
import 'package:estoque_pro/app/features/settings/presentation/widgets/home_shortcut_reorder_tile.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomeShortcutsSettingsPage extends StatelessWidget {
  final HomeShortcutsViewModel Function() viewModelFactory;
  final AuthViewModel authViewModel;

  const HomeShortcutsSettingsPage({
    super.key,
    required this.viewModelFactory,
    required this.authViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = viewModelFactory();
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, authViewModel]),
      builder: (context, _) {
        final currentUser = authViewModel.currentUser;
        final role = currentUser?.role ?? UserRole.seller;
        final isManager = role == UserRole.owner || role == UserRole.admin;
        final shortcuts = viewModel.getShortcutsForRole(isManager: isManager);

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Atalhos da Tela Inicial'),
            actions: [
              IconButton(
                icon: const Icon(AppIcons.refresh),
                tooltip: 'Restaurar Padrão',
                onPressed: () async {
                  await viewModel.resetToDefault();
                  if (context.mounted) {
                    AppSnackbar.info(context, 'Ordem padrão restaurada.');
                  }
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space16,
                    AppSpacing.space12,
                    AppSpacing.space16,
                    AppSpacing.space8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.space12),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radius12),
                      border: Border.all(
                        color: context.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.info,
                          color: context.colorScheme.primary,
                          size: AppSpacing.icon20,
                        ),
                        const Gap(AppSpacing.space12),
                        Expanded(
                          child: Text(
                            'Arraste os itens para reorganizar a ordem de exibição dos botões no grid da tela inicial.',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                      vertical: AppSpacing.space8,
                    ),
                    itemCount: shortcuts.length,
                    onReorderItem: (oldIndex, newIndex) {
                      viewModel.reorder(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final item = shortcuts[index];
                      return HomeShortcutReorderTile(
                        key: ValueKey(item.id),
                        item: item,
                        index: index,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
