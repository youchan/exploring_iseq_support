bin = File.read(ARGV[0])

( magic,
  major,
  minor,
  size,
  extra_size,
  iseq_list_size,
  id_list_size,
  object_list_size,
  iseq_list_offset,
  id_list_offset,
  object_list_offset,
  platform,
) = bin.unpack('a4I10Z*')

puts "magic: #{magic}"
puts "Version: #{major}.#{minor}"
puts "size: #{size}"
puts "extra_size: #{extra_size}"
puts "iseq_list_size: #{iseq_list_size}"
puts "id_list_size: #{id_list_size}"
puts "object_list_size: #{object_list_size}"
puts "iseq_list_offset: #{iseq_list_offset}"
puts "id_list_offset: #{id_list_offset}"
puts "object_list_offset: #{object_list_offset}"
puts "platform: #{platform}"

def show_bin(str)
  hex = str.unpack("h*").first
  puts hex.chars.each_slice(4).map(&:join).each_slice(16).map {|c| c.join(" ") }.join("\n")
end

puts
puts "---------- iSeq List ----------"

iseq_list = bin.slice(iseq_list_offset, iseq_list_size * 4).unpack("I*")

codes_offsets = iseq_list.sort.map do |offset|
  ( type,
    iseq_size,
    iseq_encoded
  ) = bin.slice(offset, 16).unpack("I2Q")

  iseq_encoded
end

(codes_offsets + [iseq_list_offset]).each_cons(2) do |s, e|
  show_bin bin.slice(s, e - s)
  puts "-" * 80 
end

puts
puts "---------- ID List ----------"

id_list = bin.slice(id_list_offset, id_list_size * 8).unpack("Q*")

p id_list

puts "-" * 80 

puts
puts "---------- Object List ----------"

object_list = bin.slice(object_list_offset, object_list_size * 4).unpack("I*")

(object_list.sort + [object_list_offset]).each_cons(2) do |s, e|
  show_bin bin.slice(s, e - s)
  puts "-" * 80 
end

