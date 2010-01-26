module WinGui
  module DefApi
    DEFAULT_DLL = 'user32'

    # Defines new instance method wrapper for Windows API function call. Converts CamelCase function name
    # into snake_case method name, renames test functions according to Ruby convention (IsWindow -> window?)
    # When the defined wrapper method is called, it executes underlying API function call, yields the result
    # to attached block (if any) and (optionally) transforms the result before returning it.
    #
    # You may modify default defined method behavior by providing optional &define_block to def_api.
    # If you do so, instead of directly calling API function, defined method yields callable api object, arguments
    # and (optional) runtime block to &define_block that should define method content and return result.
    #
    # Accepts following options:
    # :dll:: Use this dll instead of default 'user32'
    # :rename:: Use this name instead of standard (conventional) function name
    # :alias(es):: Provides additional alias(es) for defined method
    # :boolean:: Forces method to return true/false instead of nonzero/zero
    # :zeronil:: Forces method to return nil if function result is zero
    #
    def def_api(function, params, returns, options={}, &define_block)
      name = options[:rename] || function.snake_case
      if name.sub!(/^is_/, '')
        name << '?'
        boolean = true
      end
      boolean ||= options[:boolean]
      zeronil = options[:zeronil]
      aliases = ([options[:alias]] + [options[:aliases]]).flatten.compact
      proto = params.respond_to?(:join) ? params.join : params # Converts params into prototype string
      api = Win32::API.new(function, proto.upcase, returns.upcase, options[:dll] || DEFAULT_DLL)

      define_method(name) do |*args, &runtime_block|
        return api if args == [:api]
        return define_block.call(api, *args, &runtime_block) if define_block
        raise 'Invalid args count' unless args.size == params.size
        result = api.call(*args)
        yield result if runtime_block
        return result != 0 if boolean       # Boolean function returns true/false instead of nonzero/zero
        return nil if zeronil && result == 0
        result
      end
      aliases.each {|aliass| alias_method aliass, name } unless aliases == []
    end

    # Helper methods:

    # Converts block into API::Callback object that can be used as API callback argument
    def callback(params, returns, &block)
      Win32::API::Callback.new(params, returns, &block)
    end

    # Returns string buffer - used to supply string pointer reference to API functions
    def buffer(size = 1024, code = "\x00")
      code * size
    end

    # Procedure that returns (possibly encoded) string as a result of api function call
    def return_string( encode = nil )
      lambda do |api, *args|
        raise 'Invalid args count' unless args.size == api.prototype.size-2
        args += [string = buffer, string.length]
        num_chars = api.call(*args) # num_chars not used
        string = string.force_encoding('utf-16LE').encode(encode) if encode
        string.rstrip
      end
    end

    # Procedure that calls api function expecting a callback. If runtime block is given
    # it is converted into callback, otherwise procedure returns an array of all handles
    # pushed into callback by api enumeration
    def return_enum
      lambda do |api, *args, &block|
        raise 'Invalid args count' unless args.size == api.prototype.size-1
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

  end
end