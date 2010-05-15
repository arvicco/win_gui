#require File.join(File.dirname(__FILE__), ".." , "..", "note" )
require 'win_gui/win_gui'

class LockNote < Note
  include WinGui

  APP_PATH = File.join(File.dirname(__FILE__),".." ,"test_apps/locknote/LockNote.exe" )
  APP_START = 'start "" "' + APP_PATH + '"'

  @@app = LockNote
  @@titles[:save] = 'Steganos LockNote'
  
  def initialize
    system APP_START
    @main_window = Window.top_level 'LockNote - Steganos LockNote'
    @edit_window = @main_window.child 'ATL:00434310'
  end
  
end