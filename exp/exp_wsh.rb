# encoding: UTF-8
require 'win32ole'

p WIN32OLE.codepage

def show ole, name = 'ole_obj'
  puts " #{name} is: #{ole.ole_type.inspect}" if ole.respond_to? :ole_type
  puts " #{name}'s Additonal methods:"
  p (ole.methods - Object.methods).map(&:to_s).uniq.sort
  if ole.respond_to? :ole_methods
    puts " #{name}'s OLE methods:"
    #p ole.ole_methods.map(&:to_s).uniq.sort
    methods = ole.ole_methods.select{ |m| m.visible? }.sort{|a, b| a.to_s<=>b.to_s}
    puts methods.map {|meth| signature_for meth }
  end
  puts
end

def signature_for meth
  sig = "#{meth.return_type} "
  sig += "#{meth.return_type_detail} " unless meth.return_type_detail.size == 1
  sig += "#{meth.name}("
  sig +=  meth.params.map {|param| param_for param}.join(", ") unless meth.params.empty?
  sig += ")"
end

def param_for param
  if param.default
    "#{param.ole_type} #{param.name}=#{param.default}"
  else
    "#{param.ole_type} #{param.name}"
  end
end

# Object WScript.Shell
show wsh = WIN32OLE.new('Wscript.Shell'), 'Wscript.Shell'

#wsh.Popup( 'message', 0, 'title', 1 ) # Pop-up, Doh
#puts wsh.CurrentDirectory()
show env = wsh.Environment, "wsh.Environment"
env.each {|env_item| puts "   -  #{env_item}"}
puts

# Echo?
#e = WIN32OLE.new('WScript.Echo "Hello World!"')

show shell = WIN32OLE.new('Shell.Application'), 'Shell.Application'
# Must be either IE or Windows Explorer
show windows = shell.Windows, 'shell.Windows'

puts "# of windows: #{windows.count.inspect}"
show windows.ole_method('GetTypeInfo'), "ole_method('GetTypeInfo')"

show expl = windows.Item(0), "windows.Item(0)"

# Playing with CD-ROM
show my_computer = shell.NameSpace(17), 'shell.NameSpace(17) - my computer'

show cdrom = my_computer.ParseName("D:\\"), 'ParseName("D:\\") - cdrom'

cdrom.Verbs.each do |verb|
  show verb, verb.Name
  #verb.doIt if verb.Name == "E&ject"
end

## Documenting Win32OLE
#my_com_object = WIN32OLE.new("Library.Class")
#
## Set my_com_object = GetObject("Library.Class")
#com_collection_object = WIN32OLE.connect("Library.Class")
#
## For Each com_object In com_collection_object
## '...
## Next
#for com_object in com_collection_object
#  p com_object.ole_methods
##...
#end

exit 0

# Playing with Folder
time = Time.now.to_s
if wsh.AppActivate('Фолдор')
  wsh.SendKeys("%FWFRB#{time}{ENTER}")
end

# Creating new Notepad window:
if not wsh.AppActivate('Notepad')
  wsh.Run('Notepad')
  sleep 1
end

# Playing with created Notepad window:
if wsh.AppActivate('Notepad')
  sleep 1
  p 'Inside'
  # Enter text into Notepad:
  wsh.SendKeys('Ruby{TAB}on{TAB}Windows{ENTER}')
  wsh.SendKeys("#{time}")
  # ALT-F to pull down File menu, then A to select Save As...:
  wsh.SendKeys('%FA')
  sleep 1
  wsh.SendKeys('C:\dev\apps\filename.txt{ENTER}')
  sleep 1
  # If prompted to overwrite existing file:

  if wsh.AppActivate('Save As')
    sleep 1
    # Enter 'Y':
    wsh.SendKeys('Y')
  end
  # Quit Notepad with ALT-F4:
  wsh.SendKeys('%{F4}')
end
