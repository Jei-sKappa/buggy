import 'dart:io';

import 'package:args/args.dart';
import 'package:buggy/commands/run/flutter_test_coverage_workaround/flutter_test_coverage_workaround.dart';
import 'package:buggy/utils/preset.dart';

/// Builds the argument parser for the 'flutter-test-coverage-workaround'
/// subcommand.
ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print help for this command.',
    )
    ..addMultiOption(
      'include',
      abbr: 'i',
      help:
          'Include only files matching pattern (glob). '
          'Can be specified multiple times.',
    )
    ..addMultiOption(
      'exclude',
      abbr: 'e',
      help:
          'Exclude files matching pattern (glob). '
          'Can be specified multiple times.',
    )
    ..addOption(
      'target',
      abbr: 't',
      help: 'Target test directory.',
      allowed: ['test', 'integration_test'],
      defaultsTo: 'test',
    )
    ..addOption(
      'preset',
      abbr: 'p',
      help: 'Use a named preset from buggy.yaml.',
    );
}

/// Prints usage information for the flutter-test-coverage-workaround command.
void printUsage(ArgParser parser) {
  print('Usage: buggy run flutter-test-coverage-workaround [options]');
  print('');
  print('Generate a test file that imports all lib/ files,');
  print("forcing Flutter's coverage to track them.");
  print('');
  print(
    'Must be run from a Flutter project root '
    '(pubspec.yaml with flutter dependency).',
  );
  print('');
  print('Output: <target>/.buggy/coverage_fix_test.dart');
  print('');
  print('Options:');
  print(parser.usage);
}

/// Handles the 'flutter-test-coverage-workaround' subcommand execution.
Future<void> handleCommand(
  List<String> arguments, {
  bool verbose = false,
}) async {
  final parser = buildParser();

  try {
    var results = parser.parse(arguments);

    if (results.flag('help')) {
      printUsage(parser);
      return;
    }

    // Resolve preset if specified
    final preset = resolvePreset(
      results: results,
      arguments: arguments,
      parser: parser,
      commandPath: ['run', 'flutter-test-coverage-workaround'],
    );
    results = preset.results;

    if (verbose) {
      print(
        '[VERBOSE] flutter-test-coverage-workaround arguments: $arguments',
      );
      if (preset.resolvedArguments != null) {
        print(
          '[VERBOSE] flutter-test-coverage-workaround resolved arguments: '
          '${preset.resolvedArguments}',
        );
      }
    }

    final includePatterns = results.multiOption('include');
    final excludePatterns = results.multiOption('exclude');

    final config = FlutterTestCoverageWorkaroundConfig(
      includePatterns: includePatterns,
      excludePatterns: excludePatterns,
      target: results.option('target')!,
    );

    await runFlutterTestCoverageWorkaround(config);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    print('');
    printUsage(parser);
    exit(1);
  }
}
