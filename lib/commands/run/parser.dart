import 'dart:io';

import 'package:args/args.dart';
import 'package:buggy/commands/run/flutter_test_coverage_workaround/parser.dart'
    as workaround;

/// Builds the argument parser for the 'run' command.
///
/// The 'run' command is a general-purpose parent command for utility
/// subcommands.
ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print help for the run command.',
    )
    ..addCommand(
      'flutter-test-coverage-workaround',
      workaround.buildParser(),
    );
}

/// Prints usage information for the run command.
void printUsage(ArgParser runParser) {
  print('Usage: buggy run <subcommand> [arguments]');
  print('');
  print('Run various utility commands.');
  print('');
  print('Options:');
  print(runParser.usage);
  print('');
  print('Available subcommands:');
  print(
    '  flutter-test-coverage-workaround    '
    'Generate a test file that imports all lib files for complete coverage',
  );
  print('');
  print('Run "buggy run <subcommand> --help" for more information.');
}

/// Handles the 'run' command by dispatching to the appropriate subcommand.
Future<void> handleCommand(
  List<String> arguments, {
  bool verbose = false,
}) async {
  final runParser = buildParser();

  try {
    final results = runParser.parse(arguments);

    if (results.flag('help') || results.command == null) {
      printUsage(runParser);
      return;
    }

    switch (results.command!.name) {
      case 'flutter-test-coverage-workaround':
        await workaround.handleCommand(
          results.command!.arguments,
          verbose: verbose,
        );
      default:
        stderr.writeln(
          'Error: Unknown run subcommand "${results.command!.name}"',
        );
        printUsage(runParser);
        exit(1);
    }
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    print('');
    printUsage(runParser);
    exit(1);
  }
}
