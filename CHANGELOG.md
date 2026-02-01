# Changelog

[![SemVer 2.0.0][📌semver-img]][📌semver] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog]

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][📗keep-changelog],
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html),
and [yes][📌major-versions-not-sacred], platform and engine support are part of the [public API][📌semver-breaking].
Please file a bug if you notice a violation of semantic versioning.

[📌semver]: https://semver.org/spec/v2.0.0.html
[📌semver-img]: https://img.shields.io/badge/semver-2.0.0-FFDD67.svg?style=flat
[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-FFDD67.svg?style=flat

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [2.0.5] - 2026-02-01

- TAG: [v2.0.5][2.0.5t]
- COVERAGE: 96.10% -- 518/539 lines in 11 files
- BRANCH COVERAGE: 74.72% -- 133/178 branches in 11 files
- 96.33% documented

### Added

- ConflictResolver now applies per-node-type preferences via `node_typing`.

### Changed

- tree_haver v5.0.3
- ast-merge v4.0.5

## [2.0.4] - 2026-01-20

- TAG: [v2.0.4][2.0.4t]
- COVERAGE: 100.00% -- 25/25 lines in 1 files
- BRANCH COVERAGE: 100.00% -- 4/4 branches in 1 files
- 96.33% documented

### Changed

- Upgrade to [ast-merge v4.0.3](https://github.com/kettle-rb/ast-merge/releases/tag/v4.0.3)
- Upgrade to [tree_haver v5.0.2](https://github.com/kettle-rb/tree_haver/releases/tag/v5.0.2)

## [2.0.3] - 2026-01-11

- TAG: [v2.0.3][2.0.3t]
- COVERAGE: 96.16% -- 501/521 lines in 11 files
- BRANCH COVERAGE: 76.22% -- 125/164 branches in 11 files
- 96.33% documented

### Changed

- ast-merge v4.0.2
- tree_haver v5.0.1

## [2.0.2] - 2026-01-09

- TAG: [v2.0.2][2.0.2t]
- COVERAGE: 96.34% -- 500/519 lines in 11 files
- BRANCH COVERAGE: 76.54% -- 124/162 branches in 11 files
- 96.33% documented

### Changed

- tree_haver v4.0.5
  - FFI Backend improvements
  - Error handling improvements
- Improved GHA workflows & rake tasks
- **Simplified dependency_tags.rb**: Removed redundant debug code
  - Removed `BASH_MERGE_DEBUG` env var handling (use `TREE_HAVER_DEBUG` instead)
  - tree_haver's debug output now respects blocked backends via `compute_blocked_backends`
  - Avoids accidentally loading MRI backend during FFI-only test runs

## [2.0.1] - 2026-01-09

- TAG: [v2.0.1][2.0.1t]
- COVERAGE: 96.34% -- 500/519 lines in 11 files
- BRANCH COVERAGE: 76.54% -- 124/162 branches in 11 files
- 96.33% documented

### Added

- FFI backend isolation for test suite
  - Added `bin/rspec-ffi` script to run FFI specs in isolation (before MRI backend loads)
  - Added `spec/spec_ffi_helper.rb` for FFI-specific test configuration
  - Updated Rakefile with `ffi_specs` and `remaining_specs` tasks
  - The `:test` task now runs FFI specs first, then remaining specs
- Emitter-based output

### Changed

- ast-merge v3.1.0, adds Ast::Merge::EmitterBase
- tree_haver v4.0.4, adds error handling for FFI backend
- major spec refactor

## [2.0.0] - 2026-01-06

- TAG: [v2.0.0][2.0.0t]
- COVERAGE: 100.00% -- 109/109 lines in 2 files
- BRANCH COVERAGE: 100.00% -- 28/28 branches in 2 files
- 96.46% documented

### Changed

- ast-merge v3.0.0 compatibility (breaking changes)

## [1.0.2] - 2026-01-02

- TAG: [v1.0.2][1.0.2t]
- COVERAGE: 100.00% -- 109/109 lines in 2 files
- BRANCH COVERAGE: 100.00% -- 28/28 branches in 2 files
- 96.46% documented

### Removed

- **Load-time grammar registration** - TreeHaver's `parser_for` now handles grammar discovery
  and registration automatically. Removed manual `GrammarFinder` calls and warnings from
  `lib/bash/merge.rb`.

## [1.0.1] - 2026-01-01

- TAG: [v1.0.1][1.0.1t]
- COVERAGE: 100.00% -- 109/109 lines in 2 files
- BRANCH COVERAGE: 100.00% -- 28/28 branches in 2 files
- 96.46% documented

### Changed

- **NodeWrapper**: Now inherits from `Ast::Merge::NodeWrapperBase`
  - Removes ~100 lines of duplicated code (initialization, line extraction, basic methods)
  - Keeps only Bash-specific type predicates and signature computation
  - Adds `#node_wrapper?` method for distinguishing from `NodeTyping::Wrapper`
- **FileAnalysis error handling**: Now rescues `TreeHaver::Error` instead of `TreeHaver::NotAvailable`
  - `TreeHaver::Error` inherits from `Exception`, not `StandardError`
  - `TreeHaver::NotAvailable` is a subclass of `TreeHaver::Error`, so it's also caught
  - Fixes parse error handling on alternative Ruby engines

## [1.0.0] - 2026-01-01

- TAG: [v1.0.0][1.0.0t]
- COVERAGE: 100.00% -- 109/109 lines in 2 files
- BRANCH COVERAGE: 100.00% -- 28/28 branches in 2 files
- 96.90% documented

### Added

- Initial release

### Security

[Unreleased]: https://github.com/kettle-rb/bash-merge/compare/v2.0.5...HEAD
[2.0.5]: https://github.com/kettle-rb/bash-merge/compare/v2.0.4...v2.0.5
[2.0.5t]: https://github.com/kettle-rb/bash-merge/releases/tag/v2.0.5
[2.0.4]: https://github.com/kettle-rb/bash-merge/compare/v2.0.3...v2.0.4
[2.0.4t]: https://github.com/kettle-rb/bash-merge/releases/tag/v2.0.4
[2.0.3]: https://github.com/kettle-rb/bash-merge/compare/v2.0.2...v2.0.3
[2.0.3t]: https://github.com/kettle-rb/bash-merge/releases/tag/v2.0.3
[2.0.2]: https://github.com/kettle-rb/bash-merge/compare/v2.0.1...v2.0.2
[2.0.2t]: https://github.com/kettle-rb/bash-merge/releases/tag/v2.0.2
[2.0.1]: https://github.com/kettle-rb/bash-merge/compare/v2.0.0...v2.0.1
[2.0.1t]: https://github.com/kettle-rb/bash-merge/releases/tag/v2.0.1
[2.0.0]: https://github.com/kettle-rb/bash-merge/compare/v1.0.2...v2.0.0
[2.0.0t]: https://github.com/kettle-rb/bash-merge/releases/tag/v2.0.0
[1.0.2]: https://github.com/kettle-rb/bash-merge/compare/v1.0.1...v1.0.2
[1.0.2t]: https://github.com/kettle-rb/bash-merge/releases/tag/v1.0.2
[1.0.1]: https://github.com/kettle-rb/bash-merge/compare/v1.0.0...v1.0.1
[1.0.1t]: https://github.com/kettle-rb/bash-merge/releases/tag/v1.0.1
[1.0.0]: https://github.com/kettle-rb/bash-merge/compare/db525d5aedd0c895422a067629118f3fa9c3c22d...v1.0.0
[1.0.0t]: https://github.com/kettle-rb/bash-merge/tags/v1.0.0
