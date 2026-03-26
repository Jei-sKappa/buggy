import 'dart:io';

import 'package:args/args.dart';
import 'package:buggy/utils/config_file.dart';

/// Result of resolving a preset, containing the parsed [ArgResults] and
/// the merged argument list (if a preset was applied).
typedef PresetResult = ({ArgResults results, List<String>? resolvedArguments});

/// Resolves a preset if `--preset` was specified in the parsed [results].
///
/// If no preset is specified, returns [results] unchanged with
/// `resolvedArguments` set to `null`.
///
/// Otherwise, loads the config file, finds the named preset for the given
/// [commandPath], converts it to CLI arguments, prepends them before the
/// original [arguments], and re-parses with [parser].
///
/// This ensures CLI arguments override preset values for single-value options,
/// and accumulate with preset values for multi-options.
///
/// Exits with code 1 and prints an error if the config file is missing or
/// the preset is not found.
PresetResult resolvePreset({
  required ArgResults results,
  required List<String> arguments,
  required ArgParser parser,
  required List<String> commandPath,
}) {
  final presetName = results.option('preset');
  if (presetName == null) {
    return (results: results, resolvedArguments: null);
  }

  try {
    final config = loadConfigFile();
    if (config == null) {
      stderr.writeln(
        'Error: --preset requires a buggy.yaml (or buggy.yml) file '
        'in the current directory, but none was found.',
      );
      exit(1);
    }

    final preset = findPreset(config, commandPath, presetName);
    final presetArgs = presetToArguments(preset);
    final mergedArguments = [...presetArgs, ...arguments];

    return (
      results: parser.parse(mergedArguments),
      resolvedArguments: mergedArguments,
    );
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    exit(1);
  }
}
