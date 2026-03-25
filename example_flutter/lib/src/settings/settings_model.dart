import 'package:flutter/foundation.dart';

/// App settings model using ValueNotifier for individual setting values
class SettingsModel {
  SettingsModel({
    bool darkMode = false,
    double fontSize = 14.0,
    String locale = 'en',
  })  : _darkMode = ValueNotifier<bool>(darkMode),
        _fontSize = ValueNotifier<double>(fontSize),
        _locale = ValueNotifier<String>(locale);

  final ValueNotifier<bool> _darkMode;
  final ValueNotifier<double> _fontSize;
  final ValueNotifier<String> _locale;

  /// Whether dark mode is enabled
  bool get darkMode => _darkMode.value;
  set darkMode(bool value) => _darkMode.value = value;

  /// The current font size
  double get fontSize => _fontSize.value;
  set fontSize(double value) {
    if (value < 8.0 || value > 48.0) {
      throw RangeError('Font size must be between 8.0 and 48.0');
    }
    _fontSize.value = value;
  }

  /// The current locale string
  String get locale => _locale.value;
  set locale(String value) {
    if (value.isEmpty) {
      throw ArgumentError('Locale cannot be empty');
    }
    _locale.value = value;
  }

  /// Listen to dark mode changes
  ValueListenable<bool> get darkModeListenable => _darkMode;

  /// Listen to font size changes
  ValueListenable<double> get fontSizeListenable => _fontSize;

  /// Listen to locale changes
  ValueListenable<String> get localeListenable => _locale;

  /// Reset all settings to defaults
  void resetAll() {
    _darkMode.value = false;
    _fontSize.value = 14.0;
    _locale.value = 'en';
  }

  /// Dispose all notifiers
  void dispose() {
    _darkMode.dispose();
    _fontSize.dispose();
    _locale.dispose();
  }
}
