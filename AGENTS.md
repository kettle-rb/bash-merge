# AGENTS.md - bash-merge Development Guide

# AGENTS.md - Development Guide

## 🎯 Project Overview

```bash
mise exec -C /path/to/project -- bundle exec rspec
```

✅ **CORRECT** — If you need shell syntax first, load the environment in the same command:

This project is a **RubyGem** managed with the [kettle-rb](https://github.com/kettle-rb) toolchain.

## 🏗️ Architecture

### Toolchain Dependencies

This gem is part of the **kettle-rb** ecosystem. Key development tools:

## ⚠️ AI Agent Terminal Limitations

### Terminal Output Is Available, but Each Command Is Isolated

**Minimum Supported Ruby**: See the gemspec `required_ruby_version` constraint.
**Local Development Ruby**: See `.tool-versions` for the version used in local development (typically the latest stable Ruby).

**Use this pattern**:

### Test Infrastructure

- Uses `kettle-test` for RSpec helpers (stubbed_env, block_is_expected, silent_stream, timecop)
- Uses `Dir.mktmpdir` for isolated filesystem tests
- Spec helper is loaded by `.rspec` — never add `require "spec_helper"` to spec files

### Use `mise` for Project Environment

**CRITICAL**: The canonical project environment lives in `mise.toml`, with local overrides in `.env.local` loaded via `dotenvy`.

⚠️ **Watch for trust prompts**: After editing `mise.toml` or `.env.local`, `mise` may require trust to be refreshed before commands can load the project environment. Until that trust step is handled, commands can appear hung or produce no output, which can look like terminal access is broken.

**Recovery rule**: If a `mise exec` command goes silent or appears hung, assume `mise trust` is the first thing to check. Recover by running:

```bash
mise trust -C /home/pboling/src/kettle-rb/bash-merge
mise exec -C /home/pboling/src/kettle-rb/bash-merge -- bundle exec rspec
```

```bash
mise trust -C /path/to/project
mise exec -C /path/to/project -- bundle exec rspec
```

Do this before spending time on unrelated debugging; in this workspace pattern, silent `mise` commands are usually a trust problem first.

```bash
mise trust -C /home/pboling/src/kettle-rb/bash-merge
```

✅ **CORRECT** — Run self-contained commands with `mise exec`:

```bash
mise exec -C /home/pboling/src/kettle-rb/bash-merge -- bundle exec rspec
```

✅ **CORRECT**:
```bash
eval "$(mise env -C /home/pboling/src/kettle-rb/bash-merge -s bash)" && bundle exec rspec
```

❌ **WRONG**:
```bash
cd /home/pboling/src/kettle-rb/bash-merge
bundle exec rspec
```

❌ **WRONG**:
```bash
cd /home/pboling/src/kettle-rb/bash-merge && bundle exec rspec
```

```bash
eval "$(mise env -C /path/to/project -s bash)" && bundle exec rspec
```

❌ **WRONG** — Do not rely on a previous command changing directories:
```bash
cd /path/to/project
bundle exec rspec
```

❌ **WRONG** — A chained `cd` does not give directory-change hooks time to update the environment:
```bash
cd /path/to/project && bundle exec rspec
```

### Prefer Internal Tools Over Terminal

### Environment Variable Helpers

```ruby
before do
  stub_env("MY_ENV_VAR" => "value")
end

before do
  hide_env("HOME", "USER")
end
```

### Dependency Tags

Use dependency tags to conditionally skip tests when optional dependencies are not available:

### Workspace layout

### Running Commands

Always make commands self-contained. Use `mise exec -C /home/pboling/src/kettle-rb/prism-merge -- ...` so the command gets the project environment in the same invocation.

### NEVER Pipe Test Commands Through head/tail

When you do run tests, keep the full output visible so you can inspect failures completely.

## 🏗️ Architecture: Format-Specific Implementation

### What bash-merge Provides

- **`Bash::Merge::SmartMerger`** – Bash-specific SmartMerger implementation
- **`Bash::Merge::FileAnalysis`** – Bash file analysis with function/command extraction
- **`Bash::Merge::NodeWrapper`** – Wrapper for Bash AST nodes
- **`Bash::Merge::MergeResult`** – Bash-specific merge result
- **`Bash::Merge::ConflictResolver`** – Bash conflict resolution
- **`Bash::Merge::FreezeNode`** – Bash freeze block support
- **`Bash::Merge::DebugLogger`** – Bash-specific debug logging

### Key Dependencies

| Gem | Role |
|-----|------|
| `ast-merge` (~> 4.0) | Base classes and shared infrastructure |
| `tree_haver` (~> 5.0) | Unified parser adapter (tree-sitter) |
| `version_gem` (~> 1.1) | Version management |

### Parser Backend Support

bash-merge works with tree-sitter Bash parser via TreeHaver:

| Backend | Parser | Platform | Notes |
|---------|--------|----------|-------|
| `:mri` | tree-sitter-bash | MRI only | Best performance, requires native library |
| `:rust` | tree-sitter-bash | MRI only | Rust implementation via tree_stump |

| Tool | Purpose |
|------|---------|
| `kettle-dev` | Development dependency: Rake tasks, release tooling, CI helpers |
| `kettle-test` | Test infrastructure: RSpec helpers, stubbed_env, timecop |
| `kettle-jem` | Template management and gem scaffolding |

### Executables (from kettle-dev)

| Executable | Purpose |
|-----------|---------|
| `kettle-release` | Full gem release workflow |
| `kettle-pre-release` | Pre-release validation |
| `kettle-changelog` | Changelog generation |
| `kettle-dvcs` | DVCS (git) workflow automation |
| `kettle-commit-msg` | Commit message validation |
| `kettle-check-eof` | EOF newline validation |

## 📁 Project Structure

```
lib/bash/merge/
├── smart_merger.rb          # Main SmartMerger implementation
├── file_analysis.rb         # Bash file analysis
├── node_wrapper.rb          # AST node wrapper
├── merge_result.rb          # Merge result object
├── conflict_resolver.rb     # Conflict resolution
├── freeze_node.rb           # Freeze block support
├── debug_logger.rb          # Debug logging
└── version.rb

spec/bash/merge/
├── smart_merger_spec.rb
├── file_analysis_spec.rb
├── node_wrapper_spec.rb
└── integration/
```

```
lib/
├── <gem_namespace>/           # Main library code
│   └── version.rb             # Version constant (managed by kettle-release)
spec/
├── fixtures/                  # Test fixture files (NOT auto-loaded)
├── support/
│   ├── classes/               # Helper classes for specs
│   └── shared_contexts/       # Shared RSpec contexts
├── spec_helper.rb             # RSpec configuration (loaded by .rspec)
gemfiles/
├── modular/                   # Modular Gemfile components
│   ├── coverage.gemfile       # SimpleCov dependencies
│   ├── debug.gemfile          # Debugging tools
│   ├── documentation.gemfile  # YARD/documentation
│   ├── optional.gemfile       # Optional dependencies
│   ├── rspec.gemfile          # RSpec testing
│   ├── style.gemfile          # RuboCop/linting
│   └── x_std_libs.gemfile     # Extracted stdlib gems
├── ruby_*.gemfile             # Per-Ruby-version Appraisal Gemfiles
└── Appraisal.root.gemfile     # Root Gemfile for Appraisal builds
.git-hooks/
├── commit-msg                 # Commit message validation hook
├── prepare-commit-msg         # Commit message preparation
├── commit-subjects-goalie.txt # Commit subject prefix filters
└── footer-template.erb.txt    # Commit footer ERB template
```

## 🔧 Development Workflows

### Running Tests

```bash
# Full suite
mise exec -C /home/pboling/src/kettle-rb/bash-merge -- bundle exec rspec

# Single file (disable coverage threshold check)
mise exec -C /home/pboling/src/kettle-rb/bash-merge -- env K_SOUP_COV_MIN_HARD=false bundle exec rspec spec/bash/merge/smart_merger_spec.rb

# Specific backend tests
mise exec -C /home/pboling/src/kettle-rb/bash-merge -- bundle exec rspec --tag mri_backend
mise exec -C /home/pboling/src/kettle-rb/bash-merge -- bundle exec rspec --tag rust_backend
mise exec -C /home/pboling/src/kettle-rb/bash-merge -- bundle exec rspec --tag bash_grammar
```

Full suite spec runs:

```bash
mise exec -C /path/to/project -- bundle exec rspec
```

For single file, targeted, or partial spec runs the coverage threshold **must** be disabled.
Use the `K_SOUP_COV_MIN_HARD=false` environment variable to disable hard failure:

```bash
mise exec -C /path/to/project -- env K_SOUP_COV_MIN_HARD=false bundle exec rspec spec/path/to/spec.rb
```

### Coverage Reports

```bash
mise exec -C /home/pboling/src/kettle-rb/bash-merge -- bin/rake coverage
mise exec -C /home/pboling/src/kettle-rb/bash-merge -- bin/kettle-soup-cover -d
```

```bash
mise exec -C /path/to/project -- bin/rake coverage
mise exec -C /path/to/project -- bin/kettle-soup-cover -d
```

**Key ENV variables** (set in `mise.toml`, with local overrides in `.env.local`):

- Running tests (`bundle exec rspec`)
- Installing dependencies (`bundle install`)
- Git operations that require interaction
- Commands that actually need to execute (not just gather info)

### Code Quality

```bash
mise exec -C /path/to/project -- bundle exec rake reek
mise exec -C /path/to/project -- bundle exec rubocop-gradual
```

### Releasing

```bash
bin/kettle-pre-release    # Validate everything before release
bin/kettle-release        # Full release workflow
```

## 📝 Project Conventions

### API Conventions

#### SmartMerger API

- `merge` – Returns a **String** (the merged Bash content)
- `merge_result` – Returns a **MergeResult** object
- `to_s` on MergeResult returns the merged content as a string

#### Bash-Specific Features

**Function Merging**:
```bash
# Template
function setup() {
  echo "Setting up..."
}

# Destination with customization
function setup() {
  echo "Custom setup..."
}
```

### Freeze Block Preservation

Template updates preserve custom code wrapped in freeze blocks:

```bash
# bash-merge:freeze
export CUSTOM_VAR="don't override"
alias custom="my custom alias"
# bash-merge:unfreeze

function main() {
  echo "Hello"
}
```

```ruby
# kettle-jem:freeze
# ... custom code preserved across template runs ...
# kettle-jem:unfreeze
```

### Modular Gemfile Architecture

Gemfiles are split into modular components under `gemfiles/modular/`. Each component handles a specific concern (coverage, style, debug, etc.). The main `Gemfile` loads these modular components via `eval_gemfile`.

### Forward Compatibility with `**options`

**CRITICAL**: All constructors and public API methods that accept keyword arguments MUST include `**options` as the final parameter for forward compatibility.

## 🧪 Testing Patterns

### TreeHaver Dependency Tags

✅ **PREFERRED** — Use internal tools:

- `grep_search` instead of `grep` command
- `file_search` instead of `find` command
- `read_file` instead of `cat` command
- `list_dir` instead of `ls` command
- `replace_string_in_file` or `create_file` instead of `sed` / manual editing

❌ **AVOID** when possible:
- `run_in_terminal` for information gathering

Only use terminal for:

- `K_SOUP_COV_DO=true` – Enable coverage
- `K_SOUP_COV_MIN_LINE` – Line coverage threshold
- `K_SOUP_COV_MIN_BRANCH` – Branch coverage threshold
- `K_SOUP_COV_MIN_HARD=true` – Fail if thresholds not met

✅ **CORRECT**:
```ruby
RSpec.describe Bash::Merge::SmartMerger, :bash_grammar do
  # Skipped if no Bash parser available
end
```

❌ **WRONG**:
```ruby
before do
  skip "Requires tree-sitter" unless bash_available?  # DO NOT DO THIS
end
```

## 💡 Key Insights

1. **Function matching**: Bash functions matched by name
2. **Variable/export handling**: Variable assignments can be tracked
3. **Comment preservation**: Bash comments preserved and associated with statements
4. **Freeze blocks use `# bash-merge:freeze`**: Standard comment syntax
5. **Shebang preservation**: `#!/bin/bash` is preserved at top of file
6. **Backend isolation**: MRI and Rust backends available

```ruby
RSpec.describe SomeClass, :prism_merge do
  # Skipped if prism-merge is not available
end
```

## 🚫 Common Pitfalls

1. **NEVER mix FFI and MRI backends** – Use `TreeHaver.with_backend` for isolation
2. **NEVER use manual skip checks** – Use dependency tags (`:bash_grammar`, `:mri_backend`)
3. **Do NOT load vendor gems** – They are not part of this project; they do not exist in CI
4. **Use `tmp/` for temporary files** – Never use `/tmp` or other system directories
5. **Do NOT expect `cd` to persist** – Every terminal command is isolated; use a self-contained `mise exec -C ... -- ...` invocation.
6. **Do NOT rely on prior shell state** – Previous `cd`, `export`, aliases, and functions are not available to the next command.

## 🔧 Bash-Specific Notes

### Node Types

```bash
function_definition   # function name() { }
command              # Simple commands
pipeline             # cmd1 | cmd2
variable_assignment  # VAR=value
export_statement     # export VAR=value
```

### Merge Behavior

- **Functions**: Matched by function name; entire function replaced
- **Exports**: Matched by variable name
- **Commands**: Position-based matching
- **Comments**: Preserved when attached to statements
- **Freeze blocks**: Protect customizations from template updates
- **Shebang**: Always preserved at top of file

1. **NEVER add backward compatibility** — No shims, aliases, or deprecation layers. Bump major version instead.
2. **NEVER expect `cd` to persist** — Every terminal command is isolated; use a self-contained `mise exec -C ... -- ...` invocation.
3. **NEVER pipe test output through `head`/`tail`** — Run tests without truncation so you can inspect the full output.
4. **Terminal commands do not share shell state** — Previous `cd`, `export`, aliases, and functions are not available to the next command.
