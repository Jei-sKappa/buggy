import 'dart:io';
import 'package:args/args.dart';
import 'package:buggy/commands/report/parser.dart' as report;
import 'package:buggy/commands/run/parser.dart' as run_cmd;

/// Current version of the Buggy tool.
const String version = '1.2.0';

/// Builds and configures the main command line argument parser.
///
/// Creates a command-based CLI structure with:
/// - Global flags (help, version, verbose)
/// - Subcommands for different functionalities
///
/// Returns a configured [ArgParser] instance ready to parse arguments.
ArgParser buildParser() {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print the tool version.',
    )
    ..addCommand('report', report.buildParser())
    ..addCommand('run', run_cmd.buildParser());

  return parser;
}

/// Prints usage information for the command line tool.
///
/// Shows the command syntax and all available commands with their descriptions.
///
/// [argParser]: The configured argument parser to extract usage from.
void printUsage(ArgParser argParser) {
  print('Usage: buggy <command> [arguments]');
  print('');
  print('Global options:');
  print(argParser.usage);
  print('');
  print('Available commands:');
  print('  report    Generate coverage report from LCOV file');
  print('  run       Run utility commands');
  print('');
  print('Run "buggy <command> --help" for more information about a command.');
}

/// Prints the current version of the Buggy tool.
void printVersion() {
  print('buggy version: $version');
}

/// Main entry point for the Buggy command line tool.
///
/// Parses command line arguments and executes the appropriate command.
/// Uses a strict command-based architecture with the following structure:
/// - Global flags: help, version, verbose
/// - Commands: report (generate coverage reports), run (utility commands)
///
/// [arguments]: Command line arguments to parse.
///
/// Exits with code 0 on success, or code 1 if:
/// - Invalid arguments are provided
/// - Unknown command is specified
/// - Coverage falls below the specified threshold
/// - Input file doesn't exist or other errors occur
///
/// Example usage:
/// ```bash
/// buggy report --input coverage/lcov.info --output report.md
/// buggy report --exclude "**/test/**" --fail-under 80
/// buggy report --summary --uncovered-only
/// buggy --version
/// ```
Future<void> main(List<String> arguments) async {
  final argParser = buildParser();

  try {
    final results = argParser.parse(arguments);
    var verbose = false;

    // Handle global flags
    if (results.flag('help')) {
      printUsage(argParser);
      return;
    }
    if (results.flag('version')) {
      printVersion();
      return;
    }
    if (results.flag('verbose')) {
      verbose = true;
    }

    // Check if a command was provided
    if (results.command == null) {
      if (arguments.isNotEmpty && !arguments.first.startsWith('-')) {
        stderr.writeln('Error: Unknown command "${arguments.first}"');
        print('');
        printUsage(argParser);
        exit(1);
      } else {
        // No arguments at all
        printUsage(argParser);
        return;
      }
    }

    // Handle commands
    switch (results.command!.name) {
      case 'report':
        await report.handleCommand(
          results.command!.arguments,
          verbose: verbose,
        );
      case 'run':
        await run_cmd.handleCommand(
          results.command!.arguments,
          verbose: verbose,
        );
      default:
        stderr.writeln('Error: Unknown command "${results.command!.name}"');
        printUsage(argParser);
        exit(1);
    }
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    print('');
    printUsage(argParser);
    exit(1);
  }
}
