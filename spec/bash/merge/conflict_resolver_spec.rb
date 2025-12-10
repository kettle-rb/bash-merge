# frozen_string_literal: true

RSpec.describe Bash::Merge::ConflictResolver do
  # Note: Full testing requires tree-sitter-bash parser

  describe "#initialize" do
    let(:template_analysis) { instance_double(Bash::Merge::FileAnalysis, nodes: [], generate_signature: nil) }
    let(:dest_analysis) { instance_double(Bash::Merge::FileAnalysis, nodes: [], generate_signature: nil) }

    it "accepts template and destination analyses" do
      resolver = described_class.new(template_analysis, dest_analysis)

      expect(resolver.template_analysis).to eq(template_analysis)
      expect(resolver.dest_analysis).to eq(dest_analysis)
    end

    it "accepts preference option" do
      resolver = described_class.new(
        template_analysis,
        dest_analysis,
        preference: :template,
      )

      expect(resolver.preference).to eq(:template)
    end

    it "defaults to destination preference" do
      resolver = described_class.new(template_analysis, dest_analysis)

      expect(resolver.preference).to eq(:destination)
    end

    it "accepts add_template_only_nodes option" do
      resolver = described_class.new(
        template_analysis,
        dest_analysis,
        add_template_only_nodes: true,
      )

      expect(resolver.add_template_only_nodes).to be(true)
    end

    it "defaults add_template_only_nodes to false" do
      resolver = described_class.new(template_analysis, dest_analysis)

      expect(resolver.add_template_only_nodes).to be(false)
    end
  end

  describe "#resolve" do
    let(:template_analysis) do
      instance_double(
        Bash::Merge::FileAnalysis,
        nodes: [],
        generate_signature: nil,
        comment_tracker: instance_double(Bash::Merge::CommentTracker, leading_comments_before: []),
        line_at: nil,
      )
    end
    let(:dest_analysis) do
      instance_double(
        Bash::Merge::FileAnalysis,
        nodes: [],
        generate_signature: nil,
        comment_tracker: instance_double(Bash::Merge::CommentTracker, leading_comments_before: []),
        line_at: nil,
      )
    end

    it "populates the result object" do
      resolver = described_class.new(template_analysis, dest_analysis)
      result = Bash::Merge::MergeResult.new

      expect { resolver.resolve(result) }.not_to raise_error
    end
  end
end
