require "spec"
require "../src/brainfuck"

def assert_compile_error(path : String, message : String) : Nil
  buffer = IO::Memory.new
  result = Process.run("crystal", ["build", "--no-color", "--no-codegen", "spec/" + path], error: buffer)
  result.success?.should be_false
  buffer.to_s.should contain message
  buffer.close
end
