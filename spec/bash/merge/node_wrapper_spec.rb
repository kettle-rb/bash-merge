# frozen_string_literal: true

RSpec.describe Bash::Merge::NodeWrapper do
  # NodeWrapper requires a tree-sitter node, which requires parser availability
  # These tests use the actual parser when available and skip gracefully if not

  describe "class structure" do
    it "is a class" do
      expect(described_class).to be_a(Class)
    end
  end

  describe "when tree-sitter parser is available" do
    let(:bash_content) { "echo 'hello'" }

    it "creates wrapper instances from FileAnalysis" do
      analysis = Bash::Merge::FileAnalysis.new(bash_content)
      skip "tree-sitter parser not available: #{analysis.errors.first}" unless analysis.valid?

      nodes = analysis.nodes
      expect(nodes).to be_an(Array)
      expect(nodes).to all(be_a(described_class).or(be_a(Bash::Merge::FreezeNode)))
    end
  end

  describe "#freeze_node?" do
    it "returns false for NodeWrapper instances" do
      source = "echo 'hello'"
      analysis = Bash::Merge::FileAnalysis.new(source)
      skip "tree-sitter parser not available: #{analysis.errors.first}" unless analysis.valid?

      node = analysis.nodes.first
      expect(node).to be_a(described_class)
      expect(node.freeze_node?).to be false
    end
  end

  describe "node type checks" do
    describe "#function_definition?" do
      it "is defined" do
        expect(described_class.instance_methods).to include(:function_definition?)
      end
    end

    describe "#variable_assignment?" do
      it "is defined" do
        expect(described_class.instance_methods).to include(:variable_assignment?)
      end
    end

    describe "#command?" do
      it "is defined" do
        expect(described_class.instance_methods).to include(:command?)
      end
    end

    describe "#if_statement?" do
      it "is defined" do
        expect(described_class.instance_methods).to include(:if_statement?)
      end
    end

    describe "#for_statement?" do
      it "is defined" do
        expect(described_class.instance_methods).to include(:for_statement?)
      end
    end
  end

  describe "#signature" do
    it "is defined" do
      expect(described_class.instance_methods).to include(:signature)
    end
  end

  describe "#content" do
    it "is defined" do
      expect(described_class.instance_methods).to include(:content)
    end
  end

  describe "#children" do
    it "is defined" do
      expect(described_class.instance_methods).to include(:children)
    end
  end
end
