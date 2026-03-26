# Buggy 🏴‍☠️

[![Pub Version](https://img.shields.io/pub/v/buggy)](https://pub.dev/packages/buggy)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A powerful Dart tool that generates clean, readable, AI-ready Markdown reports from LCOV coverage files.

Transform messy LCOV output into gorgeous Markdown reports that are perfect for documentation, code reviews, and CI/CD pipelines.

## Features

- 🎯 **Clean Markdown Output**: Beautiful, readable coverage reports
- 🤖 **AI-Ready Format**: Perfect for feeding into AI tools and documentation systems
- 🔍 **Smart Filtering**: Automatically filters out boilerplate code (@override, braces, etc.)
- 🎨 **Syntax Highlighting**: Language-specific code blocks with proper highlighting
- 📊 **Flexible Reporting**: Summary mode, detailed reports, or uncovered-only views
- 🚫 **Pattern Exclusion**: Exclude files using glob patterns (test files, generated code, etc.)
- 🔬 **Line-Level Exclusion**: Exclude specific lines from coverage with content verification
- 📈 **Coverage Thresholds**: Fail builds when coverage drops below specified thresholds
- 🗂️ **Smart Grouping**: Groups consecutive uncovered lines into logical code blocks
- ⚙️ **Config File Presets**: Define reusable named presets in `buggy.yaml` for any command

## Installation

Install Buggy globally using Dart's package manager:

```bash
dart pub global activate buggy
```

## Usage

After installation, you can run Buggy using:

```bash
buggy <command> [arguments]
```

### `--help`

```bash
Usage: buggy <command> [arguments]

Global options:
-h, --help       Print this usage information.
    --verbose    Show additional command output.
-v, --version    Print the tool version.

Available commands:
  report    Generate coverage report from LCOV file
  run       Run utility commands

Run "buggy <command> --help" for more information about a command.
```

## Commands: `report`

### `--help`

```bash
Usage: buggy report [options]

Generate a coverage report from LCOV file.

Options:
-h, --help              Print help for the report command.
-i, --input             Input LCOV file path (default: coverage/lcov.info)
                        (defaults to "coverage/lcov.info")
-o, --output            Output file path (default: stdout)
-e, --exclude           Exclude files matching pattern (glob). Can be specified multiple times.
    --exclude-line      Exclude specific lines from coverage. Format: file_path:line_number:line_content. Can be specified multiple times.
-f, --fail-under        Exit with error if coverage below threshold (percentage)
-s, --summary           Show summary with individual file coverage
    --uncovered-only    Show only files with uncovered lines
    --no-filter         Disable filtering of common useless lines (@override, braces, etc.)
-p, --preset            Use a named preset from buggy.yaml.
```

### `--input`

Specifies the path to the input LCOV coverage file to process. By default, Buggy looks for `coverage/lcov.info` in the current directory.

```bash
buggy report --input path/to/custom_coverage.info
buggy report -i coverage/different_lcov.info
```

### `--output`

Specifies the file path where the generated coverage report should be saved. If not provided, the report is printed to stdout (console output).

```bash
buggy report --output coverage_report.md
buggy report -o docs/coverage.md
```

### `--exclude`

Excludes files from the coverage report using glob patterns. Can be specified multiple times to exclude multiple patterns. This is useful for filtering out test files, generated code, or other files you don't want to include in coverage analysis.

```bash
buggy report --exclude "**/test/**"
buggy report -e "**/*.g.dart"
buggy report --exclude "**/test/**" --exclude "**/*.g.dart" --exclude "**/generated/**"
```

Common patterns:
- `**/test/**` - Exclude all files in test directories
- `**/*_test.dart` - Exclude all test files
- `**/*.g.dart` - Exclude generated Dart files
- `**/generated/**` - Exclude generated code directories

### `--exclude-line`

Excludes specific lines from coverage calculations. This is useful when certain lines are intentionally uncovered (e.g., debug helpers, platform-specific code) and you don't want them to affect your coverage percentage.

Format: `file_path:line_number:line_content`

All three parts are required. The line content is verified against the actual source file to prevent stale exclusions.

```bash
buggy report --exclude-line "lib/user.dart:45:String customFormat() {"
buggy report --exclude-line "lib/user.dart:45:String customFormat() {" --exclude-line "lib/user.dart:46:return 'hello';"
```

Buggy validates each `--exclude-line` entry and exits with an error if:
- The file does not exist
- The line number is out of range
- The content does not match the actual source line
- The target line is not an uncovered line

### `--fail-under`

Sets a minimum coverage threshold percentage. If the total coverage falls below this threshold, Buggy will exit with code 1, making it perfect for CI/CD pipelines to fail builds with insufficient coverage.

```bash
buggy report --fail-under 80
buggy report -f 95.5
```

Example output when coverage is below threshold:
```bash
Coverage 84.2% is below threshold 100.0%
```

### `--summary`

Generates a concise summary report showing individual file coverage percentages and total coverage instead of the detailed report with code blocks. Perfect for quick coverage overviews or CI/CD pipeline status checks.

```bash
buggy report --summary
buggy report -s
```

Example output:
```
File 'lib/todo_manager.dart' coverage: 72.7%
File 'lib/user.dart' coverage: 53.8%
Total Coverage: 84.2%
```

### `--uncovered-only`

Ignore from coverage report files with 100% coverage.
Note that the files with 100% coverage are always excluded from the report, this command just ignore them from the total coverage percentage.

```bash
buggy report --uncovered-only
```

### `--no-filter`

Disables Buggy's smart filtering of common "useless" lines. By default, Buggy filters out lines like `@override` annotations, standalone braces, and empty lines from uncovered line reports. This flag shows all uncovered lines as-is.

```bash
buggy report --no-filter
```

### `--preset`

Loads a named preset from a `buggy.yaml` config file in the current directory. Preset values are applied first, so CLI flags override single-value options and accumulate with multi-options like `--exclude`.

```bash
buggy report --preset ci
buggy report -p ci
buggy report --preset ci --exclude "**/extra/**"
```

See [Config File](#config-file-buggyyaml) for details on defining presets.

### Example Workflow

1. Install the `coverage` package globally (if you haven't already):
```bash
dart pub global activate coverage
```

2. Run your tests with coverage:
```bash
dart test --coverage=coverage
```

3. Generate LCOV report:
```bash
dart pub global run coverage:format_coverage \
  --lcov \
  --in=coverage \
  --out=coverage/lcov.info \
  --packages=.dart_tool/package_config.json \
  --report-on=lib
```

4. Generate beautiful Markdown report:
```bash
buggy report
```

#### Output

Buggy generates clean, professional coverage reports like this:

```markdown
# Buggy Report

## Total Coverage: 84.2%

## File: lib/todo_manager.dart

### Coverage: 72.7%

### Uncovered Lines:

​```dart
  40:   bool uncompleteTodo(String id) {
  41:     final todoIndex = _todos.indexWhere((todo) => todo.id == id);
  42:     if (todoIndex == -1) return false;
​```

## File: lib/user.dart

### Coverage: 53.8%

### Uncovered Lines:

​```dart
  17:   User copyWith({String? id, String? name}) {
  18:     return User(id: id ?? this.id, name: name ?? this.name);
​```
```

## Commands: `run`

The `run` command is a parent for utility subcommands.

### `flutter-test-coverage-workaround`

Flutter's `flutter test --coverage` only includes files in `lcov.info` that are imported by test files. Files that are never imported don't appear in coverage at all, silently hiding untested code.

This command generates a test file that imports all `lib/` files, forcing Flutter's coverage tooling to track them.

```bash
# Must be run from a Flutter project root
buggy run flutter-test-coverage-workaround
```

This creates `test/.buggy/coverage_fix_test.dart` with imports for every Dart file under `lib/`.

#### `--target`

Choose the output directory. Defaults to `test`.

```bash
buggy run flutter-test-coverage-workaround --target integration_test
```

#### `--include`

Include only files matching glob patterns. Can be specified multiple times.

```bash
buggy run flutter-test-coverage-workaround --include "src/models/*" --include "src/services/*"
```

#### `--exclude`

Exclude files matching glob patterns. Can be specified multiple times. Applied after `--include`.

```bash
buggy run flutter-test-coverage-workaround --exclude "*.g.dart" --exclude "*.freezed.dart"
```

#### `--preset`

Loads a named preset from `buggy.yaml`. See [Config File](#config-file-buggyyaml).

```bash
buggy run flutter-test-coverage-workaround --preset default
```

### Example Flutter Workflow

1. Generate the coverage fix file:
```bash
buggy run flutter-test-coverage-workaround
```

2. Run tests with coverage:
```bash
flutter test --coverage
```

3. Generate the report:
```bash
buggy report
```

## Config File (`buggy.yaml`)

Create a `buggy.yaml` (or `buggy.yml`) in your project root to define reusable named presets for any command. Presets are selected with `--preset <name>` (or `-p <name>`).

YAML keys match CLI option names exactly. Nested commands use nested YAML objects.

### Example

```yaml
commands:
  report:
    presets:
      - name: ci
        fail-under: 80
        summary: true
        exclude:
          - "*.g.dart"
          - "*.freezed.dart"
      - name: full
        no-filter: true
      - name: custom
        exclude:
          - "**/todo.dart"
        exclude-line:
          - "lib/user.dart:45:String customFormat() {"
          - "lib/user.dart:46:return 'hello';"
  run:
    flutter-test-coverage-workaround:
      presets:
        - name: default
          exclude:
            - "*.g.dart"
            - "*.freezed.dart"
          target: test
```

### Usage

```bash
# Use the "ci" preset for report
buggy report --preset ci

# CLI flags override single-value preset options
buggy report --preset ci --fail-under 90

# CLI flags accumulate with multi-value preset options
buggy report --preset ci --exclude "**/extra/**"

# Use a preset for flutter-test-coverage-workaround
buggy run flutter-test-coverage-workaround --preset default
```

### How presets work

Preset values are prepended as synthetic CLI arguments before the actual arguments you pass. This means:
- **Single-value options** (e.g., `--fail-under`, `--input`): CLI flags override preset values.
- **Multi-value options** (e.g., `--exclude`, `--exclude-line`): CLI flags accumulate with preset values.
- **Flags** (e.g., `--summary`, `--no-filter`): Preset sets the flag; CLI cannot unset it (flags are non-negatable).

## Integration

### GitHub Actions

Coming soon...

## Why "Buggy"?

Named after Buggy the Clown from One Piece - just like how Buggy can split apart and reassemble, this tool takes apart your LCOV coverage data and puts it back together in a much more beautiful and useful format! 🏴‍☠️

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an Issue.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
