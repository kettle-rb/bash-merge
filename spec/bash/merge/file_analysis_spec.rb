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
end
