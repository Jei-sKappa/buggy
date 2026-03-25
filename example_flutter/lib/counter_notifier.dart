import 'package:flutter/foundation.dart';

/// A simple counter using ChangeNotifier for state management
class CounterNotifier extends ChangeNotifier {
  int _value = 0;

  /// The current counter value
  int get value => _value;

  /// Whether the counter is at zero
  bool get isZero => _value == 0;

  /// Increment the counter by 1
  void increment() {
    _value++;
    notifyListeners();
  }

  /// Decrement the counter by 1
  void decrement() {
    _value--;
    notifyListeners();
  }

  /// Reset the counter to zero
  void reset() {
    _value = 0;
    notifyListeners();
  }

  /// Set the counter to a specific value
  void setValue(int newValue) {
    if (newValue == _value) return;
    _value = newValue;
    notifyListeners();
  }

  /// Increment by a custom amount
  void incrementBy(int amount) {
    if (amount <= 0) {
      throw ArgumentError('Amount must be positive');
    }
    _value += amount;
    notifyListeners();
  }
}
