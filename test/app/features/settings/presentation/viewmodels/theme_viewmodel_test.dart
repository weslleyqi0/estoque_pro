import 'package:estoque_pro/app/core/services/local_storage_service.dart';
import 'package:estoque_pro/app/features/settings/presentation/viewmodels/theme_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockStorage;

  setUp(() {
    mockStorage = MockLocalStorageService();
    when(() => mockStorage.getString(any())).thenReturn(null);
    when(() => mockStorage.setString(any(), any())).thenAnswer((_) async {});
  });

  group('ThemeViewModel Tests', () {
    test('initializes with default ThemeMode.system when no preference is saved', () {
      final vm = ThemeViewModel(mockStorage);
      expect(vm.themeMode, equals(ThemeMode.system));
    });

    test('initializes with saved theme mode', () {
      when(() => mockStorage.getString('app_theme_mode')).thenReturn('dark');
      final vm = ThemeViewModel(mockStorage);
      expect(vm.themeMode, equals(ThemeMode.dark));

      when(() => mockStorage.getString('app_theme_mode')).thenReturn('light');
      final vmLight = ThemeViewModel(mockStorage);
      expect(vmLight.themeMode, equals(ThemeMode.light));
    });

    test('setThemeMode updates state and persists change', () async {
      final vm = ThemeViewModel(mockStorage);
      var notified = false;
      vm.addListener(() => notified = true);

      await vm.setThemeMode(ThemeMode.dark);

      expect(vm.themeMode, equals(ThemeMode.dark));
      expect(notified, isTrue);
      verify(() => mockStorage.setString('app_theme_mode', 'dark')).called(1);
    });

    test('setThemeMode does nothing if mode is already current mode', () async {
      final vm = ThemeViewModel(mockStorage);
      var notifyCount = 0;
      vm.addListener(() => notifyCount++);

      await vm.setThemeMode(ThemeMode.system);

      expect(vm.themeMode, equals(ThemeMode.system));
      expect(notifyCount, equals(0));
      verifyNever(() => mockStorage.setString(any(), any()));
    });
  });
}
