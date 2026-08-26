import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppDialog {
  AppDialog._();

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
  }) {
    return showDialog<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
    );
  }

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    Color? confirmColor,
    Color? cancelColor,
    bool isDestructive = false,
  }) async {
    final result = await show<bool>(
      context: context,
      builder: (dialogContext) {
        final effectiveConfirmColor = confirmColor ?? (isDestructive ? dialogContext.colorScheme.error : null);

        return Dialog(
          backgroundColor: dialogContext.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadius24,
            side: BorderSide(
              color: dialogContext.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space20,
            vertical: AppSpacing.space48,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.widthOf(context)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: dialogContext.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(AppSpacing.space12),
                  Text(
                    content,
                    style: dialogContext.textTheme.bodyMedium?.copyWith(
                      color: dialogContext.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(AppSpacing.space20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: AppSpacing.space40,
                        child: AppButton.text(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          label: cancelLabel,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                          textStyle: cancelColor != null
                              ? dialogContext.textTheme.bodyLarge?.copyWith(color: cancelColor, fontWeight: FontWeight.bold)
                              : dialogContext.textTheme.bodyLarge,
                        ),
                      ),
                      const Gap(AppSpacing.space8),
                      SizedBox(
                        height: AppSpacing.space40,
                        child: AppButton.text(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          label: confirmLabel,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                          textStyle: effectiveConfirmColor != null
                              ? dialogContext.textTheme.bodyLarge?.copyWith(color: effectiveConfirmColor, fontWeight: FontWeight.bold)
                              : dialogContext.textTheme.bodyLarge?.copyWith(color: dialogContext.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }

    return result;
  }
}
