import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class AppDateTimePicker {
  AppDateTimePicker._();

  /// Exibe um diálogo customizado e reutilizável para seleção de data e horário
  /// utilizando o OmniDateTimePicker e botões estilizados do AppButton.
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    bool is24HourMode = true,
    bool isShowSeconds = false,
    int minutesInterval = 1,
    String? title,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    OmniDateTimePickerType type = OmniDateTimePickerType.dateAndTime,
    bool barrierDismissible = true,
  }) async {
    DateTime selectedDateTime = initialDate ?? DateTime.now();

    return showDialog<DateTime>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: dialogContext.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadius16,
            side: BorderSide(
              color: dialogContext.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space20,
            vertical: AppSpacing.space24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.space8),
                        decoration: BoxDecoration(
                          color: dialogContext.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radius8),
                        ),
                        child: Icon(
                          type == OmniDateTimePickerType.time
                              ? Icons.schedule_rounded
                              : Icons.calendar_month_rounded,
                          color: dialogContext.colorScheme.onPrimaryContainer,
                          size: AppSpacing.icon20,
                        ),
                      ),
                      const Gap(AppSpacing.space12),
                      Expanded(
                        child: Text(
                          title ??
                              (type == OmniDateTimePickerType.date
                                  ? 'Selecionar Data'
                                  : type == OmniDateTimePickerType.time
                                      ? 'Selecionar Horário'
                                      : 'Selecionar Data e Horário'),
                          style: dialogContext.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(AppSpacing.space16),
                  const Divider(height: 1),
                  const Gap(AppSpacing.space12),

                  // OmniDateTimePicker Widget
                  Flexible(
                    child: SingleChildScrollView(
                      child: Theme(
                        data: Theme.of(dialogContext),
                        child: OmniDateTimePicker(
                          initialDate: initialDate,
                          firstDate: firstDate,
                          lastDate: lastDate,
                          is24HourMode: is24HourMode,
                          isShowSeconds: isShowSeconds,
                          minutesInterval: minutesInterval,
                          type: type,
                          onDateTimeChanged: (dateTime) {
                            selectedDateTime = dateTime;
                          },
                        ),
                      ),
                    ),
                  ),

                  const Gap(AppSpacing.space16),
                  const Divider(height: 1),
                  const Gap(AppSpacing.space16),

                  // Actions with AppButton
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: AppSpacing.space40,
                          child: AppButton.outlined(
                            label: cancelLabel,
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ),
                      ),
                      const Gap(AppSpacing.space12),
                      Expanded(
                        child: SizedBox(
                          height: AppSpacing.space40,
                          child: AppButton(
                            label: confirmLabel,
                            onPressed: () => Navigator.pop(dialogContext, selectedDateTime),
                          ),
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
  }
}
