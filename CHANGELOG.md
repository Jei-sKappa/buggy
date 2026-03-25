## 1.2.0

- **Breaking:** `BuggyConfig.excludePattern` (`String?`) replaced with `excludePatterns` (`List<String>`).
- `report --exclude` (`-e`) now accepts multiple patterns (e.g., `--exclude "**/test/**" --exclude "*.g.dart"`).
- Changed `flutter-test-coverage-workaround` output path from `<target>/src/.buggy/` to `<target>/.buggy/`.

## 1.1.1

- Fixed `flutter-test-coverage-workaround` to skip files with `part of` directives, which cannot be imported directly.

## 1.1.0

- Added `run` command as a general-purpose parent for utility subcommands.
- Added `run flutter-test-coverage-workaround` subcommand that generates a test file importing all `lib/` files, fixing Flutter's coverage blind spot for unimported files.
  - `--target` (`-t`): Choose output directory (`test` or `integration_test`).
  - `--include` (`-i`): Include only files matching glob patterns.
  - `--exclude` (`-e`): Exclude files matching glob patterns.
- Added `example_flutter/` demonstrating Buggy usage with Flutter projects.

## 1.0.0

- Initial version.
