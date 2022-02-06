class Brainfuck(T)
  VERSION = "0.1.0"

  property output : IO
  property input : IO

  CELL_SIZES = {Int8, Int16, Int32, Int64, Int128, UInt8, UInt16, UInt32, UInt64, UInt128}

  def initialize(*, @input : IO = STDIN, @output : IO = STDOUT)
    raise ArgumentError.new("invalid cell size") unless CELL_SIZES.includes?(T)
  end
end
