# frozen_string_literal: true

RSpec.describe Bash::Merge::Emitter do
  let(:emitter) { described_class.new }

  describe "#initialize" do
    it "starts with empty lines" do
      expect(emitter.lines).to be_empty
    end

    it "starts at indent level 0" do
      expect(emitter.indent_level).to eq(0)
    end

    it "accepts custom indent size" do
      custom_emitter = described_class.new(indent_size: 4)
      expect(custom_emitter.indent_size).to eq(4)
    end
  end

  describe "#emit_comment" do
    it "emits a full-line comment" do
      emitter.emit_comment("This is a comment")
      expect(emitter.lines).to include("# This is a comment")
    end

    it "emits an inline comment" do
      emitter.emit_line("echo 'hello'")
      emitter.emit_comment("inline", inline: true)
      expect(emitter.lines.last).to eq("echo 'hello' # inline")
    end
  end

  describe "#emit_shebang" do
    it "emits a shebang line" do
      emitter.emit_shebang("/bin/bash")
      expect(emitter.lines.first).to eq("#!/bin/bash")
    end

    it "uses /bin/bash by default" do
      emitter.emit_shebang
      expect(emitter.lines.first).to eq("#!/bin/bash")
    end
  end

  describe "#emit_variable_assignment" do
    it "emits a simple variable assignment" do
      emitter.emit_variable_assignment("FOO", '"bar"')
      expect(emitter.lines).to include('FOO="bar"')
    end

    it "emits an exported variable" do
      emitter.emit_variable_assignment("FOO", '"bar"', export: true)
      expect(emitter.lines).to include('export FOO="bar"')
    end

    it "includes inline comment when provided" do
      emitter.emit_variable_assignment("FOO", '"bar"', inline_comment: "my var")
      expect(emitter.lines.last).to include("# my var")
    end
  end

  describe "#emit_function_start / #emit_function_end" do
    it "emits a function definition" do
      emitter.emit_function_start("my_func")
      emitter.emit_line('echo "inside"')
      emitter.emit_function_end

      result = emitter.to_bash
      expect(result).to include("my_func() {")
      expect(result).to include("}")
    end

    it "indents function body" do
      emitter.emit_function_start("my_func")
      emitter.emit_line('echo "inside"')
      emitter.emit_function_end

      expect(emitter.lines[1]).to match(/^\s+echo/)
    end
  end

  describe "#emit_if_start / #emit_fi" do
    it "emits an if statement" do
      emitter.emit_if_start('[ "$x" -eq 1 ]')
      emitter.emit_line('echo "yes"')
      emitter.emit_fi

      result = emitter.to_bash
      expect(result).to include('if [ "$x" -eq 1 ]; then')
      expect(result).to include("fi")
    end
  end

  describe "#emit_for_start / #emit_done" do
    it "emits a for loop" do
      emitter.emit_for_start("i", "1 2 3")
      emitter.emit_line('echo "$i"')
      emitter.emit_done

      result = emitter.to_bash
      expect(result).to include("for i in 1 2 3; do")
      expect(result).to include("done")
    end
  end

  describe "#emit_raw_lines" do
    it "emits lines as-is" do
      emitter.emit_raw_lines(["line1\n", "line2\n"])
      expect(emitter.lines).to eq(["line1", "line2"])
    end
  end

  describe "#to_bash" do
    it "joins lines with newlines" do
      emitter.emit_shebang
      emitter.emit_line('echo "hello"')

      result = emitter.to_bash
      expect(result).to eq("#!/bin/bash\necho \"hello\"\n")
    end

    it "ensures trailing newline" do
      emitter.emit_line("echo 'test'")
      expect(emitter.to_bash).to end_with("\n")
    end
  end

  describe "#clear" do
    it "resets the emitter" do
      emitter.emit_line("test")
      emitter.clear

      expect(emitter.lines).to be_empty
      expect(emitter.indent_level).to eq(0)
    end
  end
end
