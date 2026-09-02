import 'package:estoque_pro/app/features/reports/domain/entities/report_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportPeriod', () {
    test('today generates today 00:00 to 23:59 and yesterday as previous period', () {
      final ref = DateTime(2026, 9, 2, 14, 30); // Quarta-feira
      final period = ReportPeriod.today(ref);

      expect(period.type, ReportPeriodType.today);
      expect(period.startDate, DateTime(2026, 9, 2, 0, 0, 0));
      expect(period.endDate, DateTime(2026, 9, 2, 23, 59, 59, 999));
      expect(period.previousStartDate, DateTime(2026, 9, 1, 0, 0, 0));
      expect(period.previousEndDate, DateTime(2026, 9, 1, 23, 59, 59, 999));
    });

    test('week generates Monday to Saturday of current week and previous week', () {
      final ref = DateTime(2026, 9, 2, 14, 30); // Quarta-feira (dia 2 de Setembro)
      final period = ReportPeriod.week(ref);

      expect(period.type, ReportPeriodType.week);
      // Segunda-feira é 31 de Agosto de 2026
      expect(period.startDate, DateTime(2026, 8, 31, 0, 0, 0));
      // Sábado é 05 de Setembro de 2026
      expect(period.endDate, DateTime(2026, 9, 5, 23, 59, 59, 999));

      // Semana anterior: Segunda 24/08 a Sábado 29/08
      expect(period.previousStartDate, DateTime(2026, 8, 24, 0, 0, 0));
      expect(period.previousEndDate, DateTime(2026, 8, 29, 23, 59, 59, 999));
    });

    test('month generates 1st to last day of current month and previous month', () {
      final ref = DateTime(2026, 9, 15);
      final period = ReportPeriod.month(ref);

      expect(period.type, ReportPeriodType.month);
      expect(period.startDate, DateTime(2026, 9, 1, 0, 0, 0));
      expect(period.endDate, DateTime(2026, 9, 30, 23, 59, 59, 999));

      expect(period.previousStartDate, DateTime(2026, 8, 1, 0, 0, 0));
      expect(period.previousEndDate, DateTime(2026, 8, 31, 23, 59, 59, 999));
    });

    test('year generates Jan 1 to Dec 31 of current and previous year', () {
      final ref = DateTime(2026, 6, 10);
      final period = ReportPeriod.year(ref);

      expect(period.type, ReportPeriodType.year);
      expect(period.startDate, DateTime(2026, 1, 1, 0, 0, 0));
      expect(period.endDate, DateTime(2026, 12, 31, 23, 59, 59, 999));

      expect(period.previousStartDate, DateTime(2025, 1, 1, 0, 0, 0));
      expect(period.previousEndDate, DateTime(2025, 12, 31, 23, 59, 59, 999));
    });

    test('custom generates defined date range with matching duration for previous period', () {
      final start = DateTime(2026, 9, 10);
      final end = DateTime(2026, 9, 15);
      final period = ReportPeriod.custom(start, end);

      expect(period.type, ReportPeriodType.custom);
      expect(period.startDate, DateTime(2026, 9, 10, 0, 0, 0));
      expect(period.endDate, DateTime(2026, 9, 15, 23, 59, 59, 999));
      expect(period.previousEndDate.isBefore(period.startDate), isTrue);
    });
  });
}
