# frozen_string_literal: true

module Bash
  module Merge
    # Custom Bash emitter that preserves comments and formatting.
    # This class provides utilities for emitting Bash while maintaining
    # the original structure, comments, and style choices.
    #
    # @example Basic usage
    #   emitter = Emitter.new
    #   emitter.emit_comment("This is a comment")
    #   emitter.emit_line("echo 'hello'")
    class Emitter
      # @return [Array<String>] Output lines
      attr_reader :lines

      # @return [Integer] Current indentation level
      attr_reader :indent_level

      # @return [Integer] Spaces per indent level
      attr_reader :indent_size

      # Initialize a new emitter
      #
      # @param indent_size [Integer] Number of spaces per indent level
      def initialize(indent_size: 2)
        @lines = []
        @indent_level = 0
        @indent_size = indent_size
      end

      # Emit a comment line
      #
      # @param text [String] Comment text (without #)
      # @param inline [Boolean] Whether this is an inline comment
      def emit_comment(text, inline: false)
        if inline
          # Inline comments are appended to the last line
          return if @lines.empty?

          @lines[-1] = "#{@lines[-1]} # #{text}"
        else
          @lines << "#{current_indent}# #{text}"
        end
      end

      # Emit leading comments
      #
      # @param comments [Array<Hash>] Comment hashes from CommentTracker
      def emit_leading_comments(comments)
        comments.each do |comment|
          # Preserve original indentation from comment
          indent = " " * (comment[:indent] || 0)
          @lines << "#{indent}# #{comment[:text]}"
        end
      end

      # Emit a blank line
      def emit_blank_line
        @lines << ""
      end

      # Emit a shebang line
      #
      # @param interpreter [String] Interpreter path (e.g., "/bin/bash")
      def emit_shebang(interpreter = "/bin/bash")
        @lines << "#!#{interpreter}"
      end

      # Emit a variable assignment
      #
      # @param name [String] Variable name
      # @param value [String] Variable value
      # @param export [Boolean] Whether to export the variable
      # @param inline_comment [String, nil] Optional inline comment
      def emit_variable_assignment(name, value, export: false, inline_comment: nil)
        prefix = export ? "export " : ""
        line = "#{current_indent}#{prefix}#{name}=#{value}"
        line += " # #{inline_comment}" if inline_comment
        @lines << line
      end

      # Emit a function definition start
      #
      # @param name [String] Function name
      def emit_function_start(name)
        @lines << "#{current_indent}#{name}() {"
        @indent_level += 1
      end

      # Emit a function definition end
      def emit_function_end
        @indent_level -= 1 if @indent_level > 0
        @lines << "#{current_indent}}"
      end

      # Emit an if statement start
      #
      # @param condition [String] Condition expression
      def emit_if_start(condition)
        @lines << "#{current_indent}if #{condition}; then"
        @indent_level += 1
      end

      # Emit an elif clause
      #
      # @param condition [String] Condition expression
      def emit_elif(condition)
        @indent_level -= 1 if @indent_level > 0
        @lines << "#{current_indent}elif #{condition}; then"
        @indent_level += 1
      end

      # Emit an else clause
      def emit_else
        @indent_level -= 1 if @indent_level > 0
        @lines << "#{current_indent}else"
        @indent_level += 1
      end

      # Emit an if statement end
      def emit_fi
        @indent_level -= 1 if @indent_level > 0
        @lines << "#{current_indent}fi"
      end

      # Emit a for loop start
      #
      # @param var [String] Loop variable name
      # @param items [String] Items to iterate over
      def emit_for_start(var, items)
        @lines << "#{current_indent}for #{var} in #{items}; do"
        @indent_level += 1
      end

      # Emit a for loop end
      def emit_done
        @indent_level -= 1 if @indent_level > 0
        @lines << "#{current_indent}done"
      end

      # Emit a while loop start
      #
      # @param condition [String] Condition expression
      def emit_while_start(condition)
        @lines << "#{current_indent}while #{condition}; do"
        @indent_level += 1
      end

      # Emit a case statement start
      #
      # @param expression [String] Expression to match
      def emit_case_start(expression)
        @lines << "#{current_indent}case #{expression} in"
        @indent_level += 1
      end

      # Emit a case pattern
      #
      # @param pattern [String] Pattern to match
      def emit_case_pattern(pattern)
        @lines << "#{current_indent}#{pattern})"
        @indent_level += 1
      end

      # Emit a case pattern terminator
      def emit_case_pattern_end
        @indent_level -= 1 if @indent_level > 0
        @lines << "#{current_indent};;"
      end

      # Emit a case statement end
      def emit_esac
        @indent_level -= 1 if @indent_level > 0
        @lines << "#{current_indent}esac"
      end

      # Emit a raw line of code
      #
      # @param line [String] Line to emit
      def emit_line(line)
        @lines << "#{current_indent}#{line}"
      end

      # Emit raw lines (for preserving existing content)
      #
      # @param raw_lines [Array<String>] Lines to emit as-is
      def emit_raw_lines(raw_lines)
        raw_lines.each { |line| @lines << line.chomp }
      end

      # Get the output as a single string
      #
      # @return [String]
      def to_bash
        content = @lines.join("\n")
        content += "\n" unless content.empty? || content.end_with?("\n")
        content
      end

      # Alias for consistency with other merge gems
      # @return [String]
      alias_method :to_s, :to_bash

      # Clear the output
      def clear
        @lines = []
        @indent_level = 0
      end

      private

      def current_indent
        " " * (@indent_level * @indent_size)
      end
    end
  end
end
