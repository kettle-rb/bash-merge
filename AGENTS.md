# AGENTS.md - bash-merge Development Guide

## 🎯 Project Overview

`bash-merge` is a **format-specific implementation of the `*-merge` gem family** for Bash shell scripts. It provides intelligent Bash script merging using AST analysis with tree-sitter Bash parser.

**Core Philosophy**: Intelligent Bash script merging that preserves structure, comments, and formatting while applying updates from templates.

**Repository**: https://github.com/kettle-rb/bash-merge
**Current Version**: 2.0.6
**Required Ruby**: >= 3.2.0 (currently developed against Ruby 4.0.1)

## ⚠️ AI Agent Terminal Limitations

### Terminal Output Is Not Visible

**CRITICAL**: AI agents using `run_in_terminal` almost never see the command output. The terminal tool sends commands to a persistent Copilot terminal, but output is frequently lost or invisible to the agent.

**Workaround**: Always redirect output to a file in the project's local `tmp/` directory, then read it back with `read_file`:

```bash
bundle exec rspec spec/some_spec.rb > tmp/test_output.txt 2>&1
```

**NEVER** use `/tmp` or other system directories — always use the project's own `tmp/` directory.

### direnv Requires Separate `cd` Command

**CRITICAL**: Never chain `cd` with other commands via `&&`. The `direnv` environment won't initialize until after all chained commands finish. Run `cd` alone first:

✅ **CORRECT**:
```bash
cd /home/pboling/src/kettle-rb/ast-merge/vendor/bash-merge
```
```bash
bundle exec rspec > tmp/test_output.txt 2>&1
```

❌ **WRONG**:
```bash
cd /home/pboling/src/kettle-rb/ast-merge/vendor/bash-merge && bundle exec rspec
```

### Prefer Internal Tools Over Terminal

Use `read_file`, `list_dir`, `grep_search`, `file_search` instead of terminal commands for gathering information. Only use terminal for running tests, installing dependencies, and git operations.

### grep_search Cannot Search Nested Git Projects

This project is a nested git project inside the `ast-merge` workspace. The `grep_search` tool **cannot** search inside it. Use `read_file` and `list_dir` instead.

### NEVER Pipe Test Commands Through head/tail

Always redirect to a file in `tmp/` instead of truncating output.

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
bundle exec rspec

# Single file (disable coverage threshold check)
K_SOUP_COV_MIN_HARD=false bundle exec rspec spec/bash/merge/smart_merger_spec.rb

# Specific backend tests
bundle exec rspec --tag mri_backend
bundle exec rspec --tag rust_backend
bundle exec rspec --tag bash_grammar
```

### Coverage Reports

```bash
cd /home/pboling/src/kettle-rb/ast-merge/vendor/bash-merge
bin/rake coverage && bin/kettle-soup-cover -d
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
