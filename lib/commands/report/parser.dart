import 'dart:io';

import 'package:args/args.dart';
import 'package:buggy/commands/report/report.dart';
import 'package:buggy/utils/preset.dart';

/// Builds the argument parser for the 'report' command.
///
/// Defines all available options for generating coverage reports:
/// - Input/output file paths
/// - Filtering options (exclude patterns, uncovered-only, line filtering)
/// - Coverage thresholds and summary mode
///
/// Returns a configured [ArgParser] instance for the report command.
ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print help for the report command.',
    )
    ..addOption(
      'input',
      abbr: 'i',
      help: 'Input LCOV file path (default: coverage/lcov.info)',
      defaultsTo: 'coverage/lcov.info',
    )
    ..addOption('output', abbr: 'o', help: 'Output file path (default: stdout)')
    ..addMultiOption(
      'exclude',
      abbr: 'e',
      help:
          'Exclude files matching pattern (glob). '
          'Can be specified multiple times.',
    )
    ..addMultiOption(
      'exclude-line',
      splitCommas: false,
      help:
          'Exclude specific lines from coverage. '
          'Format: file_path:line_number:line_content. '
          'Can be specified multiple times.',
    )
    ..addOption(
      'fail-under',
      abbr: 'f',
      help: 'Exit with error if coverage below threshold (percentage)',
    )
    ..addFlag(
      'summary',
      abbr: 's',
      negatable: false,
      help: 'Show summary with individual file coverage',
    )
    ..addFlag(
      'uncovered-only',
      negatable: false,
      help: 'Show only files with uncovered lines',
    )
    ..addFlag(
      'no-filter',
      negatable: false,
      help:
          'Disable filtering of common useless lines (@override, braces, etc.)',
    )
    ..addOption(
      'preset',
      abbr: 'p',
      help: 'Use a named preset from buggy.yaml.',
    );
}

/// Prints usage information for the report command.
///
/// Shows the report command syntax and all available options.
///
/// [reportParser]: The configured report argument parser.
void printUsage(ArgParser reportParser) {
  print('Usage: buggy report [options]');
  print('');
  print('Generate a coverage report from LCOV file.');
  print('');
  print('Options:');
  print(reportParser.usage);
}

/// Handles the 'report' command execution.
///
/// Parses the report command arguments and executes coverage report generation.
///
/// [arguments]: Arguments for the report command.
/// [verbose]: Whether verbose output is enabled.
Future<void> handleCommand(
  List<String> arguments, {
  bool verbose = false,
}) async {
  final reportParser = buildParser();

  try {
    var results = reportParser.parse(arguments);

    // Handle report-specific help
    if (results.flag('help')) {
      printUsage(reportParser);
      return;
    }

    // Resolve preset if specified
    final preset = resolvePreset(
      results: results,
      arguments: arguments,
      parser: reportParser,
      commandPath: ['report'],
    );
    results = preset.results;

    if (verbose) {
      print('[VERBOSE] Report arguments: $arguments');
      if (preset.resolvedArguments != null) {
        print('[VERBOSE] Report resolved arguments: '
            '${preset.resolvedArguments}');
      }
    }

    // Parse fail-under option
    double? failUnder;
    if (results.option('fail-under') != null) {
      try {
        failUnder = double.parse(results.option('fail-under')!);
        if (failUnder < 0 || failUnder > 100) {
          stderr.writeln('Error: fail-under must be between 0 and 100');
          exit(1);
        }
      } on Object catch (_) {
        stderr.writeln('Error: fail-under must be a valid number');
        exit(1);
      }
    }

    // Create configuration
    final config = ReportConfig(
      inputPath: results.option('input')!,
      outputPath: results.option('output'),
      excludePatterns: results.multiOption('exclude'),
      excludeLinePatterns: results.multiOption('exclude-line'),
      uncoveredOnly: results.flag('uncovered-only'),
      failUnder: failUnder,
      summary: results.flag('summary'),
      noFilter: results.flag('no-filter'),
    );

    await runReport(config);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    print('');
    printUsage(reportParser);
    exit(1);
  }
}
