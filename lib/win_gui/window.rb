module WinGui

  # This class is a wrapper around window handle
  class Window
    # Make convenience methods from both WinGui and Win::Gui available as both class and instance methods
    # Looks a bit circular though...
#    include WinGui
#    extend WinGui

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
            sleep SLEEP_DELAY while (@handle = WinGui.find_window window_class, window_title) == nil
          end
        rescue TimeoutError
          nil
        end
      else
        @handle = WinGui.find_window window_class, window_title
      end
      Window.new(@handle) if @handle
    end

    # find child window (control) by title, window class, or control ID:
    def child(id)
      result = case id
        when String
          by_title = find_window_ex 0, nil, id.gsub('_', '&' )
          by_class = find_window_ex 0, id, nil
          by_title ? by_title : by_class
        when Fixnum
          get_dlg_item id
        when nil
          find_window_ex 0, nil, nil
        else
          nil
      end
      raise "Control '#{id}' not found" unless result
      Window.new result
    end

    # returns array of Windows that are descendants (not only DIRECTchildren) of a given Window
    def children
      enum_child_windows.map{|child_handle| Window.new child_handle}
    end

    # emulate click of the control identified by id
    def click(id)
      left, top, right, bottom = WinGui.get_window_rect child(id).handle
      center = [(left + right) / 2, (top + bottom) / 2]
      WinGui.set_cursor_pos *center
      WinGui.mouse_event WinGui::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0
      WinGui.mouse_event WinGui::MOUSEEVENTF_LEFTUP, 0, 0, 0, 0
    end

    def wait_for_close
      timeout(CLOSE_TIMEOUT) do
        sleep SLEEP_DELAY while window_visible?
      end
    end

    # We alias convenience method shut_window (from Win::Gui::WIndow) with even more convenient
    #   window.close
    # Please keep in mind that Win32 API has another function CloseWindow that merely MINIMIZES window.
    # If you want to invoke this function, you can do it like this:
    #   window.close_window
    def close
      shut_window
    end

    # Since Window instances wrap actual window handles, they should support WinGui functions
    # manipulating these handles. Therefore, when unsupported instance method is invoked, we check if
    # WinGui responds to such method, and if yes, call it with our window handle as a first argument.
    # This gives us all handle-related WinGui functions as instance methods for Window instances, like so:
    #   window.visible?
    # This API is much more Ruby-like compared to:
    #   visible?(window.handle)
    # Of course, if we unvoke WinGui function that DOESN'T accept handle as a first arg this way, we are screwed.
    # Call such functions only like this:
    #   WinGui.function(*args)
    def method_missing(name, *args, &block)
      if WinGui.respond_to? name
         WinGui.send(name, @handle, *args, &block)
      else
        super
      end
    end
  end
end