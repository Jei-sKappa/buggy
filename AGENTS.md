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

# Run the tool locally
fvm dart run bin/buggy.dart report --input coverage/lcov.info

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

All core logic lives in a single file: `lib/buggy.dart`. It exports `BuggyConfig` (configuration class) and `run()` (entry point that reads LCOV, filters, generates markdown, and outputs the report).

`bin/buggy.dart` is the CLI entry point. It uses `package:args` to parse commands and flags, then delegates to `buggy.run()` with a constructed `BuggyConfig`.

The `example/` directory is a standalone Dart project with intentionally partial test coverage, used to demonstrate Buggy's output.

## Lint Rules

Uses `very_good_analysis` with two overrides in `analysis_options.yaml`:
- `avoid_redundant_argument_values: false` - explicit arguments preferred for clarity
- `avoid_print: false` - this is a CLI app
