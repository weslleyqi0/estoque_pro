import 'package:estoque_pro/app/core/services/local_storage_service.dart';
import 'package:estoque_pro/app/features/reports/domain/entities/report_card_type.dart';
import 'package:estoque_pro/app/features/reports/presentation/viewmodels/report_cards_order_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockStorage;

  setUp(() {
    mockStorage = MockLocalStorageService();
  });

  test('loads default order when storage has no saved order', () {
    when(() => mockStorage.getString('report_cards_order')).thenReturn(null);

    final vm = ReportCardsOrderViewModel(mockStorage);

    expect(vm.cards, ReportCardType.defaultOrder);
    expect(vm.cards.first, ReportCardType.salesComparison);
  });

  test('loads saved order correctly from storage', () {
    when(() => mockStorage.getString('report_cards_order'))
        .thenReturn('stock,deliveries,customers_debt,sales_performance,sales_summary,sales_comparison');

    final vm = ReportCardsOrderViewModel(mockStorage);

    expect(vm.cards.first, ReportCardType.stock);
    expect(vm.cards[1], ReportCardType.deliveries);
    expect(vm.cards[2], ReportCardType.customersDebt);
    expect(vm.cards[3], ReportCardType.salesPerformance);
    expect(vm.cards[4], ReportCardType.salesSummary);
    expect(vm.cards[5], ReportCardType.salesComparison);
  });

  test('reorder changes card positions and persists to storage', () async {
    when(() => mockStorage.getString('report_cards_order')).thenReturn(null);
    when(() => mockStorage.setString(any(), any())).thenAnswer((_) async {});

    final vm = ReportCardsOrderViewModel(mockStorage);

    // Mover primeiro item (salesComparison) para o índice 2
    await vm.reorder(0, 2);

    expect(vm.cards[0], ReportCardType.salesSummary);
    expect(vm.cards[1], ReportCardType.salesPerformance);
    expect(vm.cards[2], ReportCardType.salesComparison);

    verify(() => mockStorage.setString(
          'report_cards_order',
          any(that: startsWith('sales_summary,sales_performance,sales_comparison')),
        )).called(1);
  });

  test('resetToDefault restores default list and removes storage key', () async {
    when(() => mockStorage.getString('report_cards_order'))
        .thenReturn('deliveries,stock,customers_debt,sales_performance,sales_summary,sales_comparison');
    when(() => mockStorage.remove(any())).thenAnswer((_) async {});

    final vm = ReportCardsOrderViewModel(mockStorage);
    expect(vm.cards.first, ReportCardType.deliveries);

    await vm.resetToDefault();

    expect(vm.cards, ReportCardType.defaultOrder);
    verify(() => mockStorage.remove('report_cards_order')).called(1);
  });
}
