# Repository Guidelines

## Project Structure & Module Organization
The repository is centered around the `packages/` directory, where each subfolder (for example `packages/flutter` and `packages/flutter_tools`) is an independently versioned Dart package. Shared tooling lives under `dev/`, including the `dev/bots` automation scripts and fixtures used in CI. Command-line entry points, such as the `flutter` tool, reside in `bin/`. Integration samples are in `examples/`, and assets that ship with the SDK are stored under `packages/flutter/assets/`. Unit and widget tests live beside their libraries in `packages/*/test/`, while golden images are organized in `packages/flutter/test/goldens/`.

## Build, Test, and Development Commands
- `./bin/flutter doctor`: Validate that your local toolchain and platform dependencies are configured.
- `./bin/flutter analyze`: Run static analysis and lint checks across the Dart packages.
- `./bin/flutter test --coverage`: Execute unit and widget tests; generates `coverage/lcov.info`.
- `dart run ./dev/bots/test.dart --list`: Inspect CI test shards before running a targeted shard locally.
- `dart run ./dev/bots/analyze.dart`: Mirrors the checks that run in presubmit.

## Coding Style & Naming Conventions
Follow `analysis_options.yaml` for lint rules and rely on `dart format --fix .` to enforce two-space indentation and trailing comma usage. Prefer lowerCamelCase for variables and methods, PascalCase for public types, and prefix tests with the subsystem (e.g., `widget_scrollBehaviour`). Guard platform-specific logic with `kIsWeb`, `defaultTargetPlatform`, or feature flags rather than checking runtime IDs directly.

## Testing Guidelines
Name all test files with the `_test.dart` suffix. When adding golden tests, update baselines with `flutter test --update-goldens` and include the regenerated assets. Integration flows belong in `examples/` with driver scripts under `dev/integration_tests/`. Aim to keep or improve existing coverage; mention any intentional gaps in the PR description.

## Commit & Pull Request Guidelines
Craft commits in the form `area: concise summary` (for example `framework: fix semantics for sliders`) and keep them scoped to a single logical change. Reference issues using `Closes #NNNN` when applicable. Pull requests must describe the motivation, list user-visible changes, and document new tests or screenshots. Ensure `flutter analyze`, `flutter test`, and relevant integration shards succeed before requesting review.
