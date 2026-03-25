import 'package:flutter/foundation.dart';

/// Theme configuration class (intentionally untested)
@immutable
class ThemeConfig {
  const ThemeConfig({
    this.primaryColor = 0xFF2196F3,
    this.fontFamily = 'Roboto',
    this.borderRadius = 8.0,
    this.spacing = 16.0,
  });

  /// Creates a ThemeConfig from a map
  factory ThemeConfig.fromMap(Map<String, dynamic> map) {
    return ThemeConfig(
      primaryColor: map['primaryColor'] as int,
      fontFamily: map['fontFamily'] as String,
      borderRadius: (map['borderRadius'] as num).toDouble(),
      spacing: (map['spacing'] as num).toDouble(),
    );
  }

  final int primaryColor;
  final String fontFamily;
  final double borderRadius;
  final double spacing;

  /// Creates a copy with the given fields replaced
  ThemeConfig copyWith({
    int? primaryColor,
    String? fontFamily,
    double? borderRadius,
    double? spacing,
  }) {
    return ThemeConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      fontFamily: fontFamily ?? this.fontFamily,
      borderRadius: borderRadius ?? this.borderRadius,
      spacing: spacing ?? this.spacing,
    );
  }

  /// Converts this config to a map
  Map<String, dynamic> toMap() {
    return {
      'primaryColor': primaryColor,
      'fontFamily': fontFamily,
      'borderRadius': borderRadius,
      'spacing': spacing,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeConfig &&
        other.primaryColor == primaryColor &&
        other.fontFamily == fontFamily &&
        other.borderRadius == borderRadius &&
        other.spacing == spacing;
  }

  @override
  int get hashCode {
    return Object.hash(primaryColor, fontFamily, borderRadius, spacing);
  }

  @override
  String toString() {
    return 'ThemeConfig(primaryColor: $primaryColor, '
        'fontFamily: $fontFamily, '
        'borderRadius: $borderRadius, '
        'spacing: $spacing)';
  }
}
