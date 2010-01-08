module WinGui
  class Window
    include WinGui
    extend WinGui
    
    attr_reader :handle
    
    # find top level window by title, return wrapped Window object
    def self.top_level(title, seconds=3)
      @handle = timeout(seconds) do
        sleep WG_SLEEP_DELAY while (h = find_window nil, title) == nil; h
      end
      Window.new @handle
    end  
    
    def initialize(handle)
      @handle = handle
    end
   
    # find child window (control) by title, window class, or control ID:
    def child(id)
      result = case id
        when String
        by_title = find_window_ex @handle, 0, nil, id.gsub('_' , '&' )
        by_class = find_window_ex @handle, 0, id, nil
        by_title ? by_title : by_class
        when Fixnum
        get_dlg_item @handle, id
        when nil
        find_window_ex @handle, 0, nil, nil
      else
        nil
      end
      raise "Control '#{id}' not found" unless result
      Window.new result
    end

    def children
      enum_child_windows(@handle,'Msg').map{|child_handle| Window.new child_handle}
    end

    # emulate click of the control identified by id
    def click(id)
      h = child(id).handle
      rectangle = [0, 0, 0, 0].pack 'LLLL'
      get_window_rect h, rectangle
      left, top, right, bottom = rectangle.unpack 'LLLL'
      center = [(left + right) / 2, (top + bottom) / 2]
      set_cursor_pos *center
      mouse_event MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0
      mouse_event MOUSEEVENTF_LEFTUP, 0, 0, 0, 0
    end
    
    def close
      post_message @handle, WM_SYSCOMMAND, SC_CLOSE, 0
    end
    
    def wait_for_close
      timeout(WG_CLOSE_TIMEOUT) do
        sleep WG_SLEEP_DELAY while window_visible?(@handle) 
      end
    end
    
    def text
      buffer = "\x0" * 2048
      length = send_message @handle, WM_GETTEXT, buffer.length, buffer
      length == 0 ? '' : buffer[0..length - 1]
    end
  end
end