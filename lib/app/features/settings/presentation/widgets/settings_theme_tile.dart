import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/settings/presentation/viewmodels/theme_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SettingsThemeTile extends StatelessWidget {
  final ThemeViewModel themeViewModel;

  const SettingsThemeTile({
    super.key,
    required this.themeViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeViewModel,
      builder: (context, _) {
        final currentMode = themeViewModel.themeMode;
        final isSystem = currentMode == ThemeMode.system;
        final isLight = currentMode == ThemeMode.light;
        final isDark = currentMode == ThemeMode.dark;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space8),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: AppSpacing.borderRadius8,
                    ),
                    child: Icon(
                      switch (currentMode) {
                        ThemeMode.light => AppIcons.lightMode,
                        ThemeMode.dark => AppIcons.darkMode,
                        ThemeMode.system => AppIcons.brightnessAuto,
                      },
                      size: AppSpacing.icon20,
                      color: context.colorScheme.primary,
                    ),
                  ),
                  const Gap(AppSpacing.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aparência',
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          switch (currentMode) {
                            ThemeMode.light => 'Tema claro ativo',
                            ThemeMode.dark => 'Tema escuro ativo',
                            ThemeMode.system => 'Acompanha o padrão do sistema',
                          },
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.space12),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    selectedBackgroundColor: context.colorScheme.primary,
                    selectedForegroundColor: AppColors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadius12,
                    ),
                  ),
                  segments: [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      enabled: true,
                      icon: const Icon(AppIcons.lightMode, size: AppSpacing.icon16),
                      label: Text(
                        'Claro',
                        style: TextStyle(
                          fontWeight: isLight ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      enabled: true,
                      icon: const Icon(AppIcons.brightnessAuto, size: AppSpacing.icon16),
                      label: Text(
                        'Sistema',
                        style: TextStyle(
                          fontWeight: isSystem ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      enabled: true,
                      icon: const Icon(AppIcons.darkMode, size: AppSpacing.icon16),
                      label: Text(
                        'Escuro',
                        style: TextStyle(
                          fontWeight: isDark ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                  selected: {currentMode},
                  onSelectionChanged: (Set<ThemeMode> selection) {
                    if (selection.isNotEmpty) {
                      themeViewModel.setThemeMode(selection.first);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
