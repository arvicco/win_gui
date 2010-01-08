# encoding: UTF-8
require 'win32ole'

p WIN32OLE.codepage

wsh = WIN32OLE.new('Wscript.Shell')
print "wsh is: "; p wsh.ole_type

p (wsh.methods - Object.methods).sort
# wsh.Popup( 'message', 0, 'title', 1 ) # Pop-up, Doh
wsh.ExecEcho("Hello World!")

shell = WIN32OLE.new('Shell.Application')
windows = shell.Windows # Must be either IE or Windows Explorer

print "# of windows: "; p windows.count
print "windows methods: "; p windows.methods
print "windows is: "; p windows.ole_type
print "ole_method('GetTypeInfo') methods: "; p windows.ole_method('GetTypeInfo').methods - Object.methods
print "ole_method('GetTypeInfo') params: "; p windows.ole_method('GetTypeInfo').params
p windows.ole_methods

expl = windows.Item(0)
print "expl is: "; p expl.ole_type
p expl.methods - Object.methods

# Playing with CD-ROM
my_computer = shell.NameSpace(17)
print "my_computer is: "; p my_computer.ole_type
p my_computer.methods - Object.methods

cdrom = my_computer.ParseName("D:\\")
print "cdrom is: "; p cdrom.ole_type
p cdrom.methods - Object.methods

cdrom.Verbs.each do |verb|
  puts verb.Name
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


#exit 0

# Playing with Folder
time = Time.now.to_s
if wsh.AppActivate('Фолдор')
 wsh.SendKeys("%FWFRB#{time}{ENTER}")
end

# Playing with the Notepad window:
if not wsh.AppActivate('Notepad')
  wsh.Run('Notepad')
  sleep 1
end

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
