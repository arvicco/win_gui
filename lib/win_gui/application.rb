module WinGui

  # This class is a wrapper around Windows App
  class App
    LAUNCH_TIMEOUT = 0.2

    attr_accessor :main_window # Main App window (top level)

    def initialize(window_or_handle)
      @main_window = case window_or_handle
        when Window
          window_or_handle
        when Integer
          Window.new window_or_handle
        else
          raise WinGui::Errors::InitError, "Unable to create App from #{window_or_handle.inspect}"
      end
    end

    # Exits application (optionally waiting _timeout_ seconds for main window to close)
    def close(wait_timeout=nil)
      @main_window.close
      if wait_timeout
        timeout(wait_timeout) do
          sleep SLEEP_DELAY while @main_window.window?
        end
      end
#      @main_window.wait_for_close(timeout) if timeout
    end
    alias_method :exit, :close

    class << self
      # Finds already launched Application. Either title or class for main window is obligatory.
      # Returns nil if no such Application found.
      # Options:
      # :title:: main window title
      # :class:: main window class
      # :timeout:: timeout (seconds) finding main window
      # :raise:: raise this exception instead of returning nil if nothing found
      #
      def find(opts)
        opts[:logger].debug "Inside find" if opts[:logger]
        main_window = Window.top_level(opts)
        opts[:logger].debug "Almost found" if opts[:logger]
        main_window ? new(main_window) : nil
      end

      # Launch new Application. Expects executable path and options to find main Window.
      # Options:
      # :path/:app_path:: path to App's executable file
      # :dir/:cd:: change to this dir before launching App
      # :title:: main window title
      # :class:: main window class
      # :timeout:: timeout (seconds) finding main window
      # :raise:: raise this exception instead of returning nil if launched app window not found
      #
      def launch(opts)
        app_path = opts.delete(:path) || opts.delete(:app_path)
        dir_path = opts.delete(:dir) || opts.delete(:cd)

        opts[:logger].debug "Inside launch" if opts[:logger]
        launch_app app_path, dir_path, opts[:logger]
        opts[:logger].debug "App launched" if opts[:logger]

        defaults = {timeout: LAUNCH_TIMEOUT,
                    raise: WinGui::Errors::InitError.new("Unable to launch App with #{opts.inspect}")}
        opts[:logger].debug "Trying to find" if opts[:logger]
        find(defaults.merge opts)
        opts[:logger].debug "App launched" if opts[:logger]
      end

      private

      def cygwin?
        RUBY_PLATFORM =~ /cygwin/
      end

      def launch_app(app_path, dir_path, logger=nil)

        raise WinGui::Errors::InitError, "Unable to launch #{app_path.inspect}" unless File.exists? app_path.to_s
        command = cygwin? ? "cmd /c start `cygpath -w #{app_path}`" : "start #{app_path.to_s.gsub(/\//, "\\")}"

        if dir_path
          raise WinGui::Errors::InitError, "Unable to change to #{dir_path.inspect}" unless File.exists? dir_path.to_s
          command = "cd #{cygwin? ? dir_path : dir_path.to_s.gsub(/\//, "\\")} && #{command}"
        end

        # Launch App in a separate window
        logger.debug "launch_app #{__LINE__} cmd: #{command}" if logger
        system command  # TODO: make sure only valid commands are fed into system
        logger.debug "launch_app #{__LINE__} after system" if logger
      end

    end
  end
end