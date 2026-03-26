import 'dart:io';

import 'package:buggy/utils/glob_matching.dart';

/// Configuration for the Flutter test coverage workaround command.
///
/// Defines options for generating a test file that imports all `lib/` files,
/// forcing Flutter's coverage tooling to track them.
class FlutterTestCoverageWorkaroundConfig {
  /// Creates a new coverage workaround configuration.
  const FlutterTestCoverageWorkaroundConfig({
    this.excludePatterns = const [],
    this.includePatterns = const [],
    this.target = 'test',
  });

  /// Glob patterns to exclude files from the generated import list.
  ///
  /// Example: `['*.g.dart', '*.freezed.dart']`
  final List<String> excludePatterns;

  /// Glob patterns to include files in the generated import list.
  ///
  /// When non-empty, only files matching at least one pattern are included.
  /// Example: `['src/models/*', 'src/services/*']`
  final List<String> includePatterns;

  /// Target test directory for the generated file.
  ///
  /// Must be `'test'` or `'integration_test'`.
  /// Defaults to `'test'`.
  final String target;
}

/// Generates a test file that imports all `lib/` files in a Flutter project.
///
/// This works around Flutter's `flutter test --coverage` limitation where
/// only files imported by test files appear in coverage data. Files that are
/// never imported are invisible to coverage, silently hiding untested code.
///
/// Must be run from a Flutter project root (directory with `pubspec.yaml`
/// containing a `flutter` dependency).
///
/// The generated file is written to `<target>/.buggy/coverage_fix_test.dart`,
/// where `<target>` is `test` (default) or `integration_test`.
Future<void> runFlutterTestCoverageWorkaround([
  FlutterTestCoverageWorkaroundConfig? config,
]) async {
  final cfg = config ?? const FlutterTestCoverageWorkaroundConfig();

  // 1. Validate pubspec.yaml exists
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    stderr.writeln(
      'Error: pubspec.yaml not found. '
      'Run this command from a Flutter project root.',
    );
    exit(1);
  }

  // 2. Read and parse pubspec.yaml
  final pubspecContent = await pubspecFile.readAsString();

  final nameMatch = RegExp(
    r'^name:\s*(.+)$',
    multiLine: true,
  ).firstMatch(pubspecContent);
  if (nameMatch == null) {
    stderr.writeln('Error: Could not find "name:" field in pubspec.yaml.');
    exit(1);
  }
  final packageName = nameMatch.group(1)!.trim();

  // 3. Validate Flutter dependency
  if (!_hasFlutterDependency(pubspecContent)) {
    stderr.writeln(
      'Error: This does not appear to be a Flutter project. '
      'No flutter dependency found in pubspec.yaml.',
    );
    exit(1);
  }

  // 4. Scan lib/ directory
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('Error: lib/ directory not found.');
    exit(1);
  }

  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .map((f) => f.path.replaceAll(r'\', '/'))
      .toList();

  // 5. Filter by include/exclude patterns and skip `part of` files
  final partOfPattern = RegExp(r'^\s*part\s+of\s+', multiLine: true);
  final filteredFiles = dartFiles.where((filePath) {
    final relativePath = filePath.startsWith('lib/')
        ? filePath.substring(4)
        : filePath;

    // If include patterns are set, file must match at least one
    if (cfg.includePatterns.isNotEmpty) {
      final included = cfg.includePatterns.any(
        (pattern) => matchesPattern(relativePath, pattern),
      );
      if (!included) return false;
    }

    // Exclude patterns filter out matching files
    if (cfg.excludePatterns.any(
      (pattern) => matchesPattern(relativePath, pattern),
    )) {
      return false;
    }

    // Skip files that are `part of` another library
    final content = File(filePath).readAsStringSync();
    if (partOfPattern.hasMatch(content)) return false;

    return true;
  }).toList();

  // 6. Generate sorted package imports
  final imports = filteredFiles.map((filePath) {
    final relativePath = filePath.startsWith('lib/')
        ? filePath.substring(4)
        : filePath;
    return "import 'package:$packageName/$relativePath';";
  }).toList()..sort();

  // 7. Build output content
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln()
    ..writeln("import 'package:flutter_test/flutter_test.dart';");

  for (final import_ in imports) {
    buffer.writeln(import_);
  }

  buffer
    ..writeln()
    ..writeln('void main() {')
    ..writeln("  group('Buggy Coverage Fix', () {")
    ..writeln('  });')
    ..writeln('}')
    ..writeln();

  // 8. Write file
  final outputFile = File('${cfg.target}/.buggy/coverage_fix_test.dart');
  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsString(buffer.toString());

  print('Generated ${outputFile.path} with ${imports.length} imports.');
}

/// Checks if a pubspec.yaml content contains a Flutter SDK dependency.
bool _hasFlutterDependency(String pubspecContent) {
  return RegExp(r'^\s+flutter:\s*$', multiLine: true).hasMatch(pubspecContent);
}
