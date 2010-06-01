module WinGui

  # This class is a wrapper around window handle
  class Window
    # Make convenience methods from both WinGui and Win::Gui available as both class and instance methods
    # Looks a bit circular though...
    include WinGui
    extend WinGui

    def initialize(handle)
      @handle = handle
    end

    attr_reader :handle

    # Finds top level window by title/class, returns wrapped Window object or nil.
    # If timeout option given, waits for window to appear within timeout, returns nil if it didn't
    # Options:
    # :title:: window title
    # :class:: window class
    # :timeout:: timeout (seconds)
    def self.top_level(opts={})
      window_title = opts[:title]
      window_class = opts[:class]
      timeout = opts[:timeout] # || LOOKUP_TIMEOUT ? # no timeout by default

      if timeout
        begin
          timeout(timeout) do
            sleep SLEEP_DELAY while (@handle = find_window window_class, window_title) == nil
          end
        rescue TimeoutError
          nil
        end
      else
        @handle = find_window window_class, window_title
      end
      Window.new(@handle) if @handle
    end

    # find child window (control) by title, window class, or control ID:
    def child(id)
      result = case id
        when String
          by_title = find_window_ex @handle, 0, nil, id.gsub('_', '&' )
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

    # returns array of Windows that are descendants (not only DIRECTchildren) of a given Window
    def children
      enum_child_windows(@handle).map{|child_handle| Window.new child_handle}
    end

    # emulate click of the control identified by id
    def click(id)
      left, top, right, bottom = get_window_rect child(id).handle
      center = [(left + right) / 2, (top + bottom) / 2]
      set_cursor_pos *center
      mouse_event MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0
      mouse_event MOUSEEVENTF_LEFTUP, 0, 0, 0, 0
    end

    def close
      post_message @handle, WM_SYSCOMMAND, SC_CLOSE, nil
    end

    def wait_for_close
      timeout(CLOSE_TIMEOUT) do
        sleep SLEEP_DELAY while window_visible?(@handle)
      end
    end

    # Window class name property - static (not changing)
    def class_name
      @class_name ||= get_class_name @handle
    end

    # Window text/title property - dynamic (changing)
    def text
      buffer = FFI::MemoryPointer.from_string("\x0" * 2048)
      num_chars = send_message @handle, WM_GETTEXT, buffer.size, buffer # length?
      num_chars == 0 ? '' : buffer.read_string
    end
  end
end