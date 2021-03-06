module WinGui

  # This class is a wrapper around window handle
  class Window

    def initialize(handle)
      @handle = handle
    end

    attr_reader :handle

    class << self
      # Looks up window handle using code specified in attached block (either with or without :timeout).
      # Returns either Window instance (for a found handle) or nil if nothing found.
      # Private method to dry up other window lookup methods
      #
      def lookup_window opts # :yields: index, position
        # Need this to avoid handle considered local var in begin..end block
        handle = yield
        if opts[:timeout]
          begin
            timeout(opts[:timeout]) do
              sleep SLEEP_DELAY until handle = yield
            end
          rescue Timeout::Error
            nil
          end
        end
        raise opts[:raise] if opts[:raise] && !handle
        Window.new(handle) if handle
      end

      def lookup_window_in_collection opts, &collection_proc
        class_name   = opts[:class]
        title        = opts[:title]
        id           = opts[:id]
        class_regexp = class_name.is_a? Regexp
        title_regexp = title.is_a? Regexp

        lookup_window(opts) do
          collection_proc.call.each do |handle|
            win         = Window.new handle

            id_match    = !id || win.id == id
            title_match = !title || win.title == title ||
                title_regexp && win.title =~ title
            class_match = !class_name || win.class_name == class_name ||
                class_regexp && win.class_name =~ class_name
            return win if class_match && title_match && id_match
          end
          nil
        end
      end

      # Finds top level window by title/class, returns wrapped Window object or nil (raises exception if asked to).
      # If timeout option given, waits for window to appear within timeout, returns nil if it didn't.
      # Options:
      # :title:: window title (String or Regexp)
      # :class:: window class (String or Regexp)
      # :timeout:: timeout (seconds)
      # :raise:: raise this exception instead of returning nil if nothing found
      #
      def top_level opts={}
        if opts[:class].is_a?(Regexp) || opts[:title].is_a?(Regexp)
          lookup_window_in_collection(opts) { WinGui.enum_windows }
        else
          lookup_window(opts) { WinGui.find_window opts[:class], opts[:title] }
        end
      end

      alias find top_level
    end

    # Finds child window (control) by either control ID or window class/title.
    # By default, only direct children are searched.
    # Options:
    # :id:: integer control id (such as IDOK, IDCANCEL, etc)
    # :title:: window title (String or Regexp)
    # :class:: window class (String or Regexp)
    # :indirect:: search all descendants, not only direct children
    # :timeout:: timeout (seconds)
    # :raise:: raise this exception instead of returning nil if nothing found
    #
    def child(opts={})
      if opts[:indirect]
        self.class.lookup_window_in_collection(opts) { enum_child_windows }
      elsif opts[:class].is_a?(Regexp) || opts[:title].is_a?(Regexp)
        self.class.lookup_window_in_collection(opts) do
          enum_child_windows.select { |handle| child? handle }
        end
      else
        self.class.lookup_window opts do
          opts[:id] ? get_dlg_item(opts[:id]) : find_window_ex(0, opts[:class], opts[:title])
        end
      end
    end

    # Returns array of Windows that are descendants (not only DIRECT children) of a given Window
    #
    def children
      enum_child_windows.map { |child_handle| Window.new child_handle }
    end

    # Emulates click of the control identified by opts (:id, :title, :class).
    # Beware of keyboard shortcuts in button titles! So, use "&Yes" instead of just "Yes".
    # Returns screen coordinates of click point if successful, nil if control was not found
    # :id:: integer control id (such as IDOK, IDCANCEL, etc)
    # :title:: window title
    # :class:: window class
    # :raise:: raise this exception instead of returning nil if nothing found
    # :position/point/where:: location where the click is to be applied - default :center
    # :mouse_button/button/which:: mouse button which to click - default :right
    #
    def click(opts={})
      control = child(opts)
      if control
        left, top, right, bottom = control.get_window_rect

        where = opts[:point] || opts[:where] || opts[:position]
        point = case where
                  when Array
                    where # Explicit screen coords
                  when :random
                    [left + rand(right - left), top + rand(bottom - top)] # Random point within control window
                  else
                    [(left + right) / 2, (top + bottom) / 2] # Center of a control window
                end

        WinGui.set_cursor_pos *point

        button = opts[:mouse_button] || opts[:mouse] || opts[:which]
        down, up = (button == :right) ?
            [WinGui::MOUSEEVENTF_RIGHTDOWN, WinGui::MOUSEEVENTF_RIGHTUP] :
            [WinGui::MOUSEEVENTF_LEFTDOWN, WinGui::MOUSEEVENTF_LEFTUP]

        WinGui.mouse_event down, 0, 0, 0, 0
        WinGui.mouse_event up, 0, 0, 0, 0
        point
      else
        nil
      end
    end

    # Waits for this window to close with timeout (default CLOSE_TIMEOUT).
    #
    def wait_for_close(timeout=CLOSE_TIMEOUT)
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

    # Alias for [get_]window_text
    #
    def title
      get_window_text
    end

    def thread
      get_window_thread_process_id.first
    end

    def process
      get_window_thread_process_id.last
    end

    alias pid process

    # Control ID associated with the window (only makes sense for controls)
    def id
      get_dlg_ctrl_id
    end

    # Since Window instances wrap actual window handles, they should directly support Win32 API functions
    # manipulating these handles. Therefore, when unsupported instance method is invoked, we check if
    # WinGui responds to such method, and if yes, call it with our window handle as a first argument.
    # This gives us all handle-related WinGui functions as instance methods for Window instances, like so:
    #   window.visible?
    # This API is much more Ruby-like compared to:
    #   visible?(window.handle)
    # Of course, if we invoke WinGui function that DOESN'T accept handle as a first arg this way, we are screwed.
    # Call such functions only like this:
    #   WinGui.function(*args)
    # TODO: Such setup is problematic if WinGui is included into Window ancestor chain.
    # TODO: In this case, all WinGui functions become available as instance methods, and method_missing never fires.
    # TODO: It may be a better solution to explicitly define all needed instance methods,
    # TODO: instead of showing off cool meta-programming skillz. ;-)
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