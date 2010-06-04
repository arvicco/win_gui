module WinGui

  # This class is a wrapper around window handle
  class Window

    def initialize(handle)
      @handle = handle
#      puts "Window #{handle} created "
#      p self.class.ancestors
    end

    attr_reader :handle

    # Looks up window handle using code specified in attached block (either with or without :timeout).
    # Returns either Window instance (for a found handle) or nil if nothing found.
    # Private method to dry up other window lookup methods
    #
    def self.lookup_window(opts) # :yields: index, position
      # Need this to avoid handle considered local in begin..end block
      handle = yield
      if opts[:timeout]
        begin
          timeout(opts[:timeout]) do
            sleep SLEEP_DELAY until handle = yield
          end
        rescue TimeoutError
          nil
        end
      end
      raise opts[:raise] if opts[:raise] && !handle
      Window.new(handle) if handle
    end

    # Finds top level window by title/class, returns wrapped Window object or nil (raises exception if asked to).
    # If timeout option given, waits for window to appear within timeout, returns nil if it didn't.
    # Options:
    # :title:: window title
    # :class:: window class
    # :timeout:: timeout (seconds)
    # :raise:: raise this exception instead of returning nil if nothing found
    #
    def self.top_level(opts={})
      lookup_window(opts) { WinGui.find_window opts[:class], opts[:title] }
    end

    # Finds DIRECT child window (control) by either control ID or window class/title.
    # Options:
    # :id:: integer control id (such as IDOK, IDCANCEL, etc)
    # :title:: window title
    # :class:: window class
    # :timeout:: timeout (seconds)
    # :raise:: raise this exception instead of returning nil if nothing found
    #
    def child(opts={})
      self.class.lookup_window(opts) do
        opts[:id] ? get_dlg_item(opts[:id]) : find_window_ex(0, opts[:class], opts[:title])
      end
    end

    # Returns array of Windows that are descendants (not only DIRECT children) of a given Window
    #
    def children
      enum_child_windows.map{|child_handle| Window.new child_handle}
    end

    # Emulates click of the control identified by opts (:id, :title, :class)
    # Return true if click was presumably successful, false if it failed (control was not found)
    #
    def click(opts={})
      control = child(opts)
      if control
        left, top, right, bottom = control.get_window_rect
        center = [(left + right) / 2, (top + bottom) / 2]
        WinGui.set_cursor_pos *center
        WinGui.mouse_event WinGui::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0
        WinGui.mouse_event WinGui::MOUSEEVENTF_LEFTUP, 0, 0, 0, 0
        true
      else
        false
      end
    end

    # Waits for this window to close with timeout (default CLOSE_TIMEOUT).
    #
    def wait_for_close(timeout=CLOSE_TIMEOUT )
      timeout(timeout) do
        sleep SLEEP_DELAY while window_visible?
      end
    end

    # We alias convenience method shut_window (from Win::Gui::Window) with even more convenient
    #   window.close
    # Please keep in mind that Win32 API has another function CloseWindow that merely MINIMIZES window.
    # If you want to invoke this function, you can do it like this:
    #   window.close_window
    #
    def close
      shut_window
    end

    # Since Window instances wrap actual window handles, they should directly support Win32 API functions
    # manipulating these handles. Therefore, when unsupported instance method is invoked, we check if
    # WinGui responds to such method, and if yes, call it with our window handle as a first argument.
    # This gives us all handle-related WinGui functions as instance methods for Window instances, like so:
    #   window.visible?
    # This API is much more Ruby-like compared to:
    #   visible?(window.handle)
    # Of course, if we unvoke WinGui function that DOESN'T accept handle as a first arg this way, we are screwed.
    # Call such functions only like this:
    #   WinGui.function(*args)
    # TODO: Such setup is problematic if WinGui is included into Window ancestor chain.
    # TODO: in this case, all WinGui functions become available as instance methods, and method_missing never fires.
    # TODO: it may be a better solution to explicitly define all needed instance methods.
    # TODO: instead of showing off cool meta-programming skillz.
    #
    def method_missing(name, *args, &block)
      if WinGui.respond_to? name
#        puts "Window #{@handle} calling: #{name} #{@handle} #{args} &#{block}"
        WinGui.send(name, @handle, *args, &block)
      else
        super
      end
    end
  end
end