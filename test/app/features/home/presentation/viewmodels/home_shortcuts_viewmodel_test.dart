import 'package:estoque_pro/app/core/services/local_storage_service.dart';
import 'package:estoque_pro/app/features/home/domain/entities/home_shortcut_type.dart';
import 'package:estoque_pro/app/features/home/presentation/viewmodels/home_shortcuts_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockStorage;

  setUp(() {
    mockStorage = MockLocalStorageService();
  });

  test('loads default order when storage has no saved order', () {
    when(() => mockStorage.getString('home_shortcuts_order')).thenReturn(null);

    final vm = HomeShortcutsViewModel(mockStorage);

    expect(vm.shortcuts, HomeShortcutType.defaultOrder);
    expect(vm.shortcuts.first, HomeShortcutType.products);
  });

  test('loads saved order correctly from storage', () {
    when(() => mockStorage.getString('home_shortcuts_order'))
        .thenReturn('deliveries,sales,products,categories,suppliers,customers,reports,users');

    final vm = HomeShortcutsViewModel(mockStorage);

    expect(vm.shortcuts.first, HomeShortcutType.deliveries);
    expect(vm.shortcuts[1], HomeShortcutType.sales);
    expect(vm.shortcuts[2], HomeShortcutType.products);
  });

  test('filters managerOnly shortcuts when isManager is false', () {
    when(() => mockStorage.getString('home_shortcuts_order')).thenReturn(null);

    final vm = HomeShortcutsViewModel(mockStorage);

    final sellerShortcuts = vm.getShortcutsForRole(isManager: false);
    expect(sellerShortcuts.any((s) => s.managerOnly), isFalse);
    expect(sellerShortcuts.contains(HomeShortcutType.reports), isFalse);
    expect(sellerShortcuts.contains(HomeShortcutType.users), isFalse);

    final managerShortcuts = vm.getShortcutsForRole(isManager: true);
    expect(managerShortcuts.contains(HomeShortcutType.reports), isTrue);
    expect(managerShortcuts.contains(HomeShortcutType.users), isTrue);
  });

  test('reorder changes item positions and persists to storage', () async {
    when(() => mockStorage.getString('home_shortcuts_order')).thenReturn(null);
    when(() => mockStorage.setString(any(), any())).thenAnswer((_) async {});

    final vm = HomeShortcutsViewModel(mockStorage);

    // Mover primeiro item (Produtos) para o índice 2
    await vm.reorder(0, 2);

    expect(vm.shortcuts[0], HomeShortcutType.sales);
    expect(vm.shortcuts[1], HomeShortcutType.categories);
    expect(vm.shortcuts[2], HomeShortcutType.products);

    verify(() => mockStorage.setString(
          'home_shortcuts_order',
          any(that: startsWith('sales,categories,products')),
        )).called(1);
  });

  test('resetToDefault restores default list and removes storage key', () async {
    when(() => mockStorage.getString('home_shortcuts_order'))
        .thenReturn('deliveries,sales,products');
    when(() => mockStorage.remove(any())).thenAnswer((_) async {});

    final vm = HomeShortcutsViewModel(mockStorage);
    expect(vm.shortcuts.first, HomeShortcutType.deliveries);

    await vm.resetToDefault();

    expect(vm.shortcuts, HomeShortcutType.defaultOrder);
    expect(vm.shortcuts.first, HomeShortcutType.products);
    verify(() => mockStorage.remove('home_shortcuts_order')).called(1);
  });
}
