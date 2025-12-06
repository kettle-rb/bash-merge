# frozen_string_literal: true

RSpec.describe Bash::Merge do
  it "has a version number" do
    expect(Bash::Merge::VERSION).not_to be_nil
  end

  it "has the expected version format" do
    expect(Bash::Merge::VERSION).to match(/\A\d+\.\d+\.\d+/)
  end

  describe "module structure" do
    it "defines Error class inheriting from Ast::Merge::Error" do
      expect(Bash::Merge::Error).to be < Ast::Merge::Error
    end

    it "defines ParseError class inheriting from Ast::Merge::ParseError" do
      expect(Bash::Merge::ParseError).to be < Ast::Merge::ParseError
    end

    it "defines TemplateParseError class" do
      expect(Bash::Merge::TemplateParseError).to be < Bash::Merge::ParseError
    end

    it "defines DestinationParseError class" do
      expect(Bash::Merge::DestinationParseError).to be < Bash::Merge::ParseError
    end
  end

  describe "autoloaded classes" do
    it "autoloads CommentTracker" do
      expect(Bash::Merge::CommentTracker).to be_a(Class)
    end

    it "autoloads DebugLogger" do
      expect(Bash::Merge::DebugLogger).to be_a(Module)
    end

    it "autoloads Emitter" do
      expect(Bash::Merge::Emitter).to be_a(Class)
    end

    it "autoloads FreezeNode" do
      expect(Bash::Merge::FreezeNode).to be_a(Class)
    end

    it "autoloads FileAnalysis" do
      expect(Bash::Merge::FileAnalysis).to be_a(Class)
    end

    it "autoloads MergeResult" do
      expect(Bash::Merge::MergeResult).to be_a(Class)
    end

    it "autoloads NodeWrapper" do
      expect(Bash::Merge::NodeWrapper).to be_a(Class)
    end

    it "autoloads ConflictResolver" do
      expect(Bash::Merge::ConflictResolver).to be_a(Class)
    end

    it "autoloads SmartMerger" do
      expect(Bash::Merge::SmartMerger).to be_a(Class)
    end
  end
end
