import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class AppDateTimePicker {
  AppDateTimePicker._();

  /// Exibe um diálogo customizado e reutilizável para seleção de data e horário
  /// utilizando o OmniDateTimePicker e botões estilizados do AppButton.
  ///
  /// Suporta limitação de horário através de [minTime], [maxTime] e [selectableTimePredicate],
  /// exibindo feedback visual em tempo real e desabilitando a confirmação caso o horário seja inválido.
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    TimeOfDay? minTime,
    TimeOfDay? maxTime,
    bool Function(DateTime)? selectableTimePredicate,
    String? invalidTimeMessage,
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
        return StatefulBuilder(
          builder: (context, setModalState) {
            bool isTimeValid(DateTime dt) {
              if (type == OmniDateTimePickerType.date) return true;
              final time = TimeOfDay.fromDateTime(dt);
              final timeMinutes = time.hour * 60 + time.minute;
              if (minTime != null) {
                final minMinutes = minTime.hour * 60 + minTime.minute;
                if (timeMinutes < minMinutes) return false;
              }
              if (maxTime != null) {
                final maxMinutes = maxTime.hour * 60 + maxTime.minute;
                if (timeMinutes > maxMinutes) return false;
              }
              if (selectableTimePredicate != null && !selectableTimePredicate(dt)) {
                return false;
              }
              return true;
            }

            final isValid = isTimeValid(selectedDateTime);

            String formatTime(TimeOfDay t) {
              final h = t.hour.toString().padLeft(2, '0');
              final m = t.minute.toString().padLeft(2, '0');
              return '$h:$m';
            }

            String? getErrorMessage() {
              if (isValid) return null;
              if (invalidTimeMessage != null) return invalidTimeMessage;
              if (minTime != null && maxTime != null) {
                return 'Horário permitido: entre ${formatTime(minTime)} e ${formatTime(maxTime)}';
              } else if (minTime != null) {
                return 'Horário mínimo permitido: ${formatTime(minTime)}';
              } else if (maxTime != null) {
                return 'Horário máximo permitido: ${formatTime(maxTime)}';
              }
              return 'Horário selecionado inválido';
            }

            final errorMessage = getErrorMessage();

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
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.space8),
                            decoration: BoxDecoration(
                              color: dialogContext.colorScheme.primary,
                              borderRadius: BorderRadius.circular(AppSpacing.radius8),
                            ),
                            child: Icon(
                              type == OmniDateTimePickerType.time
                                  ? Icons.schedule_rounded
                                  : Icons.calendar_month_rounded,
                              color: dialogContext.colorScheme.onPrimary,
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
                            data: Theme.of(dialogContext).copyWith(
                              datePickerTheme: DatePickerThemeData(
                                dayShape: WidgetStateProperty.all(
                                  const _AppDayBorder(radius: AppSpacing.radius8, margin: 2),
                                ),
                                todayBorder: BorderSide(
                                  color: dialogContext.colorScheme.primary,
                                  width: 1.5,
                                ),
                                dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return dialogContext.colorScheme.primary;
                                  }
                                  return null;
                                }),
                                dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return dialogContext.colorScheme.onPrimary;
                                  }
                                  return null;
                                }),
                                todayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return dialogContext.colorScheme.primary;
                                  }
                                  return null;
                                }),
                                todayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return dialogContext.colorScheme.onPrimary;
                                  }
                                  return dialogContext.colorScheme.primary;
                                }),
                              ),
                            ),
                            child: OmniDateTimePicker(
                              initialDate: initialDate,
                              firstDate: firstDate,
                              lastDate: lastDate,
                              is24HourMode: is24HourMode,
                              isShowSeconds: isShowSeconds,
                              minutesInterval: minutesInterval,
                              type: type,
                              onDateTimeChanged: (dateTime) {
                                setModalState(() {
                                  selectedDateTime = dateTime;
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                      // Error message if time is out of allowed range
                      if (errorMessage != null) ...[
                        const Gap(AppSpacing.space12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space12,
                            vertical: AppSpacing.space8,
                          ),
                          decoration: BoxDecoration(
                            color: dialogContext.colorScheme.errorContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.radius8),
                            border: Border.all(
                              color: dialogContext.colorScheme.error.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: AppSpacing.icon16,
                                color: dialogContext.colorScheme.error,
                              ),
                              const Gap(AppSpacing.space8),
                              Expanded(
                                child: Text(
                                  errorMessage,
                                  style: dialogContext.textTheme.bodySmall?.copyWith(
                                    color: dialogContext.colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const Gap(AppSpacing.space16),
                      const Divider(height: 1),
                      const Gap(AppSpacing.space16),

                      // Actions with AppButton
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: AppSpacing.space48,
                              child: AppButton.outlined(
                                label: cancelLabel,
                                onPressed: () => Navigator.pop(dialogContext),
                              ),
                            ),
                          ),
                          const Gap(AppSpacing.space12),
                          Expanded(
                            child: SizedBox(
                              height: AppSpacing.space48,
                              child: AppButton(
                                label: confirmLabel,
                                onPressed: isValid ? () => Navigator.pop(dialogContext, selectedDateTime) : null,
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
      },
    );
  }
}

/// Borda customizada para os dias do calendário que aplica uma margem interna (margin/inset)
/// e cantos arredondados, evitando que dias adjacentes fiquem colados uns nos outros.
class _AppDayBorder extends OutlinedBorder {
  final double radius;
  final double margin;

  const _AppDayBorder({
    this.radius = 8.0,
    this.margin = 3.0,
    super.side,
  });

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return _AppDayBorder(
      radius: radius,
      margin: margin,
      side: side ?? this.side,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final insetRect = rect.deflate(margin);
    return Path()..addRRect(RRect.fromRectAndRadius(insetRect, Radius.circular(radius)));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final insetRect = rect.deflate(margin);
    return Path()..addRRect(RRect.fromRectAndRadius(insetRect, Radius.circular(radius)));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final insetRect = rect.deflate(margin);
    if (side.style != BorderStyle.none && side.width > 0) {
      final paint = side.toPaint();
      final rrect = RRect.fromRectAndRadius(insetRect, Radius.circular(radius));
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  ShapeBorder scale(double t) {
    return _AppDayBorder(
      radius: radius * t,
      margin: margin * t,
      side: side.scale(t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is _AppDayBorder && other.radius == radius && other.margin == margin && other.side == side;
  }

  @override
  int get hashCode => Object.hash(radius, margin, side);
}
