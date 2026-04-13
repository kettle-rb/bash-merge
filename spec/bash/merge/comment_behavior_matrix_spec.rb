# frozen_string_literal: true

require "spec_helper"
require "ast/merge/rspec/shared_examples"

RSpec.describe "bash comment behavior matrix", :bash_grammar do
  extend Ast::Merge::RSpec::CommentBehaviorMatrixAdapters

  include_examples "Ast::Merge::CommentBehaviorMatrix" do
    hash_comment_line_based_comment_matrix_adapter(
      analysis_class: Bash::Merge::FileAnalysis,
      merger_class: Bash::Merge::SmartMerger,
      structural_owners_reader: ->(analysis) { analysis.top_level_statements.select(&:variable_assignment?) },
      owner_value_reader: ->(owner) { owner.text[%r{\A[a-zA-Z_][a-zA-Z0-9_]*=(.+)\z}, 1] },
      line_builder: lambda do |name, value, inline: nil|
        line = "#{name}=#{value}"
        inline ? "#{line} # #{inline}" : line
      end,
      capabilities: {
        floating_leading_regions: "gap-separated leading docs are not yet surfaced as floating attachment regions",
        template_only_floating_comment_additions: "template-only additions currently omit floating leading docs and their gap",
        template_only_preamble_additions: "template-only additions currently omit file-preamble comments",
        template_only_trailing_comment_additions: "template-only additions currently omit trailing full-line docs",
      },
    )
  end
end
