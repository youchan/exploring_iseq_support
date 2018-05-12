bin = File.read(ARGV[0])
iseq = RubyVM::InstructionSequence.load_from_binary(bin)
iseq.eval
