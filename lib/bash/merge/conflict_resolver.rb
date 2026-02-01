# frozen_string_literal: true

module Bash
  module Merge
    # Resolves conflicts between template and destination Bash content
    # using structural signatures and configurable preferences.
    #
    # @example Basic usage
    #   resolver = ConflictResolver.new(template_analysis, dest_analysis)
    #   resolver.resolve(result)
    class ConflictResolver < ::Ast::Merge::ConflictResolverBase
      # Creates a new ConflictResolver
      #
      # @param template_analysis [FileAnalysis] Analyzed template file
      # @param dest_analysis [FileAnalysis] Analyzed destination file
      # @param preference [Symbol, Hash] Which version to prefer when
      #   nodes have matching signatures:
      #   - :destination (default) - Keep destination version (customizations)
      #   - :template - Use template version (updates)
      # @param add_template_only_nodes [Boolean] Whether to add nodes only in template
      # @param match_refiner [#call, nil] Optional match refiner for fuzzy matching
      # @param options [Hash] Additional options for forward compatibility
      # @param node_typing [Hash{Symbol,String => #call}, nil] Node typing configuration
      #   for per-node-type preferences
      def initialize(template_analysis, dest_analysis, preference: :destination, add_template_only_nodes: false, match_refiner: nil, node_typing: nil, **options)
        super(
          strategy: :batch,
          preference: preference,
          template_analysis: template_analysis,
          dest_analysis: dest_analysis,
          add_template_only_nodes: add_template_only_nodes,
          match_refiner: match_refiner,
          **options
        )
        @node_typing = node_typing
        @emitter = Emitter.new
      end

      # Resolve conflicts and populate the result
      #
      # @param result [MergeResult] Result object to populate
      def resolve(result)
        DebugLogger.time("ConflictResolver#resolve") do
          template_nodes = @template_analysis.nodes
          dest_nodes = @dest_analysis.nodes

          # Clear emitter for fresh merge
          @emitter.clear

          # Build signature maps
          template_by_sig = build_signature_map(template_nodes, @template_analysis)
          dest_by_sig = build_signature_map(dest_nodes, @dest_analysis)

          # Track which nodes have been processed
          processed_template_sigs = ::Set.new
          processed_dest_sigs = ::Set.new

          # Process nodes via emitter
          merge_nodes_to_emitter(
            template_nodes,
            dest_nodes,
            template_by_sig,
            dest_by_sig,
            processed_template_sigs,
            processed_dest_sigs,
          )

          # Transfer emitter output to result
          emitted_content = @emitter.to_s
          unless emitted_content.empty?
            emitted_content.lines.each do |line|
              result.add_line(line.chomp, decision: MergeResult::DECISION_MERGED, source: :merged)
            end
          end

          DebugLogger.debug("Conflict resolution complete", {
            template_nodes: template_nodes.size,
            dest_nodes: dest_nodes.size,
            result_lines: result.line_count,
          })
        end
      end

      private

      def merge_nodes_to_emitter(template_nodes, dest_nodes, template_by_sig, dest_by_sig, processed_template_sigs, processed_dest_sigs)
        # First pass: Process destination nodes and find matches
        dest_nodes.each do |dest_node|
          dest_sig = @dest_analysis.generate_signature(dest_node)

          # Freeze blocks from destination are always preserved
          if freeze_node?(dest_node)
            emit_freeze_block(dest_node)
            processed_dest_sigs << dest_sig if dest_sig
            next
          end

          if dest_sig && template_by_sig[dest_sig]
            # Found matching node in template
            template_info = template_by_sig[dest_sig].first
            template_node = template_info[:node]

            # Decide which to emit based on preference
            emit_preferred_node(template_node, dest_node)

            processed_dest_sigs << dest_sig
            processed_template_sigs << dest_sig
          else
            # Destination-only node - always keep
            emit_node(dest_node, @dest_analysis)
            processed_dest_sigs << dest_sig if dest_sig
          end
        end

        # Second pass: Add template-only nodes if configured
        return unless @add_template_only_nodes

        template_nodes.each do |template_node|
          template_sig = @template_analysis.generate_signature(template_node)

          # Skip if already processed (matched with dest)
          next if template_sig && processed_template_sigs.include?(template_sig)

          # Skip freeze blocks from template
          next if freeze_node?(template_node)

          # Add template-only node
          emit_node(template_node, @template_analysis)
          processed_template_sigs << template_sig if template_sig
        end
      end

      def emit_preferred_node(template_node, dest_node)
        if preference_for_pair(template_node, dest_node) == :destination
          emit_node(dest_node, @dest_analysis)
        else
          emit_node(template_node, @template_analysis)
        end
      end

      def preference_for_pair(template_node, dest_node)
        return @preference unless @preference.is_a?(Hash)

        typed_template = apply_node_typing(template_node)
        typed_dest = apply_node_typing(dest_node)

        if Ast::Merge::NodeTyping.typed_node?(typed_template)
          merge_type = Ast::Merge::NodeTyping.merge_type_for(typed_template)
          return @preference.fetch(merge_type) { default_preference } if merge_type
        end

        if Ast::Merge::NodeTyping.typed_node?(typed_dest)
          merge_type = Ast::Merge::NodeTyping.merge_type_for(typed_dest)
          return @preference.fetch(merge_type) { default_preference } if merge_type
        end

        default_preference
      end

      def apply_node_typing(node)
        return node unless @node_typing
        return node unless node

        Ast::Merge::NodeTyping.process(node, @node_typing)
      end

      # Emit a single node to the emitter
      # @param node [NodeWrapper] Node to emit
      # @param analysis [FileAnalysis] Analysis for accessing source
      def emit_node(node, analysis)
        return if freeze_node?(node)

        # Emit leading comments
        if node.start_line
          leading = analysis.comment_tracker.leading_comments_before(node.start_line)
          leading.each do |comment|
            @emitter.emit_tracked_comment(comment)
          end
        end

        # Emit the node content
        if node.start_line && node.end_line
          lines = []
          (node.start_line..node.end_line).each do |line_num|
            line = analysis.line_at(line_num)
            lines << line if line
          end
          @emitter.emit_raw_lines(lines)
        end
      end

      # Emit a freeze block
      # @param freeze_node [FreezeNode] Freeze block to emit
      def emit_freeze_block(freeze_node)
        @emitter.emit_raw_lines(freeze_node.lines)
      end
    end
  end
end
