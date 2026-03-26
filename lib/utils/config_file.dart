import 'dart:io';

import 'package:yaml/yaml.dart';

/// Attempts to load a buggy config file from the current directory.
///
/// Looks for `buggy.yaml` first, then `buggy.yml` as a fallback.
/// Returns the parsed [YamlMap], or `null` if no config file is found.
///
/// Throws a [FormatException] if the file exists but contains invalid YAML
/// or is not a YAML map.
YamlMap? loadConfigFile() {
  for (final filename in ['buggy.yaml', 'buggy.yml']) {
    final file = File(filename);
    if (file.existsSync()) {
      final content = file.readAsStringSync();
      final yaml = loadYaml(content);
      if (yaml is! YamlMap) {
        throw FormatException(
          '$filename must be a YAML map, got ${yaml.runtimeType}.',
        );
      }
      return yaml;
    }
  }
  return null;
}

/// Looks up a preset by [presetName] for the given [commandPath].
///
/// The [commandPath] is a list of command segments, e.g. `['report']` or
/// `['run', 'flutter-test-coverage-workaround']`. The function walks the
/// nested YAML structure under the `commands` key to find the preset.
///
/// Returns the preset as a [Map<String, dynamic>] (without the `name` key),
/// or throws a [FormatException] with a descriptive error if the preset or
/// command is not found.
Map<String, dynamic> findPreset(
  YamlMap config,
  List<String> commandPath,
  String presetName,
) {
  final commandLabel = commandPath.join(' ');

  // Navigate to `commands`
  final commands = config['commands'];
  if (commands is! YamlMap) {
    throw const FormatException(
      "buggy.yaml is missing the 'commands' key.",
    );
  }

  // Walk the nested command path
  dynamic current = commands;
  for (final segment in commandPath) {
    if (current is! YamlMap || current[segment] == null) {
      throw FormatException(
        "No configuration found for command '$commandLabel' in buggy.yaml.",
      );
    }
    current = current[segment];
  }

  if (current is! YamlMap) {
    throw FormatException(
      "No configuration found for command '$commandLabel' in buggy.yaml.",
    );
  }

  // Find presets list
  final presets = current['presets'];
  if (presets is! YamlList) {
    throw FormatException(
      "No presets defined for command '$commandLabel' in buggy.yaml.",
    );
  }

  // Search for the named preset
  final availableNames = <String>[];
  for (final preset in presets) {
    if (preset is! YamlMap) continue;
    final name = preset['name'];
    if (name is String) {
      availableNames.add(name);
      if (name == presetName) {
        final result = <String, dynamic>{};
        for (final key in preset.keys) {
          if (key == 'name') continue;
          final value = preset[key];
          if (value is YamlList) {
            result[key as String] = value.toList();
          } else {
            result[key as String] = value;
          }
        }
        return result;
      }
    }
  }

  throw FormatException(
    "Preset '$presetName' not found for command '$commandLabel'. "
    'Available presets: ${availableNames.join(', ')}',
  );
}

/// Converts a preset map into a list of CLI-style arguments.
///
/// Handles the following value types:
/// - [String] or [num] → `['--key', 'value']`
/// - [bool] `true` → `['--key']`
/// - [bool] `false` → skipped (flags are non-negatable, false is default)
/// - [List] → `['--key', 'v1', '--key', 'v2']` for each element
List<String> presetToArguments(Map<String, dynamic> preset) {
  final args = <String>[];
  for (final entry in preset.entries) {
    final key = entry.key;
    final value = entry.value;

    if (value is bool) {
      if (value) {
        args.add('--$key');
      }
      // false → skip, non-negatable flags default to false
    } else if (value is List) {
      for (final item in value) {
        args
          ..add('--$key')
          ..add(item.toString());
      }
    } else {
      args
        ..add('--$key')
        ..add(value.toString());
    }
  }
  return args;
}
