# frozen_string_literal: true

# External gems
# TreeHaver provides a unified cross-Ruby interface to tree-sitter
require "tree_haver"

# BACKEND COMPATIBILITY for Bash:
# - FFI: Most portable and reliable with bash grammar (recommended)
# - MRI: Has ABI incompatibility with bash grammar
# - Rust: Has version mismatch with bash grammar
#
# Set TREE_HAVER_BACKEND=ffi (or mri/rust) to control backend selection.
# When MRI loads a grammar first, FFI gets incompatible pointers (symbol conflict).
# MRI statically links tree-sitter, FFI dynamically links libtree-sitter.so.

# Register tree-sitter bash grammar
bash_finder = TreeHaver::GrammarFinder.new(:bash)
bash_available = bash_finder.available?
bash_finder.register! if bash_available

# Only warn if the grammar file is actually missing (not just runtime unavailable)
# When the runtime isn't available, tree-sitter backends just won't be used,
# which is expected behavior - no need to warn the user.
unless bash_available
  grammar_path = bash_finder.find_library_path
  unless grammar_path
    warn "WARNING: Bash grammar not available. #{bash_finder.not_found_message}"
  end
end

require "version_gem"
require "set"

# Shared merge infrastructure
require "ast/merge"

# This gem
require_relative "merge/version"

# Bash::Merge provides a generic Bash script smart merge system using tree-sitter AST analysis.
# It intelligently merges template and destination Bash scripts by identifying matching
# statements and resolving differences using structural signatures.
#
# @example Basic usage
#   template = File.read("template.sh")
#   destination = File.read("destination.sh")
#   merger = Bash::Merge::SmartMerger.new(template, destination)
#   result = merger.merge
#
# @example With debug information
#   merger = Bash::Merge::SmartMerger.new(template, destination)
#   debug_result = merger.merge_with_debug
#   puts debug_result[:content]
#   puts debug_result[:statistics]
module Bash
  # Smart merge system for Bash scripts using tree-sitter AST analysis.
  # Provides intelligent merging by understanding Bash structure
  # rather than treating files as plain text.
  #
  # @see SmartMerger Main entry point for merge operations
  # @see FileAnalysis Analyzes Bash structure
  # @see ConflictResolver Resolves content conflicts
  module Merge
    # Base error class for Bash::Merge
    # Inherits from Ast::Merge::Error for consistency across merge gems.
    class Error < Ast::Merge::Error; end

    # Raised when a Bash script has parsing errors.
    # Inherits from Ast::Merge::ParseError for consistency across merge gems.
    #
    # @example Handling parse errors
    #   begin
    #     analysis = FileAnalysis.new(bash_content)
    #   rescue ParseError => e
    #     puts "Bash syntax error: #{e.message}"
    #     e.errors.each { |error| puts "  #{error}" }
    #   end
    class ParseError < Ast::Merge::ParseError
      # @param message [String, nil] Error message (auto-generated if nil)
      # @param content [String, nil] The Bash source that failed to parse
      # @param errors [Array] Parse errors from tree-sitter
      def initialize(message = nil, content: nil, errors: [])
        super(message, errors: errors, content: content)
      end
    end

    # Raised when the template file has syntax errors.
    #
    # @example Handling template parse errors
    #   begin
    #     merger = SmartMerger.new(template, destination)
    #     result = merger.merge
    #   rescue TemplateParseError => e
    #     puts "Template syntax error: #{e.message}"
    #     e.errors.each do |error|
    #       puts "  #{error.message}"
    #     end
    #   end
    class TemplateParseError < ParseError; end

    # Raised when the destination file has syntax errors.
    #
    # @example Handling destination parse errors
    #   begin
    #     merger = SmartMerger.new(template, destination)
    #     result = merger.merge
    #   rescue DestinationParseError => e
    #     puts "Destination syntax error: #{e.message}"
    #     e.errors.each do |error|
    #       puts "  #{error.message}"
    #     end
    #   end
    class DestinationParseError < ParseError; end

    autoload :CommentTracker, "bash/merge/comment_tracker"
    autoload :DebugLogger, "bash/merge/debug_logger"
    autoload :Emitter, "bash/merge/emitter"
    autoload :FreezeNode, "bash/merge/freeze_node"
    autoload :FileAnalysis, "bash/merge/file_analysis"
    autoload :MergeResult, "bash/merge/merge_result"
    autoload :NodeWrapper, "bash/merge/node_wrapper"
    autoload :ConflictResolver, "bash/merge/conflict_resolver"
    autoload :SmartMerger, "bash/merge/smart_merger"
  end
end

Bash::Merge::Version.class_eval do
  extend VersionGem::Basic
end
