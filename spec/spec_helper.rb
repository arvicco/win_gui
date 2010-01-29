lib_dir = File.join(File.dirname(__FILE__), "..", "lib" )
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)
require 'spec'
require 'win_gui'
require 'note'

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

module GuiTest
  include WinGui

  # Test related Constants:
  TEST_TIMEOUT = 0.001
  TEST_KEY_DELAY = 0.001
  TEST_SLEEP_DELAY = 0.01
  TEST_APP_PATH = File.join(File.dirname(__FILE__), "test_apps/locknote/LockNote.exe" )
  TEST_APP_START = 'start "" "' + TEST_APP_PATH + '"'
  TEST_WIN_TITLE = 'LockNote - Steganos LockNote'
  TEST_WIN_CLASS = 'ATL:00434098'
  TEST_WIN_RECT = [710, 400, 1210, 800]
  TEST_MAX_RECT = [-4, -4, 1924, 1204]  # on my 1920x1200 display
  TEST_MIN_RECT = [-32000, -32000, -31840, -31976]
  TEST_TEXTAREA_CLASS = 'ATL:00434310'
  TEST_IMPOSSIBLE = 'Impossible'
  TEST_ERROR_CONVERSION = /Can.t convert/

  # Helper methods:
  def use
    lambda {yield}.should_not raise_error
  end

  def any_handle
    WinGui.def_api 'FindWindow', 'PP', 'L' unless respond_to? :find_window
    find_window(nil, nil)
  end

  def not_a_handle
    123
  end

  def any_block
    lambda {|*args| args}
  end

  def hide_method(*names) # hide original method(s) if it is defined
    names.each do |name|
      WinGui.module_eval do
        if method_defined? name.to_sym
          alias_method "orig_#{name.to_s}".to_sym, name.to_sym
          remove_method name.to_sym
        end
      end
    end
  end

  def restore_method(*names) # restore original method if it was hidden
    names.each do |name|
      WinGui.module_eval do
        temp = "orig_#{name.to_s}".to_sym
        if method_defined? temp
          alias_method name.to_sym, temp
          remove_method temp
        end
      end
    end
  end

  def launch_test_app
    system TEST_APP_START
    sleep TEST_SLEEP_DELAY until (handle = find_window(nil, TEST_WIN_TITLE))
    @launched_test_app = Window.new handle
  end

  def close_test_app(app = @launched_test_app)
    while app and app.respond_to? :handle and find_window(nil, TEST_WIN_TITLE)
      post_message(app.handle, WM_SYSCOMMAND, SC_CLOSE, 0)
      sleep TEST_SLEEP_DELAY
    end
    @launched_test_app = nil
  end

  # Creates test app object and yields it back to the block
  def test_app
    app = launch_test_app

    def app.textarea #define singleton method retrieving app's text area
      Window.new find_window_ex(self.handle, 0, TEST_TEXTAREA_CLASS, nil)
    end

    yield app
    close_test_app
  end

end
