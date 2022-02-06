require "./spec_helper"

describe Brainfuck do
  describe "#new " do
    {% for cell_size in Brainfuck::CELL_SIZES %}
      it "accepts cell size of #{{{cell_size}}}" do
        Brainfuck({{cell_size}}).new
      end
    {% end %}

    it "rejects invalid cell sizes" do
      expect_raises(ArgumentError) do
        Brainfuck(String).new
      end
    end
  end
end
