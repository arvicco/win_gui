require 'Win32/api'

module WinGui
  module DefApi
    # DLL to use with API decarations by default ('user32')
    DEFAULT_DLL = 'user32'

    # Defines new method wrappers for Windows API function call:
    #   - Defines method with original (CamelCase) API function name and original signature (matches MSDN description)
    #   - Defines method with snake_case name (converted from CamelCase function name) with enhanced API signature
    #       When the defined wrapper method is called, it checks the argument count, executes underlying API
    #       function call and (optionally) transforms the result before returning it. If block is attached to
    #       method invocation, raw result is yielded to this block before final transformations
    #   - Defines aliases for enhanced method with more Rubyesque names for getters, setters and tests:
    #       GetWindowText -> window_test, SetWindowText -> window_text=, IsZoomed -> zoomed?
    #
    # You may modify default behavior of defined method by providing optional &define_block to def_api.
    #   If you do so, instead of directly calling API function, defined method just yields callable api
    #   object, arguments and (optional) runtime block to your &define_block and returns result coming out of it.
    #   So, &define_block should define all the behavior of defined method. You can use define_block to:
    #   - Change original signature of API function, provide argument defaults, check argument types
    #   - Pack arguments into strings for [in] or [in/out] parameters that expect a pointer
    #   - Allocate string buffers for pointers required by API functions [out] parameters
    #   - Unpack [out] and [in/out] parameters returned as pointers
    #   - Explicitly return results of API call that are returned in [out] and [in/out] parameters
    #   - Convert attached runtime blocks into callback functions and stuff them into [in] callback parameters
    #
    # Accepts following options:
    #   :dll:: Use this dll instead of default 'user32'
    #   :rename:: Use this name instead of standard (conventional) function name
    #   :alias(es):: Provides additional alias(es) for defined method
    #   :boolean:: Forces method to return true/false instead of nonzero/zero
    #   :zeronil:: Forces method to return nil if function result is zero
    #
    def def_api(function, params, returns, options={}, &define_block)
      aliases = ([options[:alias]] + [options[:aliases]]).flatten.compact
      name = options[:rename] || function.snake_case
      case name
        when /^is_/
          aliases << name.sub(/^is_/, '') + '?'
          boolean = true
        when /^set_/
          aliases << name.sub(/^set_/, '')+ '='
        when /^get_/
          aliases << name.sub(/^get_/, '')
      end
      boolean ||= options[:boolean]
      zeronil = options[:zeronil]
      proto = params.respond_to?(:join) ? params.join : params # Converts params into prototype string
      api = Win32::API.new(function, proto.upcase, returns.upcase, options[:dll] || DEFAULT_DLL)

      define_method(function) {|*args| api.call(*args)} # defines CamelCase method wrapper for api call

      define_method(name) do |*args, &runtime_block|    # defines snake_case method with enhanced api
        return api if args == [:api]
        return define_block.call(api, *args, &runtime_block) if define_block
        unless args.size == params.size
          raise ArgumentError, "wrong number of parameters: expected #{params.size}, got #{args.size}"
        end  
        result = api.call(*args)
        result = runtime_block[result] if runtime_block
        return result != 0 if boolean       # Boolean function returns true/false instead of nonzero/zero
        return nil if zeronil && result == 0
        result
      end
      aliases.each {|ali| alias_method ali, name } unless aliases == []
    end

    # Converts block into API::Callback object that can be used as API callback argument
    #
    def callback(params, returns, &block)
      Win32::API::Callback.new(params, returns, &block)
    end

    private  # Helper methods:

    # Returns string buffer - used to supply string pointer reference to API functions
    #
    def buffer(size = 1024, code = "\x00")
      code * size
    end

    # Procedure that returns (possibly encoded) string as a result of api function call
    # or nil if zero characters was returned by api call
    #
    def return_string( encode = nil )
      lambda do |api, *args|
      num_params = api.prototype.size-2
      unless args.size == num_params
        raise ArgumentError, "wrong number of parameters: expected #{num_params}, got #{args.size}"
      end
        args += [string = buffer, string.length]
        num_chars = api.call(*args)
        return nil if num_chars == 0
        string = string.force_encoding('utf-16LE').encode(encode) if encode
        string.rstrip
      end
    end

    # Procedure that calls api function expecting a callback. If runtime block is given
    # it is converted into callback, otherwise procedure returns an array of all handles
    # pushed into callback by api enumeration
    #
    def return_enum
      lambda do |api, *args, &block|
        num_params = api.prototype.size-1
        unless args.size == num_params
          raise ArgumentError, "wrong number of parameters: expected #{num_params}, got #{args.size}"
        end
        handles = []
        cb = if block
          callback('LP', 'I', &block)
        else
          callback('LP', 'I') do |handle, message|
            handles << handle
            true
          end
        end
        args[api.prototype.find_index('K'), 0] = cb # Insert callback into appropriate place of args Array
        api.call *args
        handles
      end
    end

    # Procedure that calls (DdeInitialize) function expecting a DdeCallback. Runtime block is converted
    # into Dde callback and registered with DdeInitialize. Returns DDE init status and DDE instance id.
    #
    # TODO: Pushed into this module since RubyMine (wrongly) reports error on lambda args
    #
    def return_id_status
      lambda do |api, id=0, cmd, &block|
        raise ArgumentError, 'No callback block' unless block
        callback = callback 'IIPPPPPP', 'L', &block
        id = [id].pack('L')

        status = api.call(id, callback, cmd, 0)
        [*id.unpack('L'), status]
      end
    end

  end
end