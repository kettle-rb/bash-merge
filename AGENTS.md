# AGENTS.md - bash-merge Development Guide

## 🎯 Project Overview

`bash-merge` is a **format-specific implementation of the `*-merge` gem family** for Bash shell scripts. It provides intelligent Bash script merging using AST analysis with tree-sitter Bash parser.

**Core Philosophy**: Intelligent Bash script merging that preserves structure, comments, and formatting while applying updates from templates.

**Repository**: https://github.com/kettle-rb/bash-merge
**Current Version**: 2.0.6
**Required Ruby**: >= 3.2.0 (currently developed against Ruby 4.0.1)

## ⚠️ AI Agent Terminal Limitations

### Terminal Output Is Available, but Each Command Is Isolated

**CRITICAL**: AI agents can reliably read terminal output when commands run in the background and the output is polled afterward. However, each terminal command should be treated as a fresh shell with no shared state.

**Use this pattern**:
1. Run commands with background execution enabled.
2. Fetch the output afterward.
3. Make every command self-contained — do **not** rely on a previous `cd`, `export`, alias, or shell function.

### Use `mise` for Project Environment

**CRITICAL**: The canonical project environment now lives in `mise.toml`, with local overrides in `.env.local` loaded via `dotenvy`.

⚠️ **Watch for trust prompts**: After editing `mise.toml` or `.env.local`, `mise` may require trust to be refreshed before commands can load the project environment. That interactive trust screen can masquerade as missing terminal output, so commands may appear hung or silent until you handle it.

**Recovery rule**: If a `mise exec` command in this repo goes silent, appears hung, or terminal polling stops returning useful output, assume `mise trust` is needed first and recover with:

```bash
mise trust -C /home/pboling/src/kettle-rb/bash-merge
mise exec -C /home/pboling/src/kettle-rb/bash-merge -- bundle exec rspec
```

Do this before spending time on unrelated debugging; in this workspace, silent `mise` commands are usually a trust problem.

```bash
mise trust -C /home/pboling/src/kettle-rb/bash-merge
```

✅ **CORRECT**:
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

### Prefer Internal Tools Over Terminal

Use `read_file`, `list_dir`, `grep_search`, `file_search` instead of terminal commands for gathering information. Only use terminal for running tests, installing dependencies, and git operations.

### Workspace layout

This repo is a sibling project inside the `/home/pboling/src/kettle-rb` workspace, not a vendored dependency under another repo.

### NEVER Pipe Test Commands Through head/tail

Run the plain command and inspect the full output afterward. Do not truncate test output.

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

### Coverage Reports

```bash
mise exec -C /home/pboling/src/kettle-rb/bash-merge -- bin/rake coverage
mise exec -C /home/pboling/src/kettle-rb/bash-merge -- bin/kettle-soup-cover -d
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

**Freeze Blocks**:
```bash
# bash-merge:freeze
export CUSTOM_VAR="don't override"
alias custom="my custom alias"
# bash-merge:unfreeze

function main() {
  echo "Hello"
}
```

## 🧪 Testing Patterns

### TreeHaver Dependency Tags

**Available tags**:
- `:bash_grammar` – Requires Bash grammar (any backend)
- `:mri_backend` – Requires tree-sitter MRI backend
- `:rust_backend` – Requires tree-sitter Rust backend
- `:bash_parsing` – Requires any Bash parser

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
