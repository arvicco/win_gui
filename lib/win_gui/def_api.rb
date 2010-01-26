module WinGui
  module DefApi
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
      api = Win32::API.new(function, proto.upcase, returns.upcase, options[:dll] || WG_DLL_DEFAULT)

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
  end
end