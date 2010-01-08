require 'timeout'
require 'Win32API'

def user32(name, param_types, return_value)
  Win32API.new 'user32', name, param_types, return_value
end

KEYEVENTF_KEYDOWN = 0 
KEYEVENTF_KEYUP = 2 
WM_GETTEXT = 0x000D
IDNO = 7
WM_SYSCOMMAND = 0x0112 
SC_CLOSE = 0xF060
MOUSEEVENTF_LEFTDOWN = 0x0002 
MOUSEEVENTF_LEFTUP = 0x0004

class Note
  def initialize
    find_window = user32 'FindWindow', ['P', 'P'], 'L'
    system 'start "" "C:/Dev/apps/gui_testing/lib/win/locknote/LockNote.exe"'
    sleep 0.2 while (@main_window = find_window.call nil, 'LockNote - Steganos LockNote') <= 0
    #type_in 'aaaaabc'
  end
  
  def type_in(text)
    keybd_event = user32 'keybd_event', ['I', 'I', 'L', 'L'], 'V'
    text.upcase.each_byte do |b| # upcase needed since user32 keybd_event expects upper case chars 
      keybd_event.call b, 0, KEYEVENTF_KEYDOWN, 0 
      sleep 0.05 
      keybd_event.call b, 0, KEYEVENTF_KEYUP, 0 
      sleep 0.05 
    end 
  end
  
  def text
    find_window_ex = user32 'FindWindowEx' , ['L' , 'L' , 'P' , 'P' ], 'L'
    send_message = user32 'SendMessage' , ['L' , 'L' , 'L' , 'P' ], 'L'
    edit = find_window_ex.call @main_window, 0, 'ATL:00434310' , nil
    buffer = "\x0" * 2048
    send_message.call edit, WM_GETTEXT, buffer.length, buffer
    return buffer
  end
  
  def exit!
    begin
      post_message = user32 'PostMessage', ['L', 'L', 'L', 'L'], 'L'
      find_window = user32 'FindWindow', ['P', 'P'], 'L'
      get_dlg_item = user32 'GetDlgItem', ['L', 'L'], 'L' 
      get_window_rect = user32 'GetWindowRect', ['L', 'P'], 'I' 
      set_cursor_pos = user32 'SetCursorPos', ['L', 'L'], 'I' 
      mouse_event = user32 'mouse_event', ['L', 'L', 'L', 'L', 'L'], 'V' 
      
      post_message.call @main_window, WM_SYSCOMMAND, SC_CLOSE, 0 
      
      sleep 0.2    # You might need a slight delay here.
      
      dialog = timeout(3) do                    #(4)
        sleep 0.2 while (h = find_window.call nil, 'Steganos LockNote') <= 0; h
      end
      
      button = get_dlg_item.call dialog, IDNO 
      
      rectangle = [0, 0, 0, 0].pack 'L*'
      get_window_rect.call button, rectangle 
      left, top, right, bottom = rectangle.unpack 'L*'
      center = [(left + right) / 2, (top + bottom) / 2]

      set_cursor_pos.call *center #(7)
      mouse_event.call MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0 
      mouse_event.call MOUSEEVENTF_LEFTUP, 0, 0, 0, 0 
      
      @prompted = true
    rescue
    end
  end
  
  def has_prompted?
    @prompted
  end
end