str = $stdin.read

bin = "YARB\u0002\u0000\u0000\u0000\u0005\u0000\u0000\u0000\u0000\u0000\u0000" +
      "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000" +
      "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000" +
      "\u0000\u0000\u0000\u0000\u0000x86_64-darwin16\u0000"

putself = 16
putstring = 20
opt_send_without_block = 52
leave = 55

hello = 3

codes = [
  putself,
  putstring, hello,
  opt_send_without_block, 0, 0,
  leave
]

iseq_offset = bin.length

bin << codes.pack("q*")

insns_info_list = [0, 1, 1, 1, 1, 0]
insns_info_size = 2
insns_info_offset = bin.length

bin << insns_info_list.pack("I*")

local_table_offset = bin.length

ci_entries_offset = bin.length
ci_entries = [[1, 40, 1]]

ci_entries.each do |entry|
  bin << entry.pack("qI2")
end

iseq_list = []
iseq_list << bin.length

params = [0] * 12

location = [1,2,2,3,1,0,1,20]

iseq_info = [
  iseq_type = 0,
  codes.length,
  iseq_offset,
  params = [0] * 12,
  location, 
  insns_info_offset,
  local_table_offset,
  catch_table_offset = 0,
  parent_iseq = -1,
  local_iseq = 0,
  is_entries = 0,
  ci_entries_offset,
  cc_entries = 0,
  mark_ary = 0,
  local_table_size = 0,
  is_size = 0,
  ci_size = 1,
  ci_kw_size = 0,
  insns_info_size,
  stack_max = 2,
].flatten

bin << iseq_info.pack("I2QI12q4I4q9I6")

iseq_list_offset = bin.length
bin << iseq_list.pack("I")

id_list_offset = bin.length

id_list = [0, 4]

bin << id_list.pack("q*")

qnil = [0x11 | 0b111111111100000, 8]
objpath = [0x05 | 0b111111101000000, 1, 0, ""]
label = [0x05 | 0b111111101000000, 2, "<compiled>".yield_self{|x| [x.length, x]}].flatten
hello_world = [0x05 | 0b111111101000000, 1, str.length, str]
puts_ = [0x05 | 0b111111101000000, 2, "puts".yield_self{|x| [x.length, x]}].flatten

object_list = []
object_list << bin.length
bin << qnil.pack("IQ")
object_list << bin.length
bin << objpath.pack("IQ2a*")
object_list << bin.length
bin << label.pack("IQ2a*")
object_list << bin.length
bin << hello_world.pack("IQ2a*")
object_list << bin.length
bin << puts_.pack("IQ2a*")
object_list_offset = bin.length
bin << object_list.pack("I*")

size = bin.length
object_list_size = object_list.length

bin[12,4 * 8] = [
  size, 
  extra_size = 0,
  iseq_list_size = 1,
  id_list_size = 2,
  object_list_size, 
  iseq_list_offset,
  id_list_offset,
  object_list_offset].pack("I*")

bin[16,4] = [0].pack("I")

File.write ARGV[0], bin
