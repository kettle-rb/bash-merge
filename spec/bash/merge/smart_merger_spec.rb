# frozen_string_literal: true

RSpec.describe Bash::Merge::SmartMerger do
  # Note: Full integration testing requires tree-sitter-bash parser to be installed

  describe "#initialize" do
    context "when parser is not available" do
      it "raises TemplateParseError for template issues" do
        stub_env("TREE_SITTER_BASH_PATH" => "/nonexistent/parser.so") do
          expect {
            described_class.new(
              "echo 'template'",
              "echo 'dest'"
            )
          }.to raise_error(Bash::Merge::TemplateParseError)
        end
      end
    end
  end

  describe "configuration options" do
    it "accepts preference" do
      expect(described_class.instance_method(:initialize).parameters.flatten).to include(:preference)
    end

    it "accepts add_template_only_nodes" do
      expect(described_class.instance_method(:initialize).parameters.flatten).to include(:add_template_only_nodes)
    end

    it "accepts freeze_token" do
      expect(described_class.instance_method(:initialize).parameters.flatten).to include(:freeze_token)
    end

    it "accepts signature_generator" do
      expect(described_class.instance_method(:initialize).parameters.flatten).to include(:signature_generator)
    end

    it "accepts match_refiner" do
      expect(described_class.instance_method(:initialize).parameters.flatten).to include(:match_refiner)
    end

    it "accepts regions" do
      expect(described_class.instance_method(:initialize).parameters.flatten).to include(:regions)
    end

    it "accepts node_typing" do
      expect(described_class.instance_method(:initialize).parameters.flatten).to include(:node_typing)
    end

    # Note: parser_path was removed - use TREE_SITTER_BASH_PATH environment variable instead
  end

  describe "instance methods" do
    it "defines #merge" do
      expect(described_class.instance_methods).to include(:merge)
    end

    it "defines #merge_with_debug" do
      expect(described_class.instance_methods).to include(:merge_with_debug)
    end

    it "defines #valid?" do
      expect(described_class.instance_methods).to include(:valid?)
    end

    it "defines #errors" do
      expect(described_class.instance_methods).to include(:errors)
    end
  end

  describe "accessors" do
    it "exposes template_analysis" do
      expect(described_class.instance_methods).to include(:template_analysis)
    end

    it "exposes dest_analysis" do
      expect(described_class.instance_methods).to include(:dest_analysis)
    end

    it "exposes resolver" do
      expect(described_class.instance_methods).to include(:resolver)
    end

    it "exposes result" do
      expect(described_class.instance_methods).to include(:result)
    end

    it "exposes preference" do
      expect(described_class.instance_methods).to include(:preference)
    end

    it "exposes add_template_only_nodes" do
      expect(described_class.instance_methods).to include(:add_template_only_nodes)
    end

    it "exposes freeze_token" do
      expect(described_class.instance_methods).to include(:freeze_token)
    end
  end
end
