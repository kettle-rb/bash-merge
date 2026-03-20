# frozen_string_literal: true

module Bash
  module Merge
    # Extracts and tracks comments with their line numbers from Bash source.
    # Bash comments use the # syntax, making freeze block detection straightforward.
    #
    # Inherits shared lookup, query, region-building, and attachment API from
    # +Ast::Merge::Comment::HashTrackerBase+. Only format-specific comment
    # extraction, shebang detection, and owner resolution are overridden here.
    #
    # @example Basic usage
    #   tracker = CommentTracker.new(bash_source)
    #   tracker.comments # => [{line: 1, indent: 0, text: "This is a comment"}]
    #   tracker.comment_at(1) # => {line: 1, indent: 0, text: "This is a comment"}
    #
    # @example Comment types
    #   # Full-line comment
    #   command # Inline comment
    class CommentTracker < Ast::Merge::Comment::HashTrackerBase
      # Initialize comment tracker by scanning the source
      #
      # @param source [String] Bash source code
      def initialize(source)
        @source = source
        super(source.lines.map(&:chomp))
      end

      # Check if a line is a shebang
      #
      # @param line_num [Integer] 1-based line number
      # @return [Boolean]
      def shebang?(line_num)
        return false if line_num < 1 || line_num > @lines.length

        @lines[line_num - 1].start_with?("#!")
      end

      def augment(owners: [], **options)
        Ast::Merge::Comment::Augmenter.new(
          lines: @lines,
          comments: @comments,
          owners: owners,
          style: :hash_comment,
          total_comment_count: @comments.size,
          inline_comment_count: @comments.count { |comment| !comment[:full_line] },
          **options,
        )
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
              indent: match[:indent].length,
              text: match[:text],
              full_line: true,
              raw: line,
            }
          elsif (inline_comment = extract_inline_comment(line))
            comments << {
              line: line_num,
              indent: 0,
              text: inline_comment[:text],
              full_line: false,
              raw: inline_comment[:raw],
            }
          end
        end

        comments
      end

      def extract_inline_comment(line)
        comment_start = inline_comment_start_index(line)
        return unless comment_start

        raw = line[comment_start..]
        {
          text: raw.sub(/\A#\s?/, ""),
          raw: raw,
        }
      end

      def inline_comment_start_index(line)
        in_single_quote = false
        in_double_quote = false
        escaped = false

        line.each_char.with_index do |char, idx|
          if escaped
            escaped = false
            next
          end

          if in_single_quote
            in_single_quote = false if char == "'"
            next
          end

          if in_double_quote
            case char
            when "\\"
              escaped = true
            when '"'
              in_double_quote = false
            end
            next
          end

          case char
          when "\\"
            escaped = true
          when "'"
            in_single_quote = true
          when '"'
            in_double_quote = true
          when "#"
            next if idx.zero?
            next unless line[idx - 1].match?(/\s/)
            next if line[0...idx].strip.empty?

            return idx
          end
        end

        nil
      end
    end
  end
end
