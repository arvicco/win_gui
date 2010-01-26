require File.join(File.dirname(__FILE__), "..", "spec_helper" )

module GuiTest

#  def enum_callback
#    @enum_callback ||= WinGui.callback('LP', 'I'){|handle, message| true }
#  end

  describe WinGui::DefApi, 'defines wrappers for Win32::API functions' do
    before(:each) { hide_method :find_window_w } # hide original method if it is defined
    after(:each) { restore_method :find_window_w } # restore original method if it was hidden

    context 'defining a valid API function' do
      spec{ use{ WinGui.def_api('FindWindowW', 'PP', 'L', :rename => nil, :alias => nil, :boolean => nil, :zeronil => nil, &any_block) }}

      it 'defines new instance method with appropriate name' do
        WinGui.def_api 'FindWindowW', 'PP', 'L'
        respond_to?(:find_window_w).should be_true
      end

      it 'constructs argument prototype from uppercase string' do
        expect { WinGui.def_api 'FindWindowW', 'PP', 'L' }.to_not raise_error
        expect { find_window_w(nil) }.to raise_error 'Invalid args count'
        expect { find_window_w(nil, nil) }.to_not raise_error 'Invalid args count'
      end

      it 'constructs argument prototype from lowercase string' do
        expect { WinGui.def_api 'FindWindowW', 'pp', 'l' }.to_not raise_error
        expect { find_window_w(nil) }.to raise_error 'Invalid args count'
        expect { find_window_w(nil, nil) }.to_not raise_error 'Invalid args count'
      end

      it 'constructs argument prototype from (mixedcase) array' do
        expect { WinGui.def_api 'FindWindowW', ['p', 'P'], 'L' }.to_not raise_error
        expect { find_window_w(nil) }.to raise_error 'Invalid args count'
        expect { find_window_w(nil, nil) }.to_not raise_error 'Invalid args count'
      end

      it 'overrides standard dll name with :dll option' do

        WinGui.def_api 'GetComputerName', ['P', 'P'], 'I', :dll=> 'kernel32'
        sys_name = `echo %COMPUTERNAME%`.strip
        name = " " * 128
        get_computer_name(name, "128")
        name.unpack("A*").first.should == sys_name
      end

      it 'overrides standard name for defined method with :rename option' do
        WinGui.def_api 'FindWindowW', 'PP', 'L', :rename=> 'my_own_find'
        expect {find_window_w(nil, nil)}.to raise_error
        expect {my_own_find(nil, nil)}.to_not raise_error
      end

      it 'adds alias for defined method with :alias option' do
        WinGui.def_api 'FindWindowW', 'PP', 'L', :alias => 'my_own_find'
        expect {find_window_w(nil, nil)}.to_not raise_error
        expect {my_own_find(nil, nil)}.to_not raise_error
      end

      it 'adds aliases for defined method with :aliases option' do
        WinGui.def_api 'FindWindowW', 'PP', 'L', :aliases => ['my_own_find', 'my_own_find1']
        expect {find_window_w(nil, nil)}.to_not raise_error
        expect {my_own_find(nil, nil)}.to_not raise_error
        expect {my_own_find1(nil, nil)}.to_not raise_error
      end

      it 'defined method works properly when called with a valid args' do
        WinGui.def_api 'FindWindowW', 'PP', 'L'
        expect {find_window_w(nil, nil)}.to_not raise_error
      end

      it 'defined method returns expected value when called' do
        WinGui.def_api 'FindWindowW', 'PP', 'L'
        find_window_w(nil, nil).should_not == 0
        find_window_w(nil, TEST_IMPOSSIBLE).should == 0
        find_window_w(TEST_IMPOSSIBLE, nil).should == 0
        find_window_w(TEST_IMPOSSIBLE, TEST_IMPOSSIBLE).should == 0
      end

      it 'defined method enforces the argument count when called' do
        WinGui.def_api 'FindWindowW', 'PP', 'L'
        expect { find_window_w }.to raise_error 'Invalid args count'
        expect { find_window_w(nil) }.to raise_error 'Invalid args count'
        expect { find_window_w('Str') }.to raise_error 'Invalid args count'
        expect { find_window_w([nil, nil]) }.to raise_error 'Invalid args count'
        expect { find_window_w('Str', 'Str', 'Str') }.to raise_error 'Invalid args count'
      end

      it 'returns underlying Win32::API object if defined method is called with (:api) argument ' do
        WinGui.def_api 'FindWindowW', 'PP', 'L'
        expect {@api = find_window_w(:api)}.to_not raise_error
        @api.dll_name.should == 'user32' # The name of the DLL that exports the API function
        @api.effective_function_name.should == 'FindWindowW' # Actual function returned by the constructor: 'GetUserName' ->'GetUserNameA' or 'GetUserNameW'
        @api.function_name.should == 'FindWindowW' # The name of the function passed to the constructor
        @api.prototype.should == ['P', 'P'] # The prototype, returned as an array of characters
      end
    end

    context 'auto-defining Ruby-like boolean methods if API function name starts with "Is_"' do
      before(:each) do
        hide_method :window?
        WinGui.def_api 'IsWindow', 'L', 'L'
      end
      after(:each) { restore_method :window? }

      it 'defines new instance method name dropping Is_ and adding ?' do
        respond_to?(:window?).should be_true
      end

      it 'defined method returns false/true instead of zero/non-zero' do
        window?(any_handle).should == true
        window?(not_a_handle).should == false
      end

      it 'defined method enforces the argument count' do
        expect {window?}.to raise_error 'Invalid args count'
        expect {window?(not_a_handle, nil)}.to raise_error 'Invalid args count'
        expect {window?(nil, nil)}.to raise_error 'Invalid args count'
      end
    end

    context 'defining API with :boolean option converts result to boolean' do
      before(:each) do
        WinGui.def_api 'FindWindowW', 'PP', 'L', :boolean => true
      end

      it 'defines new instance method' do
        respond_to?(:find_window_w).should be_true
      end

      it 'defined method returns false/true instead of zero/non-zero' do
        find_window_w(nil, nil).should == true
        find_window_w(nil, TEST_IMPOSSIBLE).should == false
      end

      it 'defined method enforces the argument count' do
        expect {find_window_w}.to raise_error 'Invalid args count'
        expect {find_window_w(nil, nil, nil)}.to raise_error 'Invalid args count'
      end
    end

    context 'defining API with :zeronil option converts zero result to nil' do
      before(:each) do
        WinGui.def_api 'FindWindowW', 'PP', 'L', :zeronil => true
      end

      it 'defines new instance method' do
        respond_to?(:find_window_w).should be_true
      end

      it 'defined method returns nil (but NOT false) instead of zero' do
        find_window_w(nil, TEST_IMPOSSIBLE).should_not == false
        find_window_w(nil, TEST_IMPOSSIBLE).should == nil
      end

      it 'defined method does not return true when result is non-zero' do
        find_window_w(nil, nil).should_not == true
        find_window_w(nil, nil).should_not == 0
      end

      it 'defined method enforces the argument count' do
        expect {find_window_w}.to raise_error 'Invalid args count'
        expect {find_window_w(nil, nil, nil)}.to raise_error 'Invalid args count'
      end
    end

    context 'using DLL other than default user32 with :dll option' do
      before(:each) do
        hide_method :get_computer_name # hide original method if it is defined
        WinGui.def_api 'GetComputerName', ['P', 'P'], 'I', :dll=> 'kernel32'
      end
      after(:each) { restore_method :get_computer_name } # restore original method if it was hidden

      it 'defines new instance method with appropriate name' do
        respond_to?(:get_computer_name).should be_true
      end

      it 'returns expected result' do
        WinGui.def_api 'GetComputerName', ['P', 'P'], 'I', :dll=> 'kernel32'
        hostname = `hostname`.strip.upcase
        name = " " * 128
        get_computer_name(name, "128")
        name.unpack("A*").first.should == hostname
      end
    end

    context 'trying to define an invalid API function' do
      it 'raises error when trying to define function with a wrong function name' do
        expect { WinGui.def_api 'FindWindowImpossible', 'PP', 'L' }.
                to raise_error( /Unable to load function 'FindWindowImpossible'/ )
      end
    end

    context 'defining API function using definition block' do

      it 'defines new instance method' do
        WinGui.def_api( 'FindWindowW', 'PP', 'L' ){|api, *args|}
        respond_to?(:find_window_w).should be_true
      end

      it 'does not enforce argument count outside of block' do
        WinGui.def_api( 'FindWindowW', 'PP', 'L' ){|api, *args|}
        expect { find_window_w }.to_not raise_error 'Invalid args count'
        expect { find_window_w(nil) }.to_not raise_error 'Invalid args count'
        expect { find_window_w(nil, 'Str') }.to_not raise_error 'Invalid args count'
      end

      it 'returns block return value when defined method is called' do
        WinGui.def_api( 'FindWindowW', 'PP', 'L' ){|api, *args| 'Value'}
        find_window_w(nil).should == 'Value'
      end

      it 'passes arguments and underlying Win32::API object to the block' do
        WinGui.def_api( 'FindWindowW', 'PP', 'L' ) do |api, *args|
          @api = api
          @args = args
        end
        find_window_w(1, 2, 3)
        @args.should == [1, 2, 3]
        @api.function_name.should == 'FindWindowW' # The name of the api function passed to the block
      end

      it ':rename option overrides standard name for defined method' do
        WinGui.def_api( 'FindWindowW', 'PP', 'L', :rename => 'my_own_find' ){|api, *args|}
        expect {find_window_w(nil, nil, nil)}.to raise_error
        expect {my_own_find(nil, nil)}.to_not raise_error
      end
      it 'adds alias for defined method with :alias option' do
        WinGui.def_api( 'FindWindowW', 'PP', 'L', :alias => 'my_own_find' ){|api, *args|}
        expect {find_window_w(nil, nil)}.to_not raise_error
        expect {my_own_find(nil, nil)}.to_not raise_error
      end

      it 'adds aliases for defined method with :aliases option' do
        WinGui.def_api( 'FindWindowW', 'PP', 'L', :aliases => ['my_own_find', 'my_own_find1'] ) {|api, *args|}
        expect {find_window_w(nil, nil)}.to_not raise_error
        expect {my_own_find(nil, nil)}.to_not raise_error
        expect {my_own_find1(nil, nil)}.to_not raise_error
      end

      it 'returns underlying Win32::API object if defined method is called with (:api) argument ' do
        WinGui.def_api( 'FindWindowW', 'PP', 'L' ){|api, *args|}
        expect {@api = find_window_w(:api)}.to_not raise_error
        @api.dll_name.should == 'user32' # The name of the DLL that exports the API function
        @api.effective_function_name.should == 'FindWindowW' # Actual function returned by the constructor: 'GetUserName' ->'GetUserNameA' or 'GetUserNameW'
        @api.function_name.should == 'FindWindowW' # The name of the function passed to the constructor
        @api.prototype.should == ['P', 'P'] # The prototype, returned as an array of characters
      end
    end

    context 'providing API function with callback' do
      before(:each) { hide_method :enum_windows } # hide original find_window method if it is defined
      after(:each) { restore_method :enum_windows } # restore original find_window method if it was hidden

      it '#callback method creates a valid callback object' do
        expect { @callback = WinGui.callback('LP', 'I') {|handle, message| true} }.to_not raise_error
        @callback.should be_a_kind_of(Win32::API::Callback)
      end

      it 'created callback object can be used as a valid arg of API function expecting callback' do
        WinGui.def_api 'EnumWindows', 'KP', 'L'
        @callback = WinGui.callback('LP', 'I'){|handle, message| true }
        expect { enum_windows(@callback, 'Message') }.to_not raise_error
      end

      it 'defined API functions expecting callback recognize/accept blocks' do
        pending ' API is not exactly clear atm (what about prototype?)(.with_callback method?)'
      end
    end
  end
end
