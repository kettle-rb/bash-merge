# frozen_string_literal: true

require "spec_helper"

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
    it_behaves_like "duplicate command signatures"
    it_behaves_like "complex scripts"
    it_behaves_like "document boundary comments"
    it_behaves_like "matched leading comments"
    it_behaves_like "removed node leading comments"
    it_behaves_like "conservative inline comments"
    it_behaves_like "removed node inline comments"
    it_behaves_like "multi-byte character (emoji) handling"
    it_behaves_like "floating comment gap transitions"
  end

  describe "duplicate template preamble healing", :bash_grammar, :mri_backend do
    around do |example|
      TreeHaver.with_backend(:mri) do
        example.run
      end
    end

    let(:template_content) do
      <<~BASH
        # Shared header

        alpha=1
      BASH
    end

    let(:destination_content) do
      <<~BASH
        # Shared header
        # Shared header
        # Destination header
        alpha=9
      BASH
    end

    it "collapses the duplicated template prefix in heal mode" do
      merged = described_class.new(
        template_content,
        destination_content,
        add_template_only_nodes: true,
      ).merge

      expect(merged.lines.grep("# Shared header\n").size).to eq(0)
      expect(merged.lines.grep("# Destination header\n").size).to eq(1)
      expect(merged).to include("alpha=9")
    end

    it "preserves the duplicated prefix in skip mode" do
      merged = described_class.new(
        template_content,
        destination_content,
        add_template_only_nodes: true,
        corruption_handling: :skip,
      ).merge

      expect(merged.lines.grep("# Shared header\n").size).to eq(3)
      expect(merged.lines.grep("# Destination header\n").size).to eq(1)
    end

    it "warns and preserves the duplicated prefix in warn mode" do
      allow(Bash::Merge::DebugLogger).to receive(:debug_warning)

      merged = described_class.new(
        template_content,
        destination_content,
        add_template_only_nodes: true,
        corruption_handling: :warn,
      ).merge

      expect(Bash::Merge::DebugLogger).to have_received(:debug_warning).with(
        /Suspected corruption \(duplicate_template_preamble_prefix\)/,
        hash_including(template_comment_lines: 2, merged_comment_lines: 4, destination_specific_comment_lines: 1),
      )
      expect(merged.lines.grep("# Shared header\n").size).to eq(3)
    end

    it "raises in error mode" do
      expect {
        described_class.new(
          template_content,
          destination_content,
          add_template_only_nodes: true,
          corruption_handling: :error,
        ).merge
      }.to raise_error(Bash::Merge::CorruptionDetectedError, /duplicate_template_preamble_prefix/)
    end
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
    it_behaves_like "duplicate command signatures"
    it_behaves_like "complex scripts"
    it_behaves_like "document boundary comments"
    it_behaves_like "matched leading comments"
    it_behaves_like "removed node leading comments"
    it_behaves_like "conservative inline comments"
    it_behaves_like "removed node inline comments"
    it_behaves_like "multi-byte character (emoji) handling"
    it_behaves_like "floating comment gap transitions"
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
    it_behaves_like "duplicate command signatures"
    it_behaves_like "complex scripts"
    it_behaves_like "document boundary comments"
    it_behaves_like "matched leading comments"
    it_behaves_like "removed node leading comments"
    it_behaves_like "conservative inline comments"
    it_behaves_like "removed node inline comments"
    it_behaves_like "multi-byte character (emoji) handling"
    it_behaves_like "floating comment gap transitions"
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
    it_behaves_like "duplicate command signatures"
    it_behaves_like "complex scripts"
    it_behaves_like "document boundary comments"
    it_behaves_like "matched leading comments"
    it_behaves_like "removed node leading comments"
    it_behaves_like "conservative inline comments"
    it_behaves_like "removed node inline comments"
    it_behaves_like "multi-byte character (emoji) handling"
    it_behaves_like "floating comment gap transitions"
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
    it_behaves_like "duplicate command signatures"
    it_behaves_like "complex scripts"
    it_behaves_like "document boundary comments"
    it_behaves_like "matched leading comments"
    it_behaves_like "removed node leading comments"
    it_behaves_like "conservative inline comments"
    it_behaves_like "removed node inline comments"
    it_behaves_like "multi-byte character (emoji) handling"
    it_behaves_like "floating comment gap transitions"
  end
end
