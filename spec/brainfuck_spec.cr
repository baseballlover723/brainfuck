require "./spec_helper"

describe Brainfuck do
  describe "#new " do
    {% for cell_size in Brainfuck::CELL_SIZES %}
      it "accepts cell size of #{{{cell_size}}}" do
        Brainfuck({{cell_size}}).new(input: IO::Memory.new, output:IO::Memory.new)
      end
    {% end %}

    it "rejects invalid cell sizes" do
      expect_raises(ArgumentError) do
        Brainfuck(String).new(input: IO::Memory.new, output: IO::Memory.new)
      end
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
end
