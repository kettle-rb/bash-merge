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

      # Get all tracked comments converted to shared Ast::Merge comment nodes.
      #
      # @return [Array<Ast::Merge::Comment::Line>]
      def comment_nodes
        @comment_nodes ||= @comments.map { |comment| build_comment_node(comment) }
      end

      # Get a shared Ast::Merge comment node at a specific line.
      #
      # @param line_num [Integer] 1-based line number
      # @return [Ast::Merge::Comment::Line, nil]
      def comment_node_at(line_num)
        comment = comment_at(line_num)
        return unless comment

        build_comment_node(comment)
      end

      # Get all comments in a line range
      #
      # @param range [Range] Range of 1-based line numbers
      # @return [Array<Hash>] Comments in the range
      def comments_in_range(range)
        @comments.select { |c| range.cover?(c[:line]) }
      end

      # Get comments in a line range converted to a shared comment region.
      #
      # @param range [Range] Range of 1-based line numbers
      # @param kind [Symbol] Region kind (:leading, :inline, :orphan, etc.)
      # @param full_line_only [Boolean] Whether to keep only full-line comments
      # @return [Ast::Merge::Comment::Region]
      def comment_region_for_range(range, kind:, full_line_only: false)
        selected = comments_in_range(range)
        selected = selected.select { |comment| comment[:full_line] } if full_line_only

        build_region(
          kind: kind,
          comments: selected,
          metadata: {
            range: range,
            full_line_only: full_line_only,
            source: :comment_tracker,
          },
        )
      end

      # Get a shared leading comment region before a line.
      #
      # @param line_num [Integer] 1-based line number
      # @param comments [Array<Hash>, nil] Optional preselected comment hashes
      # @return [Ast::Merge::Comment::Region, nil]
      def leading_comment_region_before(line_num, comments: nil)
        selected = comments || leading_comments_before(line_num)
        selected = selected.select { |comment| comment[:full_line] }
        return if selected.empty?

        build_region(
          kind: :leading,
          comments: selected,
          metadata: {
            line_num: line_num,
            source: :comment_tracker,
          },
        )
      end

      # Get a shared inline comment region at a line.
      #
      # @param line_num [Integer] 1-based line number
      # @param comment [Hash, nil] Optional preselected inline comment hash
      # @return [Ast::Merge::Comment::Region, nil]
      def inline_comment_region_at(line_num, comment: nil)
        selected = [comment || inline_comment_at(line_num)].compact
        return if selected.empty?

        build_region(
          kind: :inline,
          comments: selected,
          metadata: {
            line_num: line_num,
            source: :comment_tracker,
          },
        )
      end

      # Build a passive shared comment attachment for an owner.
      #
      # @param owner [Object] Structural owner for the attachment
      # @param line_num [Integer, nil] Line number to use for leading/inline lookup
      # @param leading_comments [Array<Hash>, nil] Optional preselected leading comments
      # @param inline_comment [Hash, nil] Optional preselected inline comment
      # @param metadata [Hash] Additional metadata preserved on the attachment
      # @return [Ast::Merge::Comment::Attachment]
      def comment_attachment_for(owner, line_num: nil, leading_comments: nil, inline_comment: nil, **metadata)
        resolved_line_num = line_num || owner_line_num(owner)
        leading_region = if resolved_line_num
          leading_comment_region_before(resolved_line_num, comments: leading_comments)
        end
        inline_region = if resolved_line_num
          inline_comment_region_at(resolved_line_num, comment: inline_comment)
        end

        build_attachment(
          owner: owner,
          leading_region: leading_region,
          inline_region: inline_region,
          metadata: metadata.merge(
            line_num: resolved_line_num,
            source: :comment_tracker,
          ),
        )
      end

      # Get leading comments before a line (consecutive comment lines immediately above)
      #
      # @param line_num [Integer] 1-based line number
      # @return [Array<Hash>] Leading comments
      def leading_comments_before(line_num)
        leading = []
        current = line_num - 1

        current -= 1 while current >= 1 && blank_line?(current)

        while current >= 1
          comment = comment_at(current)
          break unless comment && comment[:full_line]

          leading.unshift(comment)
          current -= 1
          current -= 1 while current >= 1 && blank_line?(current)
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

      # Get raw line content.
      #
      # @param line_num [Integer] 1-based line number
      # @return [String, nil]
      def line_at(line_num)
        return if line_num < 1 || line_num > @lines.length

        @lines[line_num - 1]
      end

      # Build a passive shared comment augmenter for this source.
      #
      # @param owners [Array<#start_line,#end_line>] Structural owners for attachment inference
      # @param options [Hash] Additional augmenter options
      # @return [Ast::Merge::Comment::Augmenter]
      def augment(owners: [], **options)
        if defined?(Ast::Merge::Comment::Augmenter)
          Ast::Merge::Comment::Augmenter.new(
            lines: @lines,
            comments: @comments,
            owners: owners,
            style: :hash_comment,
            total_comment_count: @comments.size,
            inline_comment_count: @comments.count { |comment| !comment[:full_line] },
            **options,
          )
        else
          build_fallback_augmenter(owners: owners)
        end
      end

      private

      def owner_line_num(owner)
        return owner.start_line if owner.respond_to?(:start_line) && owner.start_line

        nil
      end

      def build_comment_node(comment)
        if defined?(Ast::Merge::Comment::TrackedHashAdapter)
          Ast::Merge::Comment::TrackedHashAdapter.node(comment, style: :hash_comment)
        else
          Struct.new(:line_number, :text).new(comment[:line], comment[:text])
        end
      end

      def build_region(kind:, comments:, metadata: {})
        if defined?(Ast::Merge::Comment::TrackedHashAdapter)
          Ast::Merge::Comment::TrackedHashAdapter.region(
            kind: kind,
            comments: comments,
            style: :hash_comment,
            metadata: metadata,
          )
        else
          Struct.new(:kind, :nodes, :metadata).new(kind, comments.map { |comment| build_comment_node(comment) }, metadata)
        end
      end

      def build_attachment(owner:, leading_region:, inline_region:, metadata: {})
        if defined?(Ast::Merge::Comment::Attachment)
          Ast::Merge::Comment::Attachment.new(
            owner: owner,
            leading_region: leading_region,
            inline_region: inline_region,
            metadata: metadata,
          )
        else
          Struct.new(:owner, :leading_region, :inline_region, :metadata).new(owner, leading_region, inline_region, metadata)
        end
      end

      def build_fallback_augmenter(owners:)
        attachment_lookup = owners.each_with_object({}) do |owner, result|
          result[owner] = comment_attachment_for(owner)
        end

        capability = Struct.new(:source_augmented?).new(true)
        owner_lines = owners.filter_map do |owner|
          next unless owner.respond_to?(:start_line) && owner.respond_to?(:end_line)
          next unless owner.start_line && owner.end_line

          owner.start_line..owner.end_line
        end
        first_owner_line = owner_lines.map(&:begin).min
        last_owner_line = owner_lines.map(&:end).max

        preamble_comments = @comments.select do |comment|
          comment[:full_line] && first_owner_line && comment[:line] < first_owner_line
        end
        postlude_comments = @comments.select do |comment|
          comment[:full_line] && last_owner_line && comment[:line] > last_owner_line
        end

        preamble = build_region(kind: :preamble, comments: preamble_comments, metadata: {source: :comment_tracker})
        postlude = build_region(kind: :postlude, comments: postlude_comments, metadata: {source: :comment_tracker})

        Struct.new(:capability, :preamble_region, :postlude_region, :orphan_regions) do
          def attachment_for(owner)
            @attachment_lookup[owner]
          end

          def with_attachment_lookup(lookup)
            @attachment_lookup = lookup
            self
          end
        end.new(capability, preamble, postlude, []).with_attachment_lookup(attachment_lookup)
      end

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
