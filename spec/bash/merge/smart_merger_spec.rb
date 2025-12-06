# frozen_string_literal: true

RSpec.describe Bash::Merge::SmartMerger do
  # Note: Full integration testing requires tree-sitter-bash parser to be installed

  describe "#initialize" do
    context "when parser is not available" do
      it "raises TemplateParseError for template issues" do
        expect {
          described_class.new(
            "echo 'template'",
            "echo 'dest'",
            parser_path: "/nonexistent/parser.so",
          )
        }.to raise_error(Bash::Merge::TemplateParseError)
      end
    end
  end

  describe "configuration options" do
    it "accepts signature_match_preference" do
      expect(described_class.instance_method(:initialize).parameters.flatten).to include(:signature_match_preference)
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

    it "accepts parser_path" do
      expect(described_class.instance_method(:initialize).parameters.flatten).to include(:parser_path)
    end
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

    it "exposes signature_match_preference" do
      expect(described_class.instance_methods).to include(:signature_match_preference)
    end

    it "exposes add_template_only_nodes" do
      expect(described_class.instance_methods).to include(:add_template_only_nodes)
    end

    it "exposes freeze_token" do
      expect(described_class.instance_methods).to include(:freeze_token)
    end
  end
end
