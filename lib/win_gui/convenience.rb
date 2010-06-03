require 'win/gui'

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

  # Window class identifying standard modal dialog window
  DIALOG_WINDOW_CLASS = '#32770'

  # Module defines convenience methods on top of straightforward Win32 API functions:

  # Finds top-level dialog window by title and yields found dialog window to attached block.
  # We work with dialog window in a block, and then we wait for it to close before proceeding.
  # That is, unless your block returns nil, in which case dialog is ignored and method immediately returns nil
  # If no block is given, method just returns found dialog window (or nil if dialog is not found)
  def dialog(title, timeout=LOOKUP_TIMEOUT)
    dialog = Window.top_level(class: DIALOG_WINDOW_CLASS, title: title, timeout: timeout)
    #set_foreground_window dialog.handle if dialog # TODO: Should be converted to d_w.s_f_g call!
    wait = block_given? ? yield(dialog) : false
    dialog.wait_for_close if dialog && wait
    dialog
  end

  # Emulates combinations of (any amount of) keys pressed one after another (Ctrl+Alt+P) and then released
  # *keys should be a sequence of a virtual-key codes. These codes must be a value in the range 1 to 254.
  # For a complete list, see msdn:Virtual Key Codes.
  # If alphanumerical char is given instead of virtual key code, only lowercase letters result (no VK_SHIFT!).
  def keystroke(*keys)
    return if keys.empty?
    key = String === keys.first ? keys.first.upcase.ord : keys.first.to_i
    keybd_event key, 0, KEYEVENTF_KEYDOWN, 0
    sleep KEY_DELAY
    keystroke *keys[1..-1]
    sleep KEY_DELAY
    keybd_event key, 0, KEYEVENTF_KEYUP, 0
  end

  # types text message into a window currently holding the focus
  def type_in(message)
    message.scan(/./m) do |char|
      keystroke(*char.to_key)
    end
  end


#  DialogWndClass = '#32770'
#  def dialog(title, seconds=5)
#    close, dlg = begin
#      sleep 0.25
#      w = Gui.top_level(title, seconds, DialogWndClass)
#      Gui.set_foreground_window w.handle
#      sleep 0.25
#
#      [yield(w), w]
#    rescue TimeoutError
#    end
#
#    dlg.wait_for_close if dlg && close
#    return dlg
#  end

end
