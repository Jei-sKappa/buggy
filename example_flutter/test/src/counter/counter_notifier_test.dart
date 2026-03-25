import 'package:example_flutter/src/counter/counter_notifier.dart';
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

    test('should decrement', () {
      counter
        ..increment()
        ..increment()
        ..decrement();

      expect(counter.value, equals(1));
    });

    test('should reset to zero', () {
      counter
        ..increment()
        ..increment()
        ..reset();

      expect(counter.value, equals(0));
      expect(counter.isZero, isTrue);
    });
  });
}
