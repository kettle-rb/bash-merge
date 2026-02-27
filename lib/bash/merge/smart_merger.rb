# frozen_string_literal: true

module Bash
  module Merge
    # Main entry point for intelligent Bash script merging.
    # SmartMerger orchestrates the merge process using FileAnalysis
    # and MergeResult to merge two Bash scripts intelligently.
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

      # No separate resolver — SmartMerger handles merge logic directly
      # (following prism-merge's paradigm of section-based inline merging)
      # @return [Class, nil]
      def resolver_class
        nil
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

      # Perform section-based merge directly (no ConflictResolver delegation).
      #
      # This follows prism-merge's paradigm: the SmartMerger itself owns the
      # merge algorithm. Signature maps store ALL occurrences of each signature,
      # and nodes are matched positionally (1:1 in order) when duplicates exist.
      #
      # Algorithm:
      #   1. Build signature → [node_info, ...] maps for both files
      #   2. Walk dest nodes in order; for each, find the next unconsumed
      #      template node with the same signature (sequential matching)
      #   3. Emit the preferred version (or dest-only if no match)
      #   4. Walk remaining unconsumed template nodes; emit as template-only
      #      if add_template_only_nodes is set
      #
      # @return [MergeResult] The merge result
      def perform_merge
        template_nodes = @template_analysis.nodes
        dest_nodes = @dest_analysis.nodes

        emitter = Emitter.new

        # Build signature maps: sig → [{node:, index:}, ...]
        template_by_sig = build_indexed_signature_map(template_nodes, @template_analysis)

        # Track which individual template node indices have been consumed.
        consumed_template_indices = ::Set.new

        # Per-signature cursor so duplicate signatures match 1:1 in order.
        sig_cursor = Hash.new(0)

        # Phase 1 — Walk destination nodes in order, preserving their positions.
        dest_nodes.each do |dest_node|
          dest_sig = @dest_analysis.generate_signature(dest_node)

          # Freeze blocks from destination are always preserved verbatim.
          if dest_node.is_a?(FreezeNode) || (dest_node.respond_to?(:is_a?) && dest_node.is_a?(Ast::Merge::Freezable))
            emitter.emit_raw_lines(dest_node.respond_to?(:lines) ? dest_node.lines : [])
            next
          end

          if dest_sig && template_by_sig.key?(dest_sig)
            # Find the next unconsumed template node with this signature.
            candidates = template_by_sig[dest_sig]
            cursor = sig_cursor[dest_sig]
            template_info = nil

            while cursor < candidates.size
              candidate = candidates[cursor]
              unless consumed_template_indices.include?(candidate[:index])
                template_info = candidate
                break
              end
              cursor += 1
            end

            if template_info
              template_node = template_info[:node]
              consumed_template_indices << template_info[:index]
              sig_cursor[dest_sig] = cursor + 1

              # Emit based on preference
              emit_preferred(emitter, template_node, dest_node)
            else
              # All template copies of this signature consumed — keep dest copy
              emit_node_to(emitter, dest_node, @dest_analysis)
            end
          else
            # Destination-only node — always keep
            emit_node_to(emitter, dest_node, @dest_analysis)
          end
        end

        # Phase 2 — Emit template-only nodes (unconsumed template nodes)
        if @add_template_only_nodes
          template_nodes.each_with_index do |template_node, idx|
            next if consumed_template_indices.include?(idx)
            next if template_node.is_a?(FreezeNode) || (template_node.respond_to?(:is_a?) && template_node.is_a?(Ast::Merge::Freezable))

            emit_node_to(emitter, template_node, @template_analysis)
          end
        end

        # Transfer emitter output to result
        emitted_content = emitter.to_s
        unless emitted_content.empty?
          emitted_content.lines.each do |line|
            @result.add_line(line.chomp, decision: MergeResult::DECISION_MERGED, source: :merged)
          end
        end

        @result
      end

      # Build the result (no-arg constructor for Bash)
      def build_result
        MergeResult.new
      end

      private

      # Build a signature map that preserves ALL occurrences per signature,
      # keyed by index for sequential consumption.
      #
      # @param nodes [Array<NodeWrapper>] Parsed nodes
      # @param analysis [FileAnalysis] Analysis for signature generation
      # @return [Hash{Array => Array<Hash>}] sig → [{node:, index:}, ...]
      def build_indexed_signature_map(nodes, analysis)
        map = Hash.new { |h, k| h[k] = [] }
        nodes.each_with_index do |node, idx|
          sig = analysis.generate_signature(node)
          map[sig] << {node: node, index: idx} if sig
        end
        map
      end

      # Emit the preferred version of a matched node pair.
      def emit_preferred(emitter, template_node, dest_node)
        pref = preference_for_pair(template_node, dest_node)
        if pref == :destination
          emit_node_to(emitter, dest_node, @dest_analysis)
        else
          emit_node_to(emitter, template_node, @template_analysis)
        end
      end

      # Determine preference for a matched pair, respecting per-type overrides.
      def preference_for_pair(template_node, dest_node)
        return @preference unless @preference.is_a?(Hash)

        typed_template = @node_typing ? ::Ast::Merge::NodeTyping.process(template_node, @node_typing) : template_node
        typed_dest = @node_typing ? ::Ast::Merge::NodeTyping.process(dest_node, @node_typing) : dest_node

        if ::Ast::Merge::NodeTyping.typed_node?(typed_template)
          merge_type = ::Ast::Merge::NodeTyping.merge_type_for(typed_template)
          return @preference.fetch(merge_type) { @preference.fetch(:default, :destination) } if merge_type
        end

        if ::Ast::Merge::NodeTyping.typed_node?(typed_dest)
          merge_type = ::Ast::Merge::NodeTyping.merge_type_for(typed_dest)
          return @preference.fetch(merge_type) { @preference.fetch(:default, :destination) } if merge_type
        end

        @preference.fetch(:default, :destination)
      end

      # Emit a single node (with its leading comments) to an emitter.
      def emit_node_to(emitter, node, analysis)
        # Emit leading comments
        if node.start_line
          leading = analysis.comment_tracker.leading_comments_before(node.start_line)
          leading.each do |comment|
            emitter.emit_tracked_comment(comment)
          end
        end

        # Emit the node content
        if node.start_line && node.end_line
          lines = (node.start_line..node.end_line).filter_map { |ln| analysis.line_at(ln) }
          emitter.emit_raw_lines(lines)
        end
      end
    end
  end
end
