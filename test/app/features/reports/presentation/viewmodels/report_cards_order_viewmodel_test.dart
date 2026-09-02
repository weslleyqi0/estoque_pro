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

  test('loads default order and visibility when storage has no saved data', () {
    when(() => mockStorage.getString('report_cards_order')).thenReturn(null);
    when(() => mockStorage.getString('report_cards_hidden')).thenReturn(null);

    final vm = ReportCardsOrderViewModel(mockStorage);

    expect(vm.cards, ReportCardType.defaultOrder);
    expect(vm.visibleCards, ReportCardType.defaultOrder);
    expect(vm.isCardVisible(ReportCardType.salesComparison), isTrue);
  });

  test('loads saved order and hidden cards from storage', () {
    when(() => mockStorage.getString('report_cards_order'))
        .thenReturn('stock,deliveries,customers_debt,sales_performance,sales_summary,sales_comparison');
    when(() => mockStorage.getString('report_cards_hidden'))
        .thenReturn('stock,customers_debt');

    final vm = ReportCardsOrderViewModel(mockStorage);

    expect(vm.cards.first, ReportCardType.stock);
    expect(vm.isCardVisible(ReportCardType.stock), isFalse);
    expect(vm.isCardVisible(ReportCardType.customersDebt), isFalse);
    expect(vm.isCardVisible(ReportCardType.deliveries), isTrue);

    expect(vm.visibleCards.first, ReportCardType.deliveries);
    expect(vm.visibleCards.contains(ReportCardType.stock), isFalse);
    expect(vm.visibleCards.contains(ReportCardType.customersDebt), isFalse);
  });

  test('toggleCardVisibility hides and unhides card and saves to storage', () async {
    when(() => mockStorage.getString('report_cards_order')).thenReturn(null);
    when(() => mockStorage.getString('report_cards_hidden')).thenReturn(null);
    when(() => mockStorage.setString(any(), any())).thenAnswer((_) async {});
    when(() => mockStorage.remove(any())).thenAnswer((_) async {});

    final vm = ReportCardsOrderViewModel(mockStorage);

    expect(vm.isCardVisible(ReportCardType.salesComparison), isTrue);

    // Ocultar card
    await vm.toggleCardVisibility(ReportCardType.salesComparison);

    expect(vm.isCardVisible(ReportCardType.salesComparison), isFalse);
    expect(vm.visibleCards.contains(ReportCardType.salesComparison), isFalse);
    verify(() => mockStorage.setString('report_cards_hidden', 'sales_comparison')).called(1);

    // Reexibir card
    await vm.toggleCardVisibility(ReportCardType.salesComparison);

    expect(vm.isCardVisible(ReportCardType.salesComparison), isTrue);
    expect(vm.visibleCards.contains(ReportCardType.salesComparison), isTrue);
    verify(() => mockStorage.remove('report_cards_hidden')).called(1);
  });

  test('reorder changes card positions and persists to storage', () async {
    when(() => mockStorage.getString('report_cards_order')).thenReturn(null);
    when(() => mockStorage.getString('report_cards_hidden')).thenReturn(null);
    when(() => mockStorage.setString(any(), any())).thenAnswer((_) async {});

    final vm = ReportCardsOrderViewModel(mockStorage);

    await vm.reorder(0, 2);

    expect(vm.cards[0], ReportCardType.salesSummary);
    expect(vm.cards[1], ReportCardType.salesPerformance);
    expect(vm.cards[2], ReportCardType.salesComparison);

    verify(() => mockStorage.setString(
          'report_cards_order',
          any(that: startsWith('sales_summary,sales_performance,sales_comparison')),
        )).called(1);
  });

  test('resetToDefault restores default list, clears hidden cards and removes storage keys', () async {
    when(() => mockStorage.getString('report_cards_order'))
        .thenReturn('deliveries,stock,customers_debt,sales_performance,sales_summary,sales_comparison');
    when(() => mockStorage.getString('report_cards_hidden')).thenReturn('deliveries');
    when(() => mockStorage.remove(any())).thenAnswer((_) async {});

    final vm = ReportCardsOrderViewModel(mockStorage);
    expect(vm.cards.first, ReportCardType.deliveries);
    expect(vm.isCardVisible(ReportCardType.deliveries), isFalse);

    await vm.resetToDefault();

    expect(vm.cards, ReportCardType.defaultOrder);
    expect(vm.visibleCards, ReportCardType.defaultOrder);
    verify(() => mockStorage.remove('report_cards_order')).called(1);
    verify(() => mockStorage.remove('report_cards_hidden')).called(1);
  });
}
