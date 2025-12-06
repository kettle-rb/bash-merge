# frozen_string_literal: true

module Bash
  module Merge
    # Wraps tree-sitter nodes with comment associations, line information, and signatures.
    # This provides a unified interface for working with Bash AST nodes during merging.
    #
    # @example Basic usage
    #   parser = TreeSitter::Parser.new
    #   parser.language = TreeSitter::Language.load("bash", path)
    #   tree = parser.parse_string(nil, source)
    #   wrapper = NodeWrapper.new(tree.root_node, lines: source.lines, source: source)
    #   wrapper.signature # => [:program, ...]
    class NodeWrapper
      # @return [TreeSitter::Node] The wrapped tree-sitter node
      attr_reader :node

      # @return [Array<Hash>] Leading comments associated with this node
      attr_reader :leading_comments

      # @return [Hash, nil] Inline/trailing comment on the same line
      attr_reader :inline_comment

      # @return [Integer] Start line (1-based)
      attr_reader :start_line

      # @return [Integer] End line (1-based)
      attr_reader :end_line

      # @return [Array<String>] Source lines
      attr_reader :lines

      # @return [String] The original source string
      attr_reader :source

      # @param node [TreeSitter::Node] Tree-sitter node to wrap
      # @param lines [Array<String>] Source lines for content extraction
      # @param source [String] Original source string for byte-based text extraction
      # @param leading_comments [Array<Hash>] Comments before this node
      # @param inline_comment [Hash, nil] Inline comment on the node's line
      def initialize(node, lines:, source: nil, leading_comments: [], inline_comment: nil)
        @node = node
        @lines = lines
        @source = source || lines.join("\n")
        @leading_comments = leading_comments
        @inline_comment = inline_comment

        # Extract line information from the tree-sitter node (0-indexed to 1-indexed)
        @start_line = node.start_point.row + 1 if node.respond_to?(:start_point)
        @end_line = node.end_point.row + 1 if node.respond_to?(:end_point)

        # Handle edge case where end_line might be before start_line
        @end_line = @start_line if @start_line && @end_line && @end_line < @start_line
      end

      # Generate a signature for this node for matching purposes.
      # Signatures are used to identify corresponding nodes between template and destination.
      #
      # @return [Array, nil] Signature array or nil if not signaturable
      def signature
        compute_signature(@node)
      end

      # Check if this is a freeze node
      # @return [Boolean]
      def freeze_node?
        false
      end

      # Get the node type as a symbol
      # @return [Symbol]
      def type
        @node.type.to_sym
      end

      # Check if this node has a specific type
      # @param type_name [Symbol, String] Type to check
      # @return [Boolean]
      def type?(type_name)
        @node.type.to_s == type_name.to_s
      end

      # Check if this is a function definition
      # @return [Boolean]
      def function_definition?
        @node.type.to_s == "function_definition"
      end

      # Check if this is a variable assignment
      # @return [Boolean]
      def variable_assignment?
        @node.type.to_s == "variable_assignment"
      end

      # Check if this is an if statement
      # @return [Boolean]
      def if_statement?
        @node.type.to_s == "if_statement"
      end

      # Check if this is a for loop
      # @return [Boolean]
      def for_statement?
        %w[for_statement c_style_for_statement].include?(@node.type.to_s)
      end

      # Check if this is a while loop
      # @return [Boolean]
      def while_statement?
        @node.type.to_s == "while_statement"
      end

      # Check if this is a case statement
      # @return [Boolean]
      def case_statement?
        @node.type.to_s == "case_statement"
      end

      # Check if this is a command
      # @return [Boolean]
      def command?
        @node.type.to_s == "command"
      end

      # Check if this is a pipeline
      # @return [Boolean]
      def pipeline?
        @node.type.to_s == "pipeline"
      end

      # Check if this is a comment
      # @return [Boolean]
      def comment?
        @node.type.to_s == "comment"
      end

      # Get the function name if this is a function definition
      # @return [String, nil]
      def function_name
        return unless function_definition?

        # In bash tree-sitter, function name is in a 'name' or 'word' child
        name_node = find_child_by_type("word") || find_child_by_field("name")
        node_text(name_node) if name_node
      end

      # Get the variable name if this is a variable assignment
      # @return [String, nil]
      def variable_name
        return unless variable_assignment?

        # Get the variable name from the left side of assignment
        name_node = find_child_by_field("name")
        node_text(name_node) if name_node
      end

      # Get the command name if this is a command
      # @return [String, nil]
      def command_name
        return unless command?

        # First child that is a word or simple_expansion
        @node.each do |child|
          next if %w[comment file_redirect heredoc_redirect].include?(child.type.to_s)

          return node_text(child) if %w[word command_name].include?(child.type.to_s)
        end
        nil
      end

      # Get children wrapped as NodeWrappers
      # @return [Array<NodeWrapper>]
      def children
        return [] unless @node.respond_to?(:each)

        result = []
        @node.each do |child|
          result << NodeWrapper.new(child, lines: @lines, source: @source)
        end
        result
      end

      # Find a child by field name
      # @param field_name [String] Field name to look for
      # @return [TreeSitter::Node, nil]
      def find_child_by_field(field_name)
        return unless @node.respond_to?(:child_by_field_name)

        @node.child_by_field_name(field_name)
      end

      # Find a child by type
      # @param type_name [String] Type name to look for
      # @return [TreeSitter::Node, nil]
      def find_child_by_type(type_name)
        return unless @node.respond_to?(:each)

        @node.each do |child|
          return child if child.type.to_s == type_name
        end
        nil
      end

      # Get the text content for this node by extracting from source using byte positions
      # @return [String]
      def text
        node_text(@node)
      end

      # Extract text from a tree-sitter node using byte positions
      # @param ts_node [TreeSitter::Node] The tree-sitter node
      # @return [String]
      def node_text(ts_node)
        return "" unless ts_node.respond_to?(:start_byte) && ts_node.respond_to?(:end_byte)

        @source[ts_node.start_byte...ts_node.end_byte] || ""
      end

      # Get the content for this node from source lines
      # @return [String]
      def content
        return "" unless @start_line && @end_line

        (@start_line..@end_line).map { |ln| @lines[ln - 1] }.compact.join("\n")
      end

      # String representation for debugging
      # @return [String]
      def inspect
        "#<#{self.class.name} type=#{@node.type} lines=#{@start_line}..#{@end_line}>"
      end

      private

      def compute_signature(node)
        node_type = node.type.to_s

        case node_type
        when "program"
          # Root node - signature based on direct children structure
          child_types = []
          node.each { |child| child_types << child.type.to_s unless child.type.to_s == "comment" }
          [:program, child_types.length]
        when "function_definition"
          # Functions are identified by their name
          name = function_name
          [:function_definition, name]
        when "variable_assignment"
          # Variable assignments are identified by variable name
          name = variable_name
          [:variable_assignment, name]
        when "command"
          # Commands identified by their command name
          name = command_name
          [:command, name, extract_command_signature_context(node)]
        when "if_statement"
          # If statements identified by their condition pattern
          condition = extract_condition_pattern(node)
          [:if_statement, condition]
        when "for_statement", "c_style_for_statement"
          # For loops identified by their loop variable
          var = extract_loop_variable(node)
          [:for_statement, var]
        when "while_statement"
          # While loops identified by condition
          condition = extract_condition_pattern(node)
          [:while_statement, condition]
        when "case_statement"
          # Case statements identified by the expression being matched
          expr = extract_case_expression(node)
          [:case_statement, expr]
        when "pipeline"
          # Pipelines identified by command names in order
          commands = extract_pipeline_commands(node)
          [:pipeline, commands]
        when "comment"
          # Comments identified by their content
          [:comment, node_text(node)&.strip]
        else
          # Generic fallback - type and first few chars of content
          content_preview = node_text(node)&.slice(0, 50)&.strip
          [node_type.to_sym, content_preview]
        end
      end

      def extract_command_signature_context(node)
        # Extract additional context like redirections
        redirections = []
        node.each do |child|
          if child.type.to_s.include?("redirect")
            redirections << child.type.to_s
          end
        end
        redirections.empty? ? nil : redirections.sort
      end

      def extract_condition_pattern(node)
        # Try to extract the test/condition from if/while statements
        # Look for test_command, compound_statement, etc.
        node.each do |child|
          if %w[test_command bracket_command].include?(child.type.to_s)
            return node_text(child)&.slice(0, 100)&.strip
          end
        end
        nil
      end

      def extract_loop_variable(node)
        # Extract the loop variable from for statements
        var_node = node.each.find { |child| child.type.to_s == "variable_name" }
        node_text(var_node) if var_node
      end

      def extract_case_expression(node)
        # Extract the expression being matched in a case statement
        node.each do |child|
          return node_text(child)&.slice(0, 50)&.strip if child.type.to_s == "word" || child.type.to_s == "variable_name"
        end
        nil
      end

      def extract_pipeline_commands(node)
        # Extract command names from a pipeline
        commands = []
        node.each do |child|
          if child.type.to_s == "command"
            wrapper = NodeWrapper.new(child, lines: @lines, source: @source)
            cmd_name = wrapper.command_name
            commands << cmd_name if cmd_name
          end
        end
        commands
      end
    end
  end
end
