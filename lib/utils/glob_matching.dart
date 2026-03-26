/// Simple glob pattern matching for file exclusion.
///
/// Converts a glob-style [pattern] to a regular expression and tests it
/// against the given file [path]. Supports common wildcards:
/// - `*` matches any characters
/// - `?` matches a single character
/// - `/` is escaped for path matching
///
/// If the pattern is invalid regex, falls back to literal string matching.
///
/// [path]: File path to test against the pattern.
/// [pattern]: Glob pattern (e.g., "**/test/**", "*.generated.dart").
///
/// Returns `true` if the path matches the pattern.
///
/// Example:
/// ```dart
/// matchesPattern('lib/test/helper.dart', '**/test/**')  // true
/// matchesPattern('lib/main.dart', '**/test/**')        // false
/// ```
bool matchesPattern(String path, String pattern) {
  // Convert simple glob pattern to regex
  final regexPattern = pattern
      .replaceAll('*', '.*')
      .replaceAll('?', '.')
      .replaceAll('/', r'\/');

  try {
    final regex = RegExp(regexPattern);
    return regex.hasMatch(path);
  } on Object catch (_) {
    // If pattern is invalid, treat as literal string match
    return path.contains(pattern);
  }
}
