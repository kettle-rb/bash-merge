# frozen_string_literal: true

RSpec.describe Bash::Merge::SmartMerger do
  # Note: Full integration testing requires tree-sitter-bash parser to be installed

  describe "#initialize" do
    context "when parser path is invalid via ENV" do
      before do
        stub_env("TREE_SITTER_BASH_PATH" => "/nonexistent/parser.so")
      end

      it "raises TreeHaver::NotAvailable for invalid parser path" do
        # When TREE_SITTER_BASH_PATH is set to an invalid path, GrammarFinder.find_library_path
        # raises TreeHaver::NotAvailable BEFORE parse_bash runs.
        # This exception (which extends Exception, not StandardError) propagates unchanged.
        expect {
          described_class.new(
            "echo 'template'",
            "echo 'dest'",
          )
        }.to raise_error(TreeHaver::NotAvailable, /file does not exist/)
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

  describe "with real parser", :tree_sitter_bash do
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
      BASH
    end

    describe "#merge" do
      it "returns merged content as a string" do
        merger = described_class.new(template_content, dest_content)
        result = merger.merge

        expect(result).to be_a(String)
        expect(result).not_to be_empty
      end

      it "preserves destination values by default" do
        merger = described_class.new(template_content, dest_content)
        result = merger.merge

        expect(result).to include("dest_value")
      end

      it "uses template values when preference is :template" do
        merger = described_class.new(
          template_content,
          dest_content,
          preference: :template,
        )
        result = merger.merge

        expect(result).to include("template_value")
      end
    end

    describe "#merge_with_debug" do
      it "returns a hash with content" do
        merger = described_class.new(template_content, dest_content)
        debug_result = merger.merge_with_debug

        expect(debug_result).to be_a(Hash)
        expect(debug_result[:content]).to be_a(String)
      end

      it "includes statistics" do
        merger = described_class.new(template_content, dest_content)
        debug_result = merger.merge_with_debug

        expect(debug_result[:statistics]).to be_a(Hash)
      end

      it "includes decisions" do
        merger = described_class.new(template_content, dest_content)
        debug_result = merger.merge_with_debug

        expect(debug_result[:decisions]).to be_a(Hash)
      end

      it "includes template_analysis info" do
        merger = described_class.new(template_content, dest_content)
        debug_result = merger.merge_with_debug

        expect(debug_result[:template_analysis]).to be_a(Hash)
        expect(debug_result[:template_analysis][:valid]).to be true
      end

      it "includes dest_analysis info" do
        merger = described_class.new(template_content, dest_content)
        debug_result = merger.merge_with_debug

        expect(debug_result[:dest_analysis]).to be_a(Hash)
        expect(debug_result[:dest_analysis][:valid]).to be true
      end
    end

    describe "#valid?" do
      it "returns true when both files parse successfully" do
        merger = described_class.new(template_content, dest_content)
        expect(merger.valid?).to be true
      end
    end

    describe "#errors" do
      it "returns empty array when no errors" do
        merger = described_class.new(template_content, dest_content)
        expect(merger.errors).to be_an(Array)
        expect(merger.errors).to be_empty
      end
    end

    describe "with add_template_only_nodes" do
      let(:template_with_extra) do
        <<~BASH
          #!/bin/bash
          TEMPLATE_ONLY="only_in_template"
          SHARED="shared_value"
        BASH
      end

      let(:simple_dest) do
        <<~BASH
          #!/bin/bash
          SHARED="shared_value"
        BASH
      end

      it "adds template-only nodes when enabled" do
        merger = described_class.new(
          template_with_extra,
          simple_dest,
          add_template_only_nodes: true,
        )
        result = merger.merge

        expect(result).to include("TEMPLATE_ONLY")
      end

      it "does not add template-only nodes when disabled" do
        merger = described_class.new(
          template_with_extra,
          simple_dest,
          add_template_only_nodes: false,
        )
        result = merger.merge

        expect(result).not_to include("TEMPLATE_ONLY")
      end
    end

    describe "with freeze blocks" do
      let(:dest_with_freeze) do
        <<~BASH
          #!/bin/bash
          # bash-merge:freeze
          SECRET="frozen_secret"
          # bash-merge:unfreeze
          PUBLIC="public_value"
        BASH
      end

      it "preserves freeze blocks even with template preference" do
        merger = described_class.new(
          template_content,
          dest_with_freeze,
          preference: :template,
        )
        result = merger.merge

        expect(result).to include("bash-merge:freeze")
        expect(result).to include("SECRET")
      end
    end

    describe "with custom freeze token" do
      let(:dest_with_custom_freeze) do
        <<~BASH
          #!/bin/bash
          # custom-token:freeze
          SECRET="custom_frozen"
          # custom-token:unfreeze
          PUBLIC="public"
        BASH
      end

      it "respects custom freeze token" do
        merger = described_class.new(
          template_content,
          dest_with_custom_freeze,
          freeze_token: "custom-token",
        )
        result = merger.merge

        expect(result).to include("custom-token:freeze")
        expect(result).to include("SECRET")
      end
    end

    describe "with functions" do
      let(:template_with_func) do
        <<~BASH
          #!/bin/bash
          setup() {
            echo "template setup"
          }

          main() {
            echo "template main"
          }
        BASH
      end

      let(:dest_with_func) do
        <<~BASH
          #!/bin/bash
          setup() {
            echo "dest setup"
          }

          cleanup() {
            echo "dest cleanup"
          }
        BASH
      end

      it "merges matching functions" do
        merger = described_class.new(
          template_with_func,
          dest_with_func,
          preference: :destination,
          add_template_only_nodes: true,
        )
        result = merger.merge

        expect(result).to include("setup")
        expect(result).to include("dest setup")
        expect(result).to include("cleanup")
        expect(result).to include("main")
      end
    end

    describe "with complex scripts" do
      let(:complex_template) do
        <<~BASH
          #!/bin/bash
          set -e

          # Configuration
          APP_NAME="myapp"
          VERSION="1.0.0"

          # Functions
          log() {
            echo "[LOG] $1"
          }

          main() {
            log "Starting $APP_NAME v$VERSION"
          }

          main "$@"
        BASH
      end

      let(:complex_dest) do
        <<~BASH
          #!/bin/bash
          set -e

          # Configuration
          APP_NAME="myapp-custom"
          VERSION="1.0.0"
          DEBUG=true

          # Functions
          log() {
            echo "[CUSTOM LOG] $1"
          }

          # Custom function
          debug() {
            if [ "$DEBUG" = true ]; then
              echo "[DEBUG] $1"
            fi
          }

          main() {
            log "Starting $APP_NAME v$VERSION"
            debug "Debug mode enabled"
          }

          main "$@"
        BASH
      end

      it "handles complex scripts with multiple constructs" do
        merger = described_class.new(
          complex_template,
          complex_dest,
          preference: :destination,
          add_template_only_nodes: false,
        )
        result = merger.merge

        expect(result).to include("myapp-custom")
        expect(result).to include("debug")
        expect(result).to include("CUSTOM LOG")
      end
    end
  end
end
