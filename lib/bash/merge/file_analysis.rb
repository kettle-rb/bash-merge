# frozen_string_literal: true

module Bash
  module Merge
    # Analyzes Bash script structure, extracting nodes, comments, and freeze blocks.
    # This is the main analysis class that prepares Bash content for merging.
    #
    # @example Basic usage
    #   analysis = FileAnalysis.new(bash_source)
    #   analysis.valid? # => true
    #   analysis.nodes # => [NodeWrapper, FreezeNodeBase, ...]
    #   analysis.freeze_blocks # => [FreezeNodeBase, ...]
    class FileAnalysis
      include Ast::Merge::FileAnalyzable

      # Default freeze token for identifying freeze blocks
      DEFAULT_FREEZE_TOKEN = "bash-merge"

      # Common paths where tree-sitter-bash library might be installed
      # Searched in order until one is found
      # For versioned libraries (e.g., Fedora), set TREE_SITTER_BASH_PATH env var
      PARSER_SEARCH_PATHS = [
        "/usr/lib/libtree-sitter-bash.so",
        "/usr/lib64/libtree-sitter-bash.so",
        "/usr/local/lib/libtree-sitter-bash.so",
        "/opt/homebrew/lib/libtree-sitter-bash.dylib",
        "/usr/local/lib/libtree-sitter-bash.dylib",
      ].freeze

      # @return [CommentTracker] Comment tracker for this file
      attr_reader :comment_tracker

      # @return [TreeSitter::Tree, nil] Parsed AST
      attr_reader :ast

      # @return [Array] Parse errors if any
      attr_reader :errors

      # Find the parser library path
      # @return [String, nil] Path to the parser library or nil if not found
      def self.find_parser_path
        # Check environment variable first
        env_path = ENV["TREE_SITTER_BASH_PATH"]
        return env_path if env_path && File.exist?(env_path)

        # Search common paths
        PARSER_SEARCH_PATHS.find { |path| File.exist?(path) }
      end

      # Initialize file analysis
      #
      # @param source [String] Bash source code to analyze
      # @param freeze_token [String] Token for freeze block markers
      # @param signature_generator [Proc, nil] Custom signature generator
      # @param parser_path [String, nil] Path to tree-sitter-bash parser library
      def initialize(source, freeze_token: DEFAULT_FREEZE_TOKEN, signature_generator: nil, parser_path: nil)
        @source = source
        @lines = source.lines.map(&:chomp)
        @freeze_token = freeze_token
        @signature_generator = signature_generator
        @parser_path = parser_path || self.class.find_parser_path
        @errors = []

        # Initialize comment tracking
        @comment_tracker = CommentTracker.new(source)

        # Parse the Bash script
        DebugLogger.time("FileAnalysis#parse_bash") { parse_bash }

        # Extract freeze blocks and integrate with nodes
        @freeze_blocks = extract_freeze_blocks
        @nodes = integrate_nodes_and_freeze_blocks

        DebugLogger.debug("FileAnalysis initialized", {
          signature_generator: signature_generator ? "custom" : "default",
          nodes_count: @nodes.size,
          freeze_blocks: @freeze_blocks.size,
          valid: valid?,
        })
      end

      # Check if parse was successful
      # @return [Boolean]
      def valid?
        @errors.empty? && !@ast.nil?
      end

      # The base module uses 'statements' - provide both names for compatibility
      # @return [Array<NodeWrapper, FreezeNodeBase>]
      def statements
        @nodes ||= []
      end

      # Alias for convenience - bash-merge prefers "nodes" terminology
      alias_method :nodes, :statements

      # Check if a line is within a freeze block
      # @param line_num [Integer] 1-based line number
      # @return [Boolean]
      def in_freeze_block?(line_num)
        @freeze_blocks.any? { |fb| fb.location.cover?(line_num) }
      end

      # Get the freeze block containing the given line
      # @param line_num [Integer] 1-based line number
      # @return [FreezeNodeBase, nil]
      def freeze_block_at(line_num)
        @freeze_blocks.find { |fb| fb.location.cover?(line_num) }
      end

      # Generate signature for a node
      # @param node [NodeWrapper, FreezeNodeBase] Node to generate signature for
      # @return [Array, nil]
      def generate_signature(node)
        result = if @signature_generator
          custom_result = @signature_generator.call(node)
          if fallthrough_node?(custom_result)
            # Fall through to default computation
            compute_node_signature(custom_result)
          else
            custom_result
          end
        else
          compute_node_signature(node)
        end

        DebugLogger.debug("Generated signature", {
          node_type: node.class.name.split("::").last,
          signature: result,
          generator: @signature_generator ? "custom" : "default",
        }) if result

        result
      end

      # Override to detect tree-sitter nodes for signature generator fallthrough
      # @param value [Object] The value to check
      # @return [Boolean] true if this is a fallthrough node
      def fallthrough_node?(value)
        value.is_a?(NodeWrapper) || value.is_a?(FreezeNode)
      end

      # Get normalized line content (stripped)
      # @param line_num [Integer] 1-based line number
      # @return [String, nil]
      def normalized_line(line_num)
        return if line_num < 1 || line_num > @lines.length

        @lines[line_num - 1].strip
      end

      # Get the root node of the parse tree
      # @return [NodeWrapper, nil]
      def root_node
        return unless valid?

        NodeWrapper.new(@ast.root_node, lines: @lines, source: @source)
      end

      # Get top-level statements from the script
      # @return [Array<NodeWrapper>]
      def top_level_statements
        return [] unless valid?

        root = @ast.root_node
        return [] unless root

        statements = []
        root.each do |child|
          next if child.type.to_s == "comment" # Comments handled separately

          statements << NodeWrapper.new(child, lines: @lines, source: @source)
        end
        statements
      end

      private

      def parse_bash
        unless @parser_path && File.exist?(@parser_path)
          @errors << "Tree-sitter bash parser not found at #{@parser_path.inspect}. Install tree-sitter-bash or set TREE_SITTER_BASH_PATH."
          @ast = nil
          return
        end

        begin
          language = TreeSitter::Language.load("bash", @parser_path)
          parser = TreeSitter::Parser.new
          parser.language = language
          @ast = parser.parse_string(nil, @source)

          # parse_string returns nil on ABI version mismatch or other parser issues
          if @ast.nil?
            @errors << "Tree-sitter bash parser failed to parse. This may indicate an ABI version mismatch between ruby_tree_sitter and the bash parser library at #{@parser_path}."
          end

          # Check for parse errors in the tree
          if @ast&.root_node&.has_error?
            collect_parse_errors(@ast.root_node)
          end
        rescue Exception => e
          @errors << "#{e.class}: #{e.message}"
          @ast = nil
        end
      end

      def collect_parse_errors(node)
        # Collect ERROR and MISSING nodes from the tree
        if node.type.to_s == "ERROR" || node.missing?
          @errors << {
            type: node.type.to_s,
            start_point: node.start_point,
            end_point: node.end_point,
            text: node.to_s,
          }
        end

        node.each { |child| collect_parse_errors(child) }
      end

      def extract_freeze_blocks
        # Use shared pattern from Ast::Merge::FreezeNodeBase with our specific token
        freeze_pattern = Ast::Merge::FreezeNodeBase.pattern_for(:hash_comment, @freeze_token)

        freeze_starts = []
        freeze_ends = []

        @lines.each_with_index do |line, idx|
          line_num = idx + 1
          next unless (match = line.match(freeze_pattern))

          marker_type = match[1]&.downcase # 'freeze' or 'unfreeze'
          if marker_type == "freeze"
            freeze_starts << {line: line_num, marker: line}
          elsif marker_type == "unfreeze"
            freeze_ends << {line: line_num, marker: line}
          end
        end

        # Match freeze starts with ends
        blocks = []
        freeze_starts.each do |start_info|
          # Find the next unfreeze after this freeze
          matching_end = freeze_ends.find { |e| e[:line] > start_info[:line] }
          next unless matching_end

          # Remove used end marker
          freeze_ends.delete(matching_end)

          blocks << FreezeNode.new(
            start_line: start_info[:line],
            end_line: matching_end[:line],
            lines: @lines,
            start_marker: start_info[:marker],
            end_marker: matching_end[:marker],
          )
        end

        blocks
      end

      def integrate_nodes_and_freeze_blocks
        return @freeze_blocks.dup unless valid?

        result = []
        processed_lines = ::Set.new

        # Mark freeze block lines as processed
        @freeze_blocks.each do |fb|
          (fb.start_line..fb.end_line).each { |ln| processed_lines << ln }
          result << fb
        end

        # Add top-level statements that aren't in freeze blocks
        top_level_statements.each do |stmt|
          next unless stmt.start_line && stmt.end_line

          # Skip if any part of this statement is in a freeze block
          stmt_lines = (stmt.start_line..stmt.end_line).to_a
          next if stmt_lines.any? { |ln| processed_lines.include?(ln) }

          result << stmt
        end

        # Sort by start line
        result.sort_by { |node| node.start_line || 0 }
      end

      def compute_node_signature(node)
        case node
        when FreezeNode
          node.signature
        when NodeWrapper
          node.signature
        end
      end
    end
  end
end
