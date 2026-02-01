# frozen_string_literal: true

require "spec_helper"
require "ast/merge/rspec/shared_examples"

RSpec.describe Bash::Merge::ConflictResolver do
  # Note: Full testing requires tree-sitter-bash parser
  it_behaves_like "Ast::Merge::ConflictResolverBase" do
    let(:conflict_resolver_class) { described_class }
    let(:strategy) { :batch }
    let(:build_conflict_resolver) do
      ->(preference:, template_analysis:, dest_analysis:, **opts) {
        described_class.new(
          template_analysis,
          dest_analysis,
          preference: preference,
          add_template_only_nodes: opts.fetch(:add_template_only_nodes, false),
        )
      }
    end
    let(:build_mock_analysis) do
      -> { double("MockAnalysis") }
    end
  end

  it_behaves_like "Ast::Merge::ConflictResolverBase batch strategy" do
    let(:conflict_resolver_class) { described_class }
    let(:build_conflict_resolver) do
      ->(preference:, template_analysis:, dest_analysis:, **opts) {
        described_class.new(
          template_analysis,
          dest_analysis,
          preference: preference,
          add_template_only_nodes: opts.fetch(:add_template_only_nodes, false),
        )
      }
    end
    let(:build_mock_analysis) do
      -> { double("MockAnalysis") }
    end
  end

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

    it "accepts match_refiner option" do
      refiner = ->(_t, _d) { [] }
      resolver = described_class.new(
        template_analysis,
        dest_analysis,
        match_refiner: refiner,
      )

      expect(resolver).to be_a(described_class)
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

  describe "with real parser", :bash_grammar do
    let(:template_content) do
      <<~BASH
        #!/bin/bash
        MY_VAR="template_value"
        echo "template"
      BASH
    end

    let(:dest_content) do
      <<~BASH
        #!/bin/bash
        MY_VAR="dest_value"
        echo "dest"
        EXTRA_VAR="only_in_dest"
      BASH
    end

    let(:template_analysis) { Bash::Merge::FileAnalysis.new(template_content) }
    let(:dest_analysis) { Bash::Merge::FileAnalysis.new(dest_content) }

    describe "with destination preference" do
      it "preserves destination values for matching nodes" do
        resolver = described_class.new(
          template_analysis,
          dest_analysis,
          preference: :destination,
        )
        result = Bash::Merge::MergeResult.new

        resolver.resolve(result)

        content = result.to_bash
        expect(content).to include("dest_value")
      end

      it "preserves destination-only nodes" do
        resolver = described_class.new(
          template_analysis,
          dest_analysis,
          preference: :destination,
        )
        result = Bash::Merge::MergeResult.new

        resolver.resolve(result)

        content = result.to_bash
        expect(content).to include("EXTRA_VAR")
      end
    end

    describe "with template preference" do
      it "uses template values for matching nodes" do
        resolver = described_class.new(
          template_analysis,
          dest_analysis,
          preference: :template,
        )
        result = Bash::Merge::MergeResult.new

        resolver.resolve(result)

        content = result.to_bash
        expect(content).to include("template_value")
      end
    end

    describe "with per-node-type preference" do
      it "uses template values for typed nodes and destination for others" do
        node_typing = {
          "NodeWrapper" => lambda { |node|
            if node.variable_assignment? && node.variable_name == "MY_VAR"
              Ast::Merge::NodeTyping.with_merge_type(node, :tracked_var)
            else
              node
            end
          },
        }

        resolver = described_class.new(
          template_analysis,
          dest_analysis,
          preference: {default: :destination, tracked_var: :template},
          node_typing: node_typing,
        )
        result = Bash::Merge::MergeResult.new

        resolver.resolve(result)

        content = result.to_bash
        expect(content).to include('MY_VAR="template_value"')
        expect(content).to include('EXTRA_VAR="only_in_dest"')
      end
    end

    describe "with add_template_only_nodes" do
      let(:template_with_extra) do
        <<~BASH
          #!/bin/bash
          MY_VAR="value"
          TEMPLATE_ONLY="only_in_template"
        BASH
      end

      let(:simple_dest) do
        <<~BASH
          #!/bin/bash
          MY_VAR="value"
        BASH
      end

      it "adds template-only nodes when enabled" do
        template = Bash::Merge::FileAnalysis.new(template_with_extra)
        dest = Bash::Merge::FileAnalysis.new(simple_dest)

        resolver = described_class.new(
          template,
          dest,
          preference: :destination,
          add_template_only_nodes: true,
        )
        result = Bash::Merge::MergeResult.new

        resolver.resolve(result)

        content = result.to_bash
        expect(content).to include("TEMPLATE_ONLY")
      end

      it "does not add template-only nodes when disabled" do
        template = Bash::Merge::FileAnalysis.new(template_with_extra)
        dest = Bash::Merge::FileAnalysis.new(simple_dest)

        resolver = described_class.new(
          template,
          dest,
          preference: :destination,
          add_template_only_nodes: false,
        )
        result = Bash::Merge::MergeResult.new

        resolver.resolve(result)

        content = result.to_bash
        expect(content).not_to include("TEMPLATE_ONLY")
      end
    end

    describe "with freeze blocks" do
      let(:dest_with_freeze) do
        <<~BASH
          #!/bin/bash
          # bash-merge:freeze
          SECRET="frozen_value"
          # bash-merge:unfreeze
          PUBLIC="public_value"
        BASH
      end

      it "preserves freeze blocks from destination" do
        template = Bash::Merge::FileAnalysis.new(template_content)
        dest = Bash::Merge::FileAnalysis.new(dest_with_freeze)

        resolver = described_class.new(
          template,
          dest,
          preference: :template,
        )
        result = Bash::Merge::MergeResult.new

        resolver.resolve(result)

        content = result.to_bash
        expect(content).to include("bash-merge:freeze")
        expect(content).to include("SECRET")
      end
    end

    describe "with functions" do
      let(:template_with_func) do
        <<~BASH
          #!/bin/bash
          my_function() {
            echo "template version"
          }
        BASH
      end

      let(:dest_with_func) do
        <<~BASH
          #!/bin/bash
          my_function() {
            echo "dest version"
          }
        BASH
      end

      it "matches functions by name" do
        template = Bash::Merge::FileAnalysis.new(template_with_func)
        dest = Bash::Merge::FileAnalysis.new(dest_with_func)

        resolver = described_class.new(
          template,
          dest,
          preference: :destination,
        )
        result = Bash::Merge::MergeResult.new

        resolver.resolve(result)

        content = result.to_bash
        expect(content).to include("my_function")
        expect(content).to include("dest version")
      end
    end

    describe "with mixed content" do
      let(:mixed_template) do
        <<~BASH
          #!/bin/bash
          VAR1="value1"

          my_func() {
            echo "in function"
          }

          if [ -n "$VAR1" ]; then
            echo "set"
          fi
        BASH
      end

      let(:mixed_dest) do
        <<~BASH
          #!/bin/bash
          VAR1="dest_value1"
          VAR2="dest_only"

          my_func() {
            echo "dest function"
          }
        BASH
      end

      it "handles mixed content types" do
        template = Bash::Merge::FileAnalysis.new(mixed_template)
        dest = Bash::Merge::FileAnalysis.new(mixed_dest)

        resolver = described_class.new(
          template,
          dest,
          preference: :destination,
          add_template_only_nodes: true,
        )
        result = Bash::Merge::MergeResult.new

        resolver.resolve(result)

        content = result.to_bash
        expect(content).to include("VAR1")
        expect(content).to include("VAR2")
        expect(content).to include("my_func")
      end
    end
  end
end
