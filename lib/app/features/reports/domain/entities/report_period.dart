import 'package:equatable/equatable.dart';

enum ReportPeriodType {
  today('Hoje', 'Ontem'),
  week('Semana', 'Semana anterior'),
  month('Mês', 'Mês anterior'),
  year('Ano', 'Ano anterior'),
  custom('Personalizado', 'Período anterior');

  final String label;
  final String previousLabel;

  const ReportPeriodType(this.label, this.previousLabel);
}

class ReportPeriod extends Equatable {
  final ReportPeriodType type;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime previousStartDate;
  final DateTime previousEndDate;

  const ReportPeriod({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.previousStartDate,
    required this.previousEndDate,
  });

  /// Retorna o período para o dia de hoje comparado ao dia de ontem
  factory ReportPeriod.today([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final prevDay = DateTime(now.year, now.month, now.day - 1);
    final prevStart = DateTime(prevDay.year, prevDay.month, prevDay.day, 0, 0, 0);
    final prevEnd = DateTime(prevDay.year, prevDay.month, prevDay.day, 23, 59, 59, 999);

    return ReportPeriod(
      type: ReportPeriodType.today,
      startDate: start,
      endDate: end,
      previousStartDate: prevStart,
      previousEndDate: prevEnd,
    );
  }

  /// Retorna a semana atual de segunda a sábado comparada com a semana anterior de segunda a sábado
  factory ReportPeriod.week([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    // Em Dart, DateTime.monday == 1, tuesday == 2, ... friday == 5, saturday == 6, sunday == 7
    final daysSinceMonday = now.weekday - DateTime.monday;
    final monday = todayStart.subtract(Duration(days: daysSinceMonday));
    final saturday = DateTime(monday.year, monday.month, monday.day + 5, 23, 59, 59, 999);

    final prevMonday = monday.subtract(const Duration(days: 7));
    final prevSaturday = DateTime(prevMonday.year, prevMonday.month, prevMonday.day + 5, 23, 59, 59, 999);

    return ReportPeriod(
      type: ReportPeriodType.week,
      startDate: monday,
      endDate: saturday,
      previousStartDate: prevMonday,
      previousEndDate: prevSaturday,
    );
  }

  /// Retorna o mês corrente comparado ao mês anterior
  factory ReportPeriod.month([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final start = DateTime(now.year, now.month, 1, 0, 0, 0);
    // Último dia do mês: dia 0 do próximo mês
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    final prevMonthYear = now.month == 1 ? now.year - 1 : now.year;
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevStart = DateTime(prevMonthYear, prevMonth, 1, 0, 0, 0);
    final prevEnd = DateTime(prevMonthYear, prevMonth + 1, 0, 23, 59, 59, 999);

    return ReportPeriod(
      type: ReportPeriodType.month,
      startDate: start,
      endDate: end,
      previousStartDate: prevStart,
      previousEndDate: prevEnd,
    );
  }

  /// Retorna o ano corrente comparado ao ano anterior
  factory ReportPeriod.year([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final start = DateTime(now.year, 1, 1, 0, 0, 0);
    final end = DateTime(now.year, 12, 31, 23, 59, 59, 999);

    final prevStart = DateTime(now.year - 1, 1, 1, 0, 0, 0);
    final prevEnd = DateTime(now.year - 1, 12, 31, 23, 59, 59, 999);

    return ReportPeriod(
      type: ReportPeriodType.year,
      startDate: start,
      endDate: end,
      previousStartDate: prevStart,
      previousEndDate: prevEnd,
    );
  }

  /// Retorna o período customizado com o período anterior equivalente
  factory ReportPeriod.custom(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final normalizedEnd = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);

    final duration = normalizedEnd.difference(normalizedStart);
    final prevEnd = normalizedStart.subtract(const Duration(milliseconds: 1));
    final prevStart = prevEnd.subtract(duration);

    return ReportPeriod(
      type: ReportPeriodType.custom,
      startDate: normalizedStart,
      endDate: normalizedEnd,
      previousStartDate: prevStart,
      previousEndDate: prevEnd,
    );
  }

  @override
  List<Object?> get props => [type, startDate, endDate, previousStartDate, previousEndDate];
}
