# frozen_string_literal: true

# SmartMerger specs with explicit backend testing
#
# This spec file tests SmartMerger behavior across all available tree-sitter backends:
# - :mri (via ruby_tree_sitter gem, tagged :mri_backend)
# - :ffi (via FFI bindings, tagged :ffi_backend)
# - :rust (via tree_stump gem, tagged :rust_backend)
# - :java (via jtreesitter, tagged :java_backend)

RSpec.describe Bash::Merge::SmartMerger do
  # ============================================================
  # :auto backend tests (uses whatever is available)
  # ============================================================

  context "with :auto backend", :bash_grammar do
    it_behaves_like "basic initialization"
    it_behaves_like "configuration options"
    it_behaves_like "instance methods"
    it_behaves_like "accessors"
    it_behaves_like "basic merge operation"
    it_behaves_like "template preference"
    it_behaves_like "merge_with_debug"
    it_behaves_like "validation"
    it_behaves_like "add template-only nodes"
    it_behaves_like "freeze blocks"
    it_behaves_like "custom freeze token"
    it_behaves_like "function merging"
    it_behaves_like "complex scripts"
  end

  # ============================================================
  # Backend-aware tests - MRI/ruby_tree_sitter
  # ============================================================

  context "with MRI backend", :bash_grammar, :mri_backend do
    around do |example|
      TreeHaver.with_backend(:mri) do
        example.run
      end
    end

    it_behaves_like "basic initialization"
    it_behaves_like "configuration options"
    it_behaves_like "instance methods"
    it_behaves_like "accessors"
    it_behaves_like "basic merge operation"
    it_behaves_like "template preference"
    it_behaves_like "merge_with_debug"
    it_behaves_like "validation"
    it_behaves_like "add template-only nodes"
    it_behaves_like "freeze blocks"
    it_behaves_like "custom freeze token"
    it_behaves_like "function merging"
    it_behaves_like "complex scripts"
  end

  # ============================================================
  # Backend-aware tests - FFI
  # ============================================================

  context "with FFI backend", :bash_grammar, :ffi_backend do
    around do |example|
      TreeHaver.with_backend(:ffi) do
        example.run
      end
    end

    it_behaves_like "basic initialization"
    it_behaves_like "configuration options"
    it_behaves_like "instance methods"
    it_behaves_like "accessors"
    it_behaves_like "basic merge operation"
    it_behaves_like "template preference"
    it_behaves_like "merge_with_debug"
    it_behaves_like "validation"
    it_behaves_like "add template-only nodes"
    it_behaves_like "freeze blocks"
    it_behaves_like "custom freeze token"
    it_behaves_like "function merging"
    it_behaves_like "complex scripts"
  end

  # ============================================================
  # Backend-aware tests - Rust/tree_stump
  # ============================================================

  context "with Rust backend", :bash_grammar, :rust_backend do
    around do |example|
      TreeHaver.with_backend(:rust) do
        example.run
      end
    end

    it_behaves_like "basic initialization"
    it_behaves_like "configuration options"
    it_behaves_like "instance methods"
    it_behaves_like "accessors"
    it_behaves_like "basic merge operation"
    it_behaves_like "template preference"
    it_behaves_like "merge_with_debug"
    it_behaves_like "validation"
    it_behaves_like "add template-only nodes"
    it_behaves_like "freeze blocks"
    it_behaves_like "custom freeze token"
    it_behaves_like "function merging"
    it_behaves_like "complex scripts"
  end

  # ============================================================
  # Backend-aware tests - Java/jtreesitter
  # ============================================================

  context "with Java backend", :bash_grammar, :java_backend do
    around do |example|
      TreeHaver.with_backend(:java) do
        example.run
      end
    end

    it_behaves_like "basic initialization"
    it_behaves_like "configuration options"
    it_behaves_like "instance methods"
    it_behaves_like "accessors"
    it_behaves_like "basic merge operation"
    it_behaves_like "template preference"
    it_behaves_like "merge_with_debug"
    it_behaves_like "validation"
    it_behaves_like "add template-only nodes"
    it_behaves_like "freeze blocks"
    it_behaves_like "custom freeze token"
    it_behaves_like "function merging"
    it_behaves_like "complex scripts"
  end
end
