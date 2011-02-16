require 'rspec'
require 'win_gui'

# Customize RSpec with my own extensions
module SpecMacros

  # wrapper for it method that extracts description from example source code, such as:
  # spec { use{    function(arg1 = 4, arg2 = 'string')  }}
  def spec &block
    it description_from(*block.source_location), &block
  end

  # reads description line from source file and drops external brackets (like its{}, use{}
  def description_from(file, line)
    File.open(file) do |f|
      f.lines.to_a[line-1].gsub(/(spec.*?{)|(use.*?{)|}/, '').strip
    end
  end
end

RSpec.configure { |config|
  config.include Win::Gui # This is a namespace from win gem.
  config.include WinGui # This is our own main namespace. TODO: looks confusing... better names?
  config.extend SpecMacros }


# Test related Constants:
TIMEOUT          = 0.001
KEY_DELAY        = 0.001
SLEEP_DELAY      = 0.01
APP_PATH         = File.join(File.dirname(__FILE__), "../misc/locknote/LockNote.exe")
DIALOG_TITLE     = "Save As"
WIN_TITLE        = 'LockNote - Steganos LockNote'
WIN_CLASS        = 'ATL:00434098'
TEXTAREA_CLASS   = 'ATL:00434310'
STATUSBAR_CLASS  = 'msctls_statusbar32'
IMPOSSIBLE       = 'Impossible'
ERROR_CONVERSION = /Can.t convert/

# Helper methods:
def use
  lambda { yield }.should_not raise_error
end

def any_handle
  find_window(nil, nil)
end

def not_a_handle
  123
end

def any_block
  lambda { |*args| args }
end

def launch_test_app
  #system APP_START
  @test_app = App.launch(path: APP_PATH, title: WIN_TITLE, timeout: 1)
end

def close_test_app
  while @test_app && @test_app.main_window.window?
    @test_app.close
    # Dealing with closing confirmation modal dialog
    if dialog = dialog(title: "Steganos Locknote", timeout: SLEEP_DELAY)
      dialog.set_foreground_window
      keystroke("N")
    end
  end
  @test_app = nil
end

# Creates test app object and yields it back to the block
def test_app
  yield launch_test_app
  close_test_app
end

def with_dialog(type=:close)
  case type
    when :close
      keystroke('A')
      @app.close
      title, key = "Steganos Locknote", "N"
    when :save
      keystroke(VK_ALT, 'F', 'A')
      title, key = "Save As", VK_ESCAPE
  end
  sleep 0.01 until dialog = Window.top_level(title: title)
  yield dialog
  while dialog.window?
    dialog.set_foreground_window
    keystroke(key)
    sleep 0.01
  end
end
