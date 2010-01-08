# encoding: CP1251
Encoding.default_internal, Encoding.default_external = ['utf-8'] * 2
t = '��������� �����������!'
d = t.encode('CP866')
utf8 = t.encode('utf-8')

puts '��������� �����������!', t, utf8, "#{d}  #{d.encoding}"

str = "\xE2\x80\x93"
puts "Str: #{str}, #{str.encoding}"

p "Source encoding: #{__ENCODING__}"
p "String encoding: #{t.encoding}"
p "Def ext encoding: #{Encoding.default_external}"
p "Def int encoding: #{Encoding.default_internal}"

puts

puts 'Playing with encodings: setting default to utf-8'
Encoding.default_internal, Encoding.default_external = ['utf-8'] * 2
p "Source encoding: #{__ENCODING__}"
p "Def ext encoding: #{Encoding.default_external}"
p "Def int encoding: #{Encoding.default_internal}"
zhopa ='Yes, ��� ����!!'
puts zhopa
p "String encoding: #{zhopa.encoding}"
puts zhopa.encode!('CP866', :undef => :replace)
p "String encoding: #{zhopa.encoding}"

puts
puts 'Playing with encodings: setting default to cp866'
Encoding.default_internal, Encoding.default_external = ['cp866'] * 2
p "Source encoding: #{__ENCODING__}"
p "Def ext encoding: #{Encoding.default_external}"
p "Def int encoding: #{Encoding.default_internal}"
zhopa ='Yes, ��� ����!!'
puts zhopa
p "String encoding: #{zhopa.encoding}"
puts zhopa.encode!('CP866', :undef => :replace)
p "String encoding: #{zhopa.encoding}"
