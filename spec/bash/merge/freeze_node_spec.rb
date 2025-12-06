# frozen_string_literal: true

require "ast/merge/rspec/shared_examples"

RSpec.describe Bash::Merge::FreezeNode do
  # Use shared examples to validate base FreezeNodeBase integration
  it_behaves_like "Ast::Merge::FreezeNodeBase" do
    let(:freeze_node_class) { described_class }
    let(:default_pattern_type) { :hash_comment }
    let(:build_freeze_node) do
      ->(start_line:, end_line:, **opts) {
        # Build enough lines to cover the requested range
        lines = opts.delete(:lines) || begin
          result = []
          (1..end_line).each do |i|
            result << if i == start_line
              "# bash-merge:freeze"
            elsif i == end_line
              "# bash-merge:unfreeze"
            else
              "VAR_#{i}=\"value_#{i}\""
            end
          end
          result
        end
        freeze_node_class.new(
          start_line: start_line,
          end_line: end_line,
          lines: lines,
          pattern_type: opts[:pattern_type] || :hash_comment,
          **opts.except(:pattern_type),
        )
      }
    end
  end

  # Bash-specific tests
  let(:lines) do
    [
      "#!/bin/bash",
      "# bash-merge:freeze",
      'SECRET="my-secret"',
      "# bash-merge:unfreeze",
      'echo "hello"',
    ]
  end

  describe "#initialize" do
    it "creates a freeze node from start and end lines" do
      freeze_node = described_class.new(
        start_line: 2,
        end_line: 4,
        lines: lines,
      )

      expect(freeze_node.start_line).to eq(2)
      expect(freeze_node.end_line).to eq(4)
    end

    it "extracts lines within the freeze block" do
      freeze_node = described_class.new(
        start_line: 2,
        end_line: 4,
        lines: lines,
      )

      expect(freeze_node.lines.size).to eq(3)
      expect(freeze_node.lines).to include('SECRET="my-secret"')
    end

    it "raises error for invalid structure" do
      expect {
        described_class.new(
          start_line: 5,
          end_line: 2,
          lines: lines,
        )
      }.to raise_error(Bash::Merge::FreezeNode::InvalidStructureError)
    end
  end

  describe "#signature" do
    it "generates consistent signatures for same content" do
      node1 = described_class.new(start_line: 2, end_line: 4, lines: lines)
      node2 = described_class.new(start_line: 2, end_line: 4, lines: lines)

      expect(node1.signature).to eq(node2.signature)
    end
  end

  describe "#location" do
    it "returns a Location struct" do
      freeze_node = described_class.new(
        start_line: 2,
        end_line: 4,
        lines: lines,
      )

      expect(freeze_node.location).to respond_to(:start_line)
      expect(freeze_node.location).to respond_to(:end_line)
      expect(freeze_node.location).to respond_to(:cover?)
    end

    it "covers lines within the block" do
      freeze_node = described_class.new(
        start_line: 2,
        end_line: 4,
        lines: lines,
      )

      expect(freeze_node.location.cover?(2)).to be(true)
      expect(freeze_node.location.cover?(3)).to be(true)
      expect(freeze_node.location.cover?(4)).to be(true)
      expect(freeze_node.location.cover?(1)).to be(false)
      expect(freeze_node.location.cover?(5)).to be(false)
    end
  end

  describe "bash-specific methods" do
    let(:freeze_node) do
      described_class.new(
        start_line: 2,
        end_line: 4,
        lines: lines,
      )
    end

    it "#function_definition? returns false" do
      expect(freeze_node.function_definition?).to be(false)
    end

    it "#variable_assignment? returns false" do
      expect(freeze_node.variable_assignment?).to be(false)
    end

    it "#command? returns false" do
      expect(freeze_node.command?).to be(false)
    end

    it "#inspect returns a useful string" do
      result = freeze_node.inspect
      expect(result).to include("FreezeNode")
      expect(result).to include("2..4")
    end
  end

  describe "validation edge cases" do
    it "raises error for empty freeze block" do
      empty_lines = [nil, nil, nil]
      expect {
        described_class.new(
          start_line: 1,
          end_line: 3,
          lines: empty_lines,
        )
      }.to raise_error(Bash::Merge::FreezeNode::InvalidStructureError, /empty/i)
    end

    it "raises error for reversed line order" do
      expect {
        described_class.new(
          start_line: 5,
          end_line: 1,
          lines: lines,
        )
      }.to raise_error(Bash::Merge::FreezeNode::InvalidStructureError)
    end
  end
end
