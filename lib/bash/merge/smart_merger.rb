# frozen_string_literal: true

module Bash
  module Merge
    # Main entry point for intelligent Bash script merging.
    # SmartMerger orchestrates the merge process using FileAnalysis,
    # ConflictResolver, and MergeResult to merge two Bash scripts intelligently.
    #
    # @example Basic merge (destination customizations preserved)
    #   merger = SmartMerger.new(template_bash, dest_bash)
    #   result = merger.merge
    #   File.write("output.sh", result)
    #
    # @example Template updates win
    #   merger = SmartMerger.new(
    #     template_bash,
    #     dest_bash,
    #     preference: :template,
    #     add_template_only_nodes: true
    #   )
    #   result = merger.merge
    #
    # @example With custom signature generator
    #   sig_gen = ->(node) {
    #     if node.is_a?(NodeWrapper) && node.function_definition? && node.function_name == "main"
    #       [:special_main]
    #     else
    #       node # Fall through to default
    #     end
    #   }
    #   merger = SmartMerger.new(template, dest, signature_generator: sig_gen)
    #
    # @example With node_typing for per-node-type preferences
    #   merger = SmartMerger.new(template, dest,
    #     node_typing: { "function_definition" => ->(n) { NodeTyping.with_merge_type(n, :func) } },
    #     preference: { default: :destination, func: :template })
    class SmartMerger < ::Ast::Merge::SmartMergerBase
      # Creates a new SmartMerger for intelligent Bash script merging.
      #
      # @param template_content [String] Template Bash source code
      # @param dest_content [String] Destination Bash source code
      # @param signature_generator [Proc, nil] Custom signature generator
      # @param preference [Symbol, Hash] :destination, :template, or per-type Hash
      # @param add_template_only_nodes [Boolean] Whether to add nodes only in template
      # @param freeze_token [String] Token for freeze block markers
      # @param match_refiner [#call, nil] Match refiner for fuzzy matching
      # @param regions [Array<Hash>, nil] Region configurations for nested merging
      # @param region_placeholder [String, nil] Custom placeholder for regions
      # @param node_typing [Hash{Symbol,String => #call}, nil] Node typing configuration
      #
      # @note To specify a custom parser path, use the TREE_SITTER_BASH_PATH environment
      #   variable. This is handled by tree_haver's GrammarFinder.
      # @param options [Hash] Additional options for forward compatibility
      #
      # @raise [TemplateParseError] If template has syntax errors
      # @raise [DestinationParseError] If destination has syntax errors
      def initialize(
        template_content,
        dest_content,
        signature_generator: nil,
        preference: :destination,
        add_template_only_nodes: false,
        freeze_token: nil,
        match_refiner: nil,
        regions: nil,
        region_placeholder: nil,
        node_typing: nil,
        **options
      )
        super(
          template_content,
          dest_content,
          signature_generator: signature_generator,
          preference: preference,
          add_template_only_nodes: add_template_only_nodes,
          freeze_token: freeze_token,
          match_refiner: match_refiner,
          regions: regions,
          region_placeholder: region_placeholder,
          node_typing: node_typing,
          **options
        )
      end

      # Perform the merge and return the result as a Bash string.
      #
      # @return [String] Merged Bash content
      def merge
        merge_result.to_bash
      end

      # Perform the merge and return detailed results including debug info.
      #
      # @return [Hash] Hash containing :content, :statistics, :decisions
      def merge_with_debug
        content = merge

        {
          content: content,
          statistics: @result.statistics,
          decisions: @result.decision_summary,
          template_analysis: {
            valid: @template_analysis.valid?,
            nodes: @template_analysis.nodes.size,
            freeze_blocks: @template_analysis.freeze_blocks.size,
          },
          dest_analysis: {
            valid: @dest_analysis.valid?,
            nodes: @dest_analysis.nodes.size,
            freeze_blocks: @dest_analysis.freeze_blocks.size,
          },
        }
      end

      # Check if both files were parsed successfully.
      #
      # @return [Boolean]
      def valid?
        @template_analysis.valid? && @dest_analysis.valid?
      end

      # Get any parse errors from template or destination.
      #
      # @return [Array] Array of errors
      def errors
        errors = []
        errors.concat(@template_analysis.errors.map { |e| {source: :template, error: e} })
        errors.concat(@dest_analysis.errors.map { |e| {source: :destination, error: e} })
        errors
      end

      protected

      # @return [Class] The analysis class for Bash files
      def analysis_class
        FileAnalysis
      end

      # @return [String] The default freeze token
      def default_freeze_token
        "bash-merge"
      end

      # @return [Class] The resolver class for Bash files
      def resolver_class
        ConflictResolver
      end

      # @return [Class] The result class for Bash files
      def result_class
        MergeResult
      end

      # @return [Class] The template parse error class for Bash
      def template_parse_error_class
        TemplateParseError
      end

      # @return [Class] The destination parse error class for Bash
      def destination_parse_error_class
        DestinationParseError
      end

      # Perform the Bash-specific merge
      #
      # @return [MergeResult] The merge result
      def perform_merge
        @resolver.resolve(@result)
        @result
      end

      # Build the resolver with Bash-specific options
      def build_resolver
        ConflictResolver.new(
          @template_analysis,
          @dest_analysis,
          preference: @preference,
          add_template_only_nodes: @add_template_only_nodes,
          node_typing: @node_typing,
        )
      end

      # Build the result (no-arg constructor for Bash)
      def build_result
        MergeResult.new
      end
    end
  end
end
