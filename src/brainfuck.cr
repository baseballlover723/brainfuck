class Brainfuck(T)
  VERSION = "0.1.0"

  property output : IO
  property input : IO

  # CELL_SIZES = {Int8, Int16, Int32, Int64, Int128, UInt8, UInt16, UInt32, UInt64, UInt128}
  CELL_SIZES = {UInt8, UInt16, UInt32, UInt64, UInt128}

  def initialize(*, @input : IO = STDIN, @output : IO = STDOUT)
    {% if !CELL_SIZES.map(&.symbolize).includes?(T.symbolize) %}
      {% raise "#{T} is not a valid cell size, please use one of #{CELL_SIZES}" %}
    {% end %}
    @tape = [T.new(0)] of T
    @data_pointer = 0_u64
    @instruction_pointer = 0_u64
    @infinite_loop_counter = 0_u64
  end

  def run(instructions : IO) : Nil
    run(instructions.gets_to_end)
  end

  def run(path : Path) : Nil
    File.open(path) do |file|
      run(file)
    end
  end

  def run(instructions : String) : Nil
    instructions = instructions.delete("^<>+\\-,.[]")
    
    while (@instruction_pointer < instructions.size)
      case command = instructions[@instruction_pointer]
      when '<'
        @data_pointer -= 1
      when '>'
        @data_pointer += 1
        @tape.push(T.new(0)) unless @tape.size < @data_pointer
      when '+'
        @tape[@data_pointer] &+= 1
      when '-'
        @tape[@data_pointer] &-= 1
      when '.'
        @output << @tape[@data_pointer].chr
      when ','
        # TODO read bytes? only deal with bytes? each byte?
        @tape[@data_pointer] = read_char
      when '['
        if @tape[@data_pointer] == 0
          counter = 1_u64
          while (counter > 0) 
            @instruction_pointer += 1
            raise "can't find matching ']'" if @instruction_pointer >= instructions.size
            case next_command = instructions[@instruction_pointer]
            when '['
              counter += 1
            when ']'
              counter -= 1
            end
          end
        end
      when ']'
        if @tape[@data_pointer] == 0
          @infinite_loop_counter = 0_u64
        else
          @infinite_loop_counter += 1
          raise "infinite loop detected" if @infinite_loop_counter > 1_000_000
          counter = 1_u64
          while (counter > 0)
            @instruction_pointer -= 1
            raise "can't find matching '['" if @instruction_pointer < 0
            case next_command = instructions[@instruction_pointer]
            when '['
              counter -= 1
            when ']'
              counter += 1
            end
          end
        end
      end
      @instruction_pointer += 1
    end
  end

  private def read_char : T
    local_input_var = @input # compiler treats this special and requires local vars https://crystal-lang.org/reference/1.3/syntax_and_semantics/if_varresponds_to.html
    # do this so that when working with stdin we block
    input_char = local_input_var.tty? && local_input_var.responds_to?(:raw) ? local_input_var.raw(&.read_char).as(Char) : poll_char
    T.new(input_char.ord)
  end

  private def poll_char : Char
    loop do
      input_char = @input.read_char
      if input_char
        return input_char.as(Char)
      else
        sleep 0.001
      end
    end
  end
end
