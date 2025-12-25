# frozen_string_literal: true

# Dependency detection helpers for conditional test execution in bash-merge
#
# This module detects whether the tree-sitter bash grammar is available
# and configures RSpec to skip tests that require unavailable dependencies.
#
# BACKEND COMPATIBILITY for Bash:
# - FFI: Most portable and reliable with bash grammar (recommended)
# - MRI: Has ABI incompatibility with bash grammar
# - Rust: Has version mismatch with bash grammar
#
# Set TREE_HAVER_BACKEND=ffi (or mri/rust) to control backend selection.
# When MRI loads a grammar first, FFI gets incompatible pointers (symbol conflict).
# MRI statically links tree-sitter, FFI dynamically links libtree-sitter.so.
#
# Usage in specs:
#   it "requires tree-sitter-bash", :tree_sitter_bash do
#     # This test only runs when tree-sitter-bash is available
#   end

module BashMergeDependencies
  # Test source code for verifying parsing works
  TEST_SOURCE = "echo hello"

  class << self
    # Check if tree-sitter-bash grammar is available and parsing works
    def tree_sitter_bash_available?
      return @tree_sitter_bash_available if defined?(@tree_sitter_bash_available)

      @tree_sitter_bash_available = begin
        # TreeHaver handles grammar discovery and raises NotAvailable if not found
        # Set TREE_HAVER_BACKEND=ffi for bash (MRI/Rust have compatibility issues)
        parser = TreeHaver.parser_for(:bash)
        result = parser.parse(TEST_SOURCE)
        !result.nil? && result.root_node && !result.root_node.has_error?
      rescue StandardError
        false
      end
    end

    # Check if running on JRuby
    def jruby?
      defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby"
    end

    # Check if running on MRI (CRuby)
    def mri?
      defined?(RUBY_ENGINE) && RUBY_ENGINE == "ruby"
    end

    # Get a summary of available dependencies (for debugging)
    def summary
      {
        tree_haver_backend: ENV.fetch("TREE_HAVER_BACKEND", "auto"),
        tree_sitter_bash: tree_sitter_bash_available?,
        ruby_engine: RUBY_ENGINE,
        jruby: jruby?,
        mri: mri?,
      }
    end
  end
end

RSpec.configure do |config|
  # Define exclusion filters for optional dependencies
  # Tests tagged with these will be skipped when the dependency is not available

  config.before(:suite) do
    # Print dependency summary if BASH_MERGE_DEBUG is set
    if ENV["BASH_MERGE_DEBUG"]
      puts "\n=== Bash::Merge Test Dependencies ==="
      BashMergeDependencies.summary.each do |dep, available|
        status = case available
        when true then "✓ available"
        when false then "✗ not available"
        when nil then "✗ none"
        when Symbol then "✓ #{available}"
        else available.to_s
        end
        puts "  #{dep}: #{status}"
      end
      puts "======================================\n"
    end
  end

  # ============================================================
  # Positive tags: run when dependency IS available
  # ============================================================

  # Skip tests tagged :tree_sitter_bash when tree-sitter-bash grammar is not available
  config.filter_run_excluding tree_sitter_bash: true unless BashMergeDependencies.tree_sitter_bash_available?

  # Skip tests tagged :jruby when not running on JRuby
  config.filter_run_excluding jruby: true unless BashMergeDependencies.jruby?

  # ============================================================
  # Negated tags: run when dependency is NOT available
  # ============================================================

  # Skip tests tagged :not_tree_sitter_bash when tree-sitter-bash IS available
  config.filter_run_excluding not_tree_sitter_bash: true if BashMergeDependencies.tree_sitter_bash_available?

  # Skip tests tagged :not_jruby when running on JRuby
  config.filter_run_excluding not_jruby: true if BashMergeDependencies.jruby?
end

