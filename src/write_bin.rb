str = $stdin.read
iseq = RubyVM::InstructionSequence.compile(str, "", "")

File.write(ARGV[0], iseq.to_binary)
