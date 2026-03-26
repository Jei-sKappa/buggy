# AGENTS.md

This file provides guidance to AI Agents when working with code in this repository.

## Update rule

Update `AGENTS.md` when:
- You make significant changes that needs to be remembered across session.
- You made a mistake that should not be repeated.
- The user told you a new rule that should be remembered.

> Note: `CLAUDE.md` is a symlink to `AGENTS.md`.

## What This Is

Buggy is a Dart CLI tool that parses LCOV coverage files and generates clean, AI-ready Markdown reports. Published to pub.dev as `buggy`.

## Commands

```bash
# Get dependencies
fvm dart pub get

# Regenerate version from pubspec.yaml (after version bumps)
fvm dart run build_runner build --delete-conflicting-outputs

# Run report locally
fvm dart run bin/buggy.dart report --input coverage/lcov.info

# Generate Flutter coverage workaround (run from a Flutter project root)
fvm dart run bin/buggy.dart run flutter-test-coverage-workaround

# Analyze (uses very_good_analysis rules)
fvm dart analyze

# Format
fvm dart format .

# Run tests (tests live in example/ only)
cd example && fvm dart pub get && fvm dart test

# Run a single test file
cd example && fvm dart test test/example_test.dart
```

FVM is configured (Flutter 3.41.0) via `.fvmrc`.

## Architecture

All core logic lives in a single file: `lib/buggy.dart`. It exports:
- `BuggyConfig` + `run()` — report generation (reads LCOV, filters, generates markdown)
- `CoverageWorkaroundConfig` + `runCoverageWorkaround()` — Flutter coverage workaround (scans lib/, generates test file importing all files)

`bin/buggy.dart` is the CLI entry point. It uses `package:args` to parse commands and flags. Commands:
- `report` — generate coverage report from LCOV file
- `run` — general-purpose parent command for utility subcommands
  - `flutter-test-coverage-workaround` — generates `<target>/.buggy/coverage_fix_test.dart` (target: `test` or `integration_test`) that imports all `lib/` files, fixing Flutter's coverage blind spot for unimported files

### Config file (`buggy.yaml`)

Users can create a `buggy.yaml` (or `buggy.yml`) in their project root to define named presets for any command. Presets are resolved via `--preset <name>` / `-p <name>`. YAML keys match CLI option names exactly. Nested commands use nested YAML objects. Preset values are prepended as synthetic CLI args, so CLI flags override single-value options and accumulate with multi-options.

Config loading lives in `lib/utils/config_file.dart`, preset resolution in `lib/utils/preset.dart`.

The `example/` directory is a standalone Dart project with intentionally partial test coverage, used to demonstrate Buggy's output.

The `example_flutter/` directory is a standalone Flutter project (no widgets, uses `ChangeNotifier`/`ValueNotifier`) with intentionally partial coverage, used to demonstrate the Flutter coverage workaround.

## Lint Rules

Uses `very_good_analysis` with two overrides in `analysis_options.yaml`:
- `avoid_redundant_argument_values: false` - explicit arguments preferred for clarity
- `avoid_print: false` - this is a CLI app
