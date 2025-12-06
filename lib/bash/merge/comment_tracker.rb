# frozen_string_literal: true

module Bash
  module Merge
    # Extracts and tracks comments with their line numbers from Bash source.
    # Bash comments use the # syntax, making freeze block detection straightforward.
    #
    # @example Basic usage
    #   tracker = CommentTracker.new(bash_source)
    #   tracker.comments # => [{line: 1, indent: 0, text: "This is a comment"}]
    #   tracker.comment_at(1) # => {line: 1, indent: 0, text: "This is a comment"}
    #
    # @example Comment types
    #   # Full-line comment
    #   command # Inline comment
    class CommentTracker
      # Regex to match full-line comments (line is only whitespace + comment)
      FULL_LINE_COMMENT_REGEX = /\A(\s*)#\s?(.*)\z/

      # Regex to match inline comments (comment after Bash content)
      # Note: This is simplified and doesn't handle all edge cases like comments in strings
      INLINE_COMMENT_REGEX = /\s+#\s?(.*)$/

      # @return [Array<Hash>] All extracted comments with metadata
      attr_reader :comments

      # @return [Array<String>] Source lines
      attr_reader :lines

      # Initialize comment tracker by scanning the source
      #
      # @param source [String] Bash source code
      def initialize(source)
        @source = source
        @lines = source.lines.map(&:chomp)
        @comments = extract_comments
        @comments_by_line = @comments.group_by { |c| c[:line] }
      end

      # Get comment at a specific line
      #
      # @param line_num [Integer] 1-based line number
      # @return [Hash, nil] Comment info or nil
      def comment_at(line_num)
        @comments_by_line[line_num]&.first
      end

      # Get all comments in a line range
      #
      # @param range [Range] Range of 1-based line numbers
      # @return [Array<Hash>] Comments in the range
      def comments_in_range(range)
        @comments.select { |c| range.cover?(c[:line]) }
      end

      # Get leading comments before a line (consecutive comment lines immediately above)
      #
      # @param line_num [Integer] 1-based line number
      # @return [Array<Hash>] Leading comments
      def leading_comments_before(line_num)
        leading = []
        current = line_num - 1

        while current >= 1
          comment = comment_at(current)
          break unless comment && comment[:full_line]

          leading.unshift(comment)
          current -= 1
        end

        leading
      end

      # Get trailing comment on the same line (inline comment)
      #
      # @param line_num [Integer] 1-based line number
      # @return [Hash, nil] Inline comment or nil
      def inline_comment_at(line_num)
        comment = comment_at(line_num)
        comment if comment && !comment[:full_line]
      end

      # Check if a line is a full-line comment
      #
      # @param line_num [Integer] 1-based line number
      # @return [Boolean]
      def full_line_comment?(line_num)
        comment = comment_at(line_num)
        comment&.dig(:full_line) || false
      end

      # Check if a line is blank
      #
      # @param line_num [Integer] 1-based line number
      # @return [Boolean]
      def blank_line?(line_num)
        return false if line_num < 1 || line_num > @lines.length

        @lines[line_num - 1].strip.empty?
      end

      # Check if a line is a shebang
      #
      # @param line_num [Integer] 1-based line number
      # @return [Boolean]
      def shebang?(line_num)
        return false if line_num < 1 || line_num > @lines.length

        @lines[line_num - 1].start_with?("#!")
      end

      private

      def extract_comments
        comments = []

        @lines.each_with_index do |line, idx|
          line_num = idx + 1

          # Skip shebang lines
          next if line.start_with?("#!")

          # Check for full-line comment
          if (match = line.match(FULL_LINE_COMMENT_REGEX))
            comments << {
              line: line_num,
              indent: match[1].length,
              text: match[2],
              full_line: true,
              raw: line,
            }
          # Check for inline comment (simplified - doesn't handle quotes)
          elsif line.include?(" #") && !line.strip.start_with?("#")
            # Try to extract inline comment, but be careful with strings
            # This is a simplified approach
            if (inline_match = line.match(INLINE_COMMENT_REGEX))
              comments << {
                line: line_num,
                indent: 0,
                text: inline_match[1],
                full_line: false,
                raw: "# #{inline_match[1]}",
              }
            end
          end
        end

        comments
      end
    end
  end
end
