require "./spec_helper"

describe Brainfuck do
  describe "#new" do
    it "rejects invalid cell sizes" do
      assert_compile_error("test_files/compile_error.cr", "String is not a valid cell")
    end

    it "defaults input to STDIN" do
      bf = Brainfuck(Int8).new(output: IO::Memory.new)
      bf.input.should be(STDIN)
    end

    it "accepts an input io" do
      io = IO::Memory.new
      bf = Brainfuck(Int8).new(input: io, output: IO::Memory.new)
      bf.input.should be(io)
    end

    it "defaults output to STDOUT" do
      bf = Brainfuck(Int8).new(input: IO::Memory.new)
      bf.output.should be(STDOUT)
    end

    it "accepts an output io" do
      io = IO::Memory.new
      bf = Brainfuck(Int8).new(input: IO::Memory.new, output: io)
      bf.output.should be(io)
    end
  end

  describe "#run" do
    it "can run with string instructions" do
      bf = Brainfuck(Int8).new(input: IO::Memory.new, output: IO::Memory.new)
      bf.run(File.read("#{__DIR__}/test_files/hello_world.bf"))
    end

    it "can run with a path to instructions" do
      bf = Brainfuck(Int8).new(input: IO::Memory.new, output: IO::Memory.new)
      bf.run(Path.new("#{__DIR__}/test_files/hello_world.bf"))
    end

    it "can run with an io of instructions" do
      bf = Brainfuck(Int8).new(input: IO::Memory.new, output: IO::Memory.new)
      bf.run(IO::Memory.new(File.read("#{__DIR__}/test_files/hello_world.bf")))
    end

    it "can run with a file of instructions" do
      bf = Brainfuck(Int8).new(input: IO::Memory.new, output: IO::Memory.new)
      File.open("#{__DIR__}/test_files/hello_world.bf", "r") do |file|
        bf.run(file)
      end
    end
  end
end

{% for cell_size in Brainfuck::CELL_SIZES %}
describe Brainfuck({{cell_size}}) do
  it "accepts a cell size of #{{{cell_size}}}" do
    Brainfuck({{cell_size}}).new(input: IO::Memory.new, output: IO::Memory.new)
  end

  describe "it successfully runs" do
    Dir["#{__DIR__}/test_files/*.bf"].each do |instruction_string_path|
      output_file = instruction_string_path[0...-File.extname(instruction_string_path).size] + ".output"
      input_file = instruction_string_path[0...-File.extname(instruction_string_path).size] + ".input"
      next unless File.exists?(output_file)
      instruction_path = Path.new(instruction_string_path)
      test_name = File.basename(instruction_path)
      expected_output = File.read(output_file).gsub("{cell_size}", {{cell_size}}::MAX)

      it test_name do
        input = File.exists?(input_file) ? File.open(input_file, "r") : IO::Memory.new
        output = String.build do |output_io|
          bf = Brainfuck(Int8).new(input: input, output: output_io)
          bf.run(instruction_path)
        end

        output.should eq(expected_output)
      end
    end
  end

  describe "it successfully errors on" do
    Dir["#{__DIR__}/test_files/*.bf"].each do |instruction_string_path|
      output_file = instruction_string_path[0...-File.extname(instruction_string_path).size] + ".error"
      input_file = instruction_string_path[0...-File.extname(instruction_string_path).size] + ".input"
      next unless File.exists?(output_file)
      instruction_path = Path.new(instruction_string_path)
      test_name = File.basename(instruction_path)

      it test_name do
        input = File.exists?(input_file) ? File.open(input_file, "r") : IO::Memory.new
        output = IO::Memory.new
        bf = Brainfuck(Int8).new(input: input, output: output)
        expect_raises(Exception) do
          bf.run(instruction_path)
        end
      end
    end
  end
end
{% end %}
