import 'package:example_flutter/counter_notifier.dart';
import 'package:example_flutter/settings_model.dart';
// ignore: unused_import
import 'package:example_flutter/theme_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CounterNotifier Tests (Partial Coverage)', () {
    late CounterNotifier counter;

    setUp(() {
      counter = CounterNotifier();
    });

    test('should start at zero', () {
      expect(counter.value, equals(0));
      expect(counter.isZero, isTrue);
    });

    test('should increment', () {
      counter.increment();

      expect(counter.value, equals(1));
      expect(counter.isZero, isFalse);
    });

    test('should increment multiple times', () {
      counter
        ..increment()
        ..increment()
        ..increment();

      expect(counter.value, equals(3));
    });

    test('should set value', () {
      counter.setValue(42);

      expect(counter.value, equals(42));
    });

    test('should not notify when setting same value', () {
      counter
        ..setValue(5)
        ..addListener(expectAsync0(() {}, count: 0))
        ..setValue(5);
    });

    test('should notify listeners on increment', () {
      var notified = false;
      counter
        ..addListener(() => notified = true)
        ..increment();

      expect(notified, isTrue);
    });

    test('should increment by custom amount', () {
      counter.incrementBy(10);

      expect(counter.value, equals(10));
    });

    test('should throw when incrementBy non-positive amount', () {
      expect(() => counter.incrementBy(0), throwsArgumentError);
      expect(() => counter.incrementBy(-5), throwsArgumentError);
    });

    // Note: Intentionally NOT testing decrement() and reset() methods
    // This will show as uncovered in the coverage report
  });

  group('SettingsModel Tests (Full Coverage)', () {
    late SettingsModel settings;

    setUp(() {
      settings = SettingsModel();
    });

    tearDown(() {
      settings.dispose();
    });

    test('should have default values', () {
      expect(settings.darkMode, isFalse);
      expect(settings.fontSize, equals(14.0));
      expect(settings.locale, equals('en'));
    });

    test('should create with custom values', () {
      final custom = SettingsModel(
        darkMode: true,
        fontSize: 18,
        locale: 'it',
      );

      expect(custom.darkMode, isTrue);
      expect(custom.fontSize, equals(18.0));
      expect(custom.locale, equals('it'));

      custom.dispose();
    });

    test('should update dark mode', () {
      settings.darkMode = true;

      expect(settings.darkMode, isTrue);
    });

    test('should update font size', () {
      settings.fontSize = 20.0;

      expect(settings.fontSize, equals(20.0));
    });

    test('should throw on invalid font size', () {
      expect(() => settings.fontSize = 4.0, throwsRangeError);
      expect(() => settings.fontSize = 50.0, throwsRangeError);
    });

    test('should update locale', () {
      settings.locale = 'fr';

      expect(settings.locale, equals('fr'));
    });

    test('should throw on empty locale', () {
      expect(() => settings.locale = '', throwsArgumentError);
    });

    test('should expose listenables', () {
      expect(settings.darkModeListenable.value, isFalse);
      expect(settings.fontSizeListenable.value, equals(14.0));
      expect(settings.localeListenable.value, equals('en'));
    });

    test('should notify via listenable on change', () {
      var notified = false;
      settings.darkModeListenable.addListener(() => notified = true);

      settings.darkMode = true;

      expect(notified, isTrue);
    });

    test('should reset all settings to defaults', () {
      settings
        ..darkMode = true
        ..fontSize = 24.0
        ..locale = 'de'
        ..resetAll();

      expect(settings.darkMode, isFalse);
      expect(settings.fontSize, equals(14.0));
      expect(settings.locale, equals('en'));
    });
  });

  // Note: Intentionally NOT testing ThemeConfig class at all
  // This will show as completely uncovered in the coverage report
}
