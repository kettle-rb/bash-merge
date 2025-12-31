# frozen_string_literal: true

RSpec.describe Bash::Merge::FileAnalysis do
  # Note: These tests require tree-sitter-bash to be installed
  # They use fallback behavior when parser is not available

  describe "#initialize" do
    it "accepts source code" do
      source = "#!/bin/bash\necho 'hello'"
      analysis = described_class.new(source)
      expect(analysis.source).to eq(source)
    end

    it "accepts freeze_token option" do
      analysis = described_class.new("echo 'test'", freeze_token: "custom-token")
      expect(analysis.freeze_token).to eq("custom-token")
    end

    it "uses default freeze token" do
      analysis = described_class.new("echo 'test'")
      expect(analysis.freeze_token).to eq("bash-merge")
    end

    it "accepts signature_generator option" do
      custom_gen = ->(node) { [:custom, node.class.name] }
      analysis = described_class.new("echo 'test'", signature_generator: custom_gen)
      expect(analysis).to be_a(described_class)
    end

    it "accepts additional options for forward compatibility" do
      # Should not raise even with unknown options
      expect {
        described_class.new("echo 'test'", unknown_option: true, another: "value")
      }.not_to raise_error
    end
  end

  describe "#valid?" do
    context "when parser is not available" do
      it "returns false with error" do
        # Force a non-existent parser path
        analysis = described_class.new("echo 'test'", parser_path: "/nonexistent/path.so")
        expect(analysis.valid?).to be(false)
        expect(analysis.errors).not_to be_empty
      end
    end

    context "when parser is available", :bash_grammar do
      it "returns true for valid bash" do
        analysis = described_class.new("echo 'hello'")
        expect(analysis.valid?).to be true
      end

      it "returns true for empty source" do
        analysis = described_class.new("")
        expect(analysis.valid?).to be true
      end
    end
  end

  describe "#lines" do
    it "returns source split into lines" do
      source = "line1\nline2\nline3"
      analysis = described_class.new(source)
      expect(analysis.lines).to eq(["line1", "line2", "line3"])
    end
  end

  describe "#line_at" do
    it "returns the line at the given 1-based index" do
      source = "line1\nline2\nline3"
      analysis = described_class.new(source)
      expect(analysis.line_at(2)).to eq("line2")
    end

    it "returns nil for out-of-bounds index" do
      analysis = described_class.new("line1")
      expect(analysis.line_at(5)).to be_nil
    end
  end

  describe "#normalized_line" do
    it "returns stripped line content" do
      source = "  indented  "
      analysis = described_class.new(source)
      expect(analysis.normalized_line(1)).to eq("indented")
    end
  end

  describe "#freeze_blocks" do
    it "extracts freeze blocks from source" do
      source = <<~BASH
        #!/bin/bash
        # bash-merge:freeze
        SECRET="value"
        # bash-merge:unfreeze
        echo "hello"
      BASH

      analysis = described_class.new(source)
      expect(analysis.freeze_blocks.size).to eq(1)
    end

    it "handles nested or multiple freeze blocks" do
      source = <<~BASH
        #!/bin/bash
        # bash-merge:freeze
        SECRET1="value1"
        # bash-merge:unfreeze
        echo "between"
        # bash-merge:freeze
        SECRET2="value2"
        # bash-merge:unfreeze
      BASH

      analysis = described_class.new(source)
      expect(analysis.freeze_blocks.size).to eq(2)
    end

    it "handles unmatched freeze markers" do
      source = <<~BASH
        #!/bin/bash
        # bash-merge:freeze
        SECRET="value"
        # No unfreeze marker
      BASH

      analysis = described_class.new(source)
      # Unmatched freeze markers should not create blocks
      expect(analysis.freeze_blocks.size).to eq(0)
    end
  end

  describe "#in_freeze_block?" do
    it "returns true for lines inside freeze blocks" do
      source = <<~BASH
        #!/bin/bash
        # bash-merge:freeze
        SECRET="value"
        # bash-merge:unfreeze
      BASH

      analysis = described_class.new(source)
      expect(analysis.in_freeze_block?(3)).to be(true)
    end

    it "returns false for lines outside freeze blocks" do
      source = <<~BASH
        #!/bin/bash
        # bash-merge:freeze
        SECRET="value"
        # bash-merge:unfreeze
        echo "hello"
      BASH

      analysis = described_class.new(source)
      expect(analysis.in_freeze_block?(5)).to be(false)
    end

    it "returns true for freeze marker lines" do
      source = <<~BASH
        #!/bin/bash
        # bash-merge:freeze
        SECRET="value"
        # bash-merge:unfreeze
      BASH

      analysis = described_class.new(source)
      expect(analysis.in_freeze_block?(2)).to be(true) # freeze marker
      expect(analysis.in_freeze_block?(4)).to be(true) # unfreeze marker
    end
  end

  describe "#freeze_block_at" do
    it "returns the freeze block containing the line" do
      source = <<~BASH
        #!/bin/bash
        # bash-merge:freeze
        SECRET="value"
        # bash-merge:unfreeze
      BASH

      analysis = described_class.new(source)
      block = analysis.freeze_block_at(3)
      expect(block).to be_a(Bash::Merge::FreezeNode)
    end

    it "returns nil for lines not in freeze blocks" do
      source = <<~BASH
        #!/bin/bash
        echo "hello"
      BASH

      analysis = described_class.new(source)
      expect(analysis.freeze_block_at(2)).to be_nil
    end
  end

  describe "#comment_tracker" do
    it "returns a CommentTracker instance" do
      analysis = described_class.new("# comment")
      expect(analysis.comment_tracker).to be_a(Bash::Merge::CommentTracker)
    end
  end

  describe "#root_node", :bash_grammar do
    it "returns a NodeWrapper for the root" do
      analysis = described_class.new("echo 'hello'")
      expect(analysis.root_node).to be_a(Bash::Merge::NodeWrapper)
    end

    it "returns nil when invalid" do
      analysis = described_class.new("echo 'hello'", parser_path: "/nonexistent/path.so")
      expect(analysis.root_node).to be_nil
    end
  end

  describe "#top_level_statements", :bash_grammar do
    it "returns top-level statements" do
      source = <<~BASH
        echo "one"
        echo "two"
        echo "three"
      BASH
      analysis = described_class.new(source)
      statements = analysis.top_level_statements
      expect(statements).to be_an(Array)
      expect(statements.size).to be >= 3
    end

    it "excludes comments from statements" do
      source = <<~BASH
        # This is a comment
        echo "one"
      BASH
      analysis = described_class.new(source)
      statements = analysis.top_level_statements
      expect(statements.none? { |s| s.comment? }).to be true
    end

    it "returns empty array when invalid" do
      analysis = described_class.new("echo 'hello'", parser_path: "/nonexistent/path.so")
      expect(analysis.top_level_statements).to eq([])
    end
  end

  describe "#nodes and #statements", :bash_grammar do
    it "returns nodes including freeze blocks" do
      source = <<~BASH
        echo "before"
        # bash-merge:freeze
        SECRET="value"
        # bash-merge:unfreeze
        echo "after"
      BASH
      analysis = described_class.new(source)
      nodes = analysis.nodes
      freeze_nodes = nodes.select { |n| n.is_a?(Bash::Merge::FreezeNode) }
      expect(freeze_nodes.size).to eq(1)
    end

    it "aliases statements to nodes" do
      analysis = described_class.new("echo 'hello'")
      expect(analysis.statements).to eq(analysis.nodes)
    end
  end

  describe "#fallthrough_node?", :bash_grammar do
    it "returns true for NodeWrapper instances" do
      analysis = described_class.new("echo 'hello'")
      node = analysis.nodes.first
      expect(analysis.fallthrough_node?(node)).to be true
    end

    it "returns true for FreezeNode instances" do
      source = <<~BASH
        # bash-merge:freeze
        SECRET="value"
        # bash-merge:unfreeze
      BASH
      analysis = described_class.new(source)
      freeze_node = analysis.freeze_blocks.first
      expect(analysis.fallthrough_node?(freeze_node)).to be true
    end

    it "returns false for other types" do
      analysis = described_class.new("echo 'hello'")
      expect(analysis.fallthrough_node?("not a node")).to be false
      expect(analysis.fallthrough_node?(nil)).to be false
      expect(analysis.fallthrough_node?(123)).to be false
    end
  end

  describe ".find_parser_path" do
    it "returns a string path or nil" do
      path = described_class.find_parser_path
      expect(path.is_a?(String) || path.nil?).to be true
    end
  end

  describe "error handling" do
    it "handles missing grammar gracefully" do
      analysis = described_class.new("echo 'hello'", parser_path: "/nonexistent/path.so")
      expect(analysis.valid?).to be false
      expect(analysis.errors).not_to be_empty
    end
  end

  describe "integration with freeze blocks", :bash_grammar do
    it "excludes freeze block content from regular nodes" do
      source = <<~BASH
        echo "before"
        # bash-merge:freeze
        SECRET="value"
        # bash-merge:unfreeze
        echo "after"
      BASH
      analysis = described_class.new(source)

      # Regular nodes should not include the SECRET assignment
      regular_nodes = analysis.nodes.reject { |n| n.is_a?(Bash::Merge::FreezeNode) }
      var_nodes = regular_nodes.select { |n| n.respond_to?(:variable_assignment?) && n.variable_assignment? }
      expect(var_nodes.size).to eq(0)
    end

    it "sorts nodes by start line" do
      source = <<~BASH
        echo "first"
        # bash-merge:freeze
        SECRET="value"
        # bash-merge:unfreeze
        echo "last"
      BASH
      analysis = described_class.new(source)
      nodes = analysis.nodes

      lines = nodes.map(&:start_line).compact
      expect(lines).to eq(lines.sort)
    end
  end
end
