require 'win/gui'

# Module contains Win32 API gui-related functions as both module and instance methods.
# See documentation of Win::Gui module of *win* gem for a full scope of available functions.
# In addition, module defines several higher-level convenience methods that can be useful
# when dealing with GUI-related tasks under windows (such as testing automation).
#
module WinGui
  include Win::Gui
  extend Win::Gui

  # Delay between key commands/events (in sec)
  KEY_DELAY = 0.00001
  # Delay when sleeping (in sec)
  SLEEP_DELAY = 0.001
  # Timeout waiting for Window to be closed (in sec)
  CLOSE_TIMEOUT = 1
  # Default timeout for dialog operations (in sec)
  LOOKUP_TIMEOUT = 3

  # Windows class identifying standard modal dialog window
  DIALOG_WINDOW_CLASS = '#32770'

  # Module defines convenience methods on top of straightforward Win32 API functions:

  # Finds top-level dialog window by title and yields found dialog window to attached block.
  # We work with dialog window in a block, and then we wait for it to close before proceeding.
  # That is, unless your block returns nil, in which case dialog is ignored (and method immediately returns nil?).
  # If no block is given, method just returns found dialog window (or nil if dialog is not found).
  # Options:
  # :title:: dialog title
  # :class:: dialog class - default DIALOG_WINDOW_CLASS
  # :timeout:: timeout (seconds) - default LOOKUP_TIMEOUT (3)
  # :raise:: raise this exception instead of returning nil if nothing found
  #
  def dialog(opts={})  # :yields: dialog_window
    dialog = Window.top_level( {class: DIALOG_WINDOW_CLASS, timeout: LOOKUP_TIMEOUT}.merge opts )
    dialog.set_foreground_window if dialog
    wait = block_given? ? yield(dialog) : false
    dialog.wait_for_close if dialog && wait
    dialog
  end

  # Emulates combinations of (any amount of) keys pressed one after another (Ctrl+Alt+P) and then released.
  # *keys should be a sequence of a virtual-key codes (value in the range 1 to 254).
  # For a complete list, see msdn:Virtual Key Codes.
  # If alphanumerical char is given instead of virtual key code, only lowercase letters result (no VK_SHIFT!).
  #
  def keystroke(*keys)
    return if keys.empty?
    key = String === keys.first ? keys.first.upcase.ord : keys.first.to_i
    keybd_event key, 0, KEYEVENTF_KEYDOWN, 0
    sleep KEY_DELAY
    keystroke *keys[1..-1]
    sleep KEY_DELAY
    keybd_event key, 0, KEYEVENTF_KEYUP, 0
  end

  # Types text message into a window currently holding the focus
  #
  def type_in(message)
    message.scan(/./m) do |char|
      keystroke(*char.to_key)
    end
  end
end
