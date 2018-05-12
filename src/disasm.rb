iseq = RubyVM::InstructionSequence.compile(<<SRC, "", "")
  puts "Hello world"
SRC

puts iseq.disassemble
