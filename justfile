set shell := ["bash", "-euo", "pipefail", "-c"]

example := "example"
example_flutter := "example_flutter"

default:
    @just --list

test-and-report:
    just test-and-report-example
    just test-and-report-example-flutter

test-and-report-example:
    cd {{example}} && fvm dart test --coverage=coverage
    @echo ""
    @echo "---"
    @echo ""
    cd {{example}} && dart pub global run coverage:format_coverage \
        --lcov \
        --in=coverage \
        --out=coverage/lcov.info \
        --packages=.dart_tool/package_config.json \
        --report-on=lib
    @echo ""
    @echo "---"
    @echo ""
    cd {{example}} && buggy report

test-and-report-example-preset:
    cd {{example}} && fvm dart test --coverage=coverage
    @echo ""
    @echo "---"
    @echo ""
    cd {{example}} && dart pub global run coverage:format_coverage \
        --lcov \
        --in=coverage \
        --out=coverage/lcov.info \
        --packages=.dart_tool/package_config.json \
        --report-on=lib
    @echo ""
    @echo "---"
    @echo ""
    cd {{example}} && fvm dart run ../bin/buggy.dart report --preset exclude-custom-format-lines

test-and-report-example-flutter:
    cd {{example_flutter}} && fvm dart run ../bin/buggy.dart run flutter-test-coverage-workaround
    @echo ""
    @echo "---"
    @echo ""
    cd {{example_flutter}} && fvm flutter test --coverage
    @echo ""
    @echo "---"
    @echo ""
    cd {{example_flutter}} && buggy report
