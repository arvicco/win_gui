require 'spec'
require 'spec/autorun'
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
      f.lines.to_a[line-1].gsub( /(spec.*?{)|(use.*?{)|}/, '' ).strip
    end
  end
end

Spec::Runner.configure { |config| config.extend(SpecMacros) }

module WinGuiTest
  include Win::Gui  # This is a namespace from win gem.
  include WinGui    # This is our own main namespace. TODO: looks confusing... better names?

  # Test related Constants:
  TIMEOUT = 0.001
  KEY_DELAY = 0.001
  SLEEP_DELAY = 0.01
  APP_PATH = File.join(File.dirname(__FILE__), "../misc/locknote/LockNote.exe" )
  APP_START = RUBY_PLATFORM =~ /cygwin/ ? "cmd /c start `cygpath -w #{APP_PATH}`" : "start #{APP_PATH}"
  #          'start "" "' + APP_PATH + '"'
  DIALOG_TITLE = "Save As"
  WIN_TITLE = 'LockNote - Steganos LockNote'
  WIN_CLASS = 'ATL:00434098'
  WIN_RECT = [710, 400, 1210, 800]
  MAX_RECT = [-4, -4, 1924, 1204]  # on my 1920x1200 display
  MIN_RECT = [-32000, -32000, -31840, -31976]
  TEXTAREA_CLASS = 'ATL:00434310'
  STATUSBAR_CLASS = 'msctls_statusbar32'
  IMPOSSIBLE = 'Impossible'
  ERROR_CONVERSION = /Can.t convert/

  # Helper methods:
  def use
    lambda {yield}.should_not raise_error
  end

  def any_handle
    find_window(nil, nil)
  end

  def not_a_handle
    123
  end

  def any_block
    lambda {|*args| args}
  end

  def launch_test_app
    system APP_START
    @test_app = Window.top_level( title: WIN_TITLE, timeout: 10)

    def @test_app.textarea #define singleton method retrieving app's text area
      Window.new WinGui::find_window_ex(self.handle, 0, TEXTAREA_CLASS, nil)
    end

    @test_app
  end

  def close_test_app
    while @test_app && find_window(nil, WIN_TITLE)
      @test_app.close
      # Dealing with closing confirmation modal dialog
      if dialog = dialog( title: "Steganos Locknote", timeout: SLEEP_DELAY)
        dialog.set_foreground_window
        keystroke("N")
      end
    end
    @test_app = nil
  end

  # Creates test app object and yields it back to the block
  def test_app
    test_app = launch_test_app
    yield test_app
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
end
