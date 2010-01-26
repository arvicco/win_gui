require File.join(File.dirname(__FILE__), "..", "spec_helper" )

module GuiTest
  describe WinGui, ' contains a set of pre-defined GUI functions' do
    describe '#window?' do
      spec{ use{ window?(handle = 0) }}
      # Tests whether the specified window handle identifies an existing window.
      #   A thread should not use IsWindow for a window that it did not create because the window could be destroyed after this 
      #   function was called. Further, because window handles are recycled the handle could even point to a different window. 

      it 'returns true if window exists' do
        test_app do |app|
          window?(app.handle).should == true
          window?(app.textarea.handle).should == true
        end
      end

      it 'returns false if window does not exist' do
        test_app do |app|
          @app_handle = app.handle
          @ta_handle = app.textarea.handle
        end
        window?(@app_handle).should == false
        window?(@ta_handle).should == false
      end
    end

    describe '#window_visible?' do
      spec{ use{ window_visible?(handle = any_handle) }}
      spec{ use{ visible?(handle = any_handle) }}
      # Tests if the specified window, its parent window, its parent's parent window, and so forth, have the WS_VISIBLE style.
      # Because the return value specifies whether the window has the WS_VISIBLE style, it may be true even if the window is totally obscured by other windows. 

      it 'returns true if window is visible' do
        test_app do |app|
          visible?(app.handle).should == true
          window_visible?(app.handle).should == true
          window_visible?(app.textarea.handle).should == true
        end
      end

      it 'returns false if window is not visible' do
        test_app do |app|
          hide_window(app.handle)
          visible?(app.handle).should == false
          window_visible?(app.handle).should == false
          window_visible?(app.textarea.handle).should == false
        end
      end
    end

    describe '#maximized?' do
      spec{ use{ zoomed?(handle = 0) }}
      spec{ use{ maximized?(handle = 0) }}
      # Tests whether the specified window is maximized. 

      it 'returns false if window is not maximized' do
        test_app do |app|
          zoomed?(app.handle).should == false
          maximized?(app.handle).should == false
        end
      end

      it 'returns true if the window is maximized' do
        test_app do |app|
          show_window(app.handle, SW_MAXIMIZE)
          maximized?(app.handle).should == true
          zoomed?(app.handle).should == true
        end
      end
    end

    describe '#minimized?' do
      spec{ use{ iconic?(handle = 0) }}
      spec{ use{ minimized?(handle = 0) }}
      # Tests whether the specified window is minimized. 

      it 'returns false if window is not minimized' do
        test_app do |app|
          iconic?(app.handle).should == false
          minimized?(app.handle).should == false
        end
      end

      it 'returns true if the window is minimized' do
        test_app do |app|
          show_window(app.handle, SW_MINIMIZE)
          iconic?(app.handle).should == true
          minimized?(app.handle).should == true
        end
      end
    end

    describe '#child?' do
      spec{ use{ child?(parent_handle = any_handle, handle = any_handle) }}
      # Tests whether a window is a child (or descendant) window of a specified parent window. A child window is the direct descendant 
      # of a specified parent window if that parent window is in the chain of parent windows; the chain of parent windows leads from 
      # the original overlapped or pop-up window to the child window.

      it 'returns true if the window is a child' do
        test_app do |app|
          child?(app.handle, app.textarea.handle).should == true
        end
      end
      it 'returns false if window is not a child' do
        test_app do |app|
          child?(app.handle, any_handle).should == false
        end
      end
    end

    describe '#find_window' do
      spec{ use{ find_window(class_name = nil, win_name = nil) }}

      it 'returns either Integer Window handle or nil' do
        find_window(nil, nil).should be_a_kind_of Integer
        nil.class.should === find_window(TEST_IMPOSSIBLE, nil)
      end

      it 'returns nil if Window is not found' do
        find_window(TEST_IMPOSSIBLE, nil).should == nil
        find_window(nil, TEST_IMPOSSIBLE).should == nil
        find_window(TEST_IMPOSSIBLE, TEST_IMPOSSIBLE).should == nil
      end

      it 'finds at least one window if both args are nils' do
        find_window(nil, nil).should_not == nil
      end

      it 'finds top-level window by window class' do
        test_app {|app| find_window(TEST_WIN_CLASS, nil).should == app.handle }
      end

      it 'finds top-level window by title' do
        test_app {|app| find_window(nil, TEST_WIN_TITLE).should == app.handle }
      end
    end

    describe '#find_window_w' do
      spec{ use{ find_window_w(class_name = nil, win_name = nil) }}

      it 'returns zero if Window is not found' do
        find_window_w(TEST_IMPOSSIBLE, nil).should == nil
        find_window_w(nil, TEST_IMPOSSIBLE).should == nil
        find_window_w(TEST_IMPOSSIBLE, TEST_IMPOSSIBLE).should == nil
      end

      it 'finds at least one window if given two nils' do
        find_window_w(nil, nil).should_not == nil
      end

      it 'finds top-level window by window class' do
        test_app {|app| find_window_w(TEST_WIN_CLASS.to_w, nil).should == app.handle }
      end

      it 'finds top-level window by title' do
        test_app {|app| find_window_w(nil, TEST_WIN_TITLE.to_w).should == app.handle }
      end
    end

    describe '#find_window_ex' do
      spec{ use{ control_handle = find_window_ex(parent = any_handle, after_child = 0, win_class = nil, win_title = nil) }}

      it 'returns nil if wrong control is given' do
        parent_handle = any_handle
        find_window_ex(parent_handle, 0, TEST_IMPOSSIBLE, nil).should == nil
        find_window_ex(parent_handle, 0, nil, TEST_IMPOSSIBLE).should == nil
      end

      it 'finds child window/control by class' do
        test_app do |app|
          ta_handle = find_window_ex(app.handle, 0, TEST_TEXTAREA_CLASS, nil)
          ta_handle.should_not == nil
          ta_handle.should == app.textarea.handle
        end
      end

      it 'finds child window/control by text/title' do
        pending 'Identify appropriate (short name) control'
        test_app do |app|
          keystroke(VK_CONTROL, 'A'.ord)
          keystroke('1'.ord, '2'.ord)
          ta_handle = find_window_ex(app.handle, 0, nil, '12')
          ta_handle.should_not == 0
          ta_handle.should == app.textarea.handle
        end
      end
    end

    describe '#get_window_thread_process_id' do
      spec{ use{ thread, process = get_window_thread_process_id(handle = any_handle) }}
      # Improved with block to accept window handle as a single arg and return a pair of [thread, process]

      it 'returns a pair of nonzero Integer ids (window thread and process)' do
        thread, process = get_window_thread_process_id(handle = any_handle)
        thread.should be_a_kind_of Integer
        thread.should be > 0
        process.should be_a_kind_of Integer
        process.should be > 0
      end
    end

    describe '#get_window_text' do
      spec{ use{ text = get_window_text(handle = 0)}}
      # Improved with block to accept window handle as a single arg and return (rstripped) text string 

      it 'returns correct window text' do
        test_app {|app| get_window_text(app.handle).should == TEST_WIN_TITLE }
      end
    end

    describe '#get_window_text_w' do
      spec{ use{ class_name = get_window_text_w(handle = 0)}} # result encoded as utf-8
      # Unicode version of get_window_text (strings returned encoded as utf-8)

      it 'returns correct window text' do
        test_app {|app| get_window_text_w(app.handle).should == TEST_WIN_TITLE }
      end
    end

    describe '#get_class_name' do
      spec{ use{ class_name = get_class_name(handle = 0)}}
      # Improved with block to accept window handle as a single arg and return class name string 

      it 'returns correct window class name' do
        test_app {|app| get_class_name(app.handle).should == TEST_WIN_CLASS }
      end
    end

    describe '#get_class_name_w' do
      spec{ use{ class_name = get_class_name_w(handle = 0)}} # result encoded as utf-8
      # Unicode version of get_class_name (strings returned encoded as utf-8)

      it 'returns correct window class name' do
        test_app {|app| get_class_name_w(app.handle).should == TEST_WIN_CLASS }
      end
    end

    describe '#get_window_rect' do
      spec{ use{ left, top, right, bottom = get_window_rect(any_handle)}}

      it 'returns windows rectangle' do
        test_app do |app|
          get_window_rect(app.handle).should == TEST_WIN_RECT
        end
      end
    end

    describe '#show_window ', 'LI', 'I' do
      spec{ use{ was_visible = show_window(handle = any_handle, cmd = SW_SHOWNA) }}

      it 'was_visible = hide_window(handle = any_handle)  # alias method (not a separate API function)' do
        test_app do |app|
          use{ hide_window(app.handle) }
          visible?(app.handle).should == false
        end
      end

      it 'returns true if the window was PREVIOUSLY visible' do
        test_app {|app| show_window(app.handle, SW_HIDE).should == true }
      end

      it 'returns false if the window was PREVIOUSLY not visible' do
        test_app do |app|
          show_window(app.handle, SW_HIDE)
          show_window(app.handle, SW_HIDE).should == false
        end
      end

      it 'SW_HIDE command hides window' do
        test_app do |app|
          show_window(app.handle, SW_HIDE)
          visible?(app.handle).should == false
        end
      end

      it 'SW_SHOW command shows hidden window' do
        test_app do |app|
          show_window(app.handle, SW_HIDE)
          show_window(app.handle, SW_SHOW)
          visible?(app.handle).should == true
        end
      end

      it 'SW_MAXIMIZE maximizes window' do
        test_app do |app|
          show_window(app.handle, SW_MAXIMIZE)
          maximized?(app.handle).should == true
        end
        pending 'Need to make sure window is maximized but NOT activated '
      end

      it 'SW_MINIMIZE minimizes window and activates the next top-level window in the Z order' do
        test_app do |app|
          show_window(app.handle, SW_MINIMIZE)
          minimized?(app.handle).should == true
        end
      end

      it 'SW_SHOWMAXIMIZED activates the window and displays it as a maximized window' do
        pending 'Need to make sure window is maximized AND activated '
        test_app do |app|
          show_window(app.handle, SW_SHOWMAXIMIZED)
          get_window_rect(app.handle)
          #.should == TEST_MAX_RECT
        end

      end
      it 'SW_SHOWMINIMIZED activates the window and displays it as a minimized window' do
        pending 'Need to make sure window is minimized AND activated '
        test_app do |app|
          show_window(app.handle, SW_SHOWMINIMIZED)
          p get_window_rect(app.handle)
          #.should == TEST_MAX_RECT
        end

      end
      it 'SW_SHOWMINNOACTIVE displays the window as a minimized window (similar to SW_SHOWMINIMIZED, but window is not activated)'
      it 'SW_SHOWNA displays the window in its current size and position (similar to SW_SHOW, but window is not activated)'
      it 'SW_SHOWNOACTIVATE displays the window in its current size and position (similar to SW_SHOW, but window is not activated)'
      it 'SW_SHOWNORMAL activates and displays a window. Restores minimized/maximized window to original size/position. Use it to show window for the first time'
      it 'SW_RESTORE activates and displays the window. Restores minimized/maximized window to original size/position. Use it to restore minimized windows'
      it 'SW_SHOWDEFAULT sets the show state based on the SW_ value specified in the STARTUPINFO structure passed to the CreateProcess function by the program that started the application'
      it 'SW_FORCEMINIMIZE minimizes a window, even if the thread that owns the window is not responding - only Win2000/XP'
    end

    describe '#keydb_event' do
      spec{ use{ keybd_event(vkey = 0, bscan = 0, flags = 0, extra_info = 0) }}
      # vkey (I) - Specifies a virtual-key code. The code must be a value in the range 1 to 254. For a complete list, see msdn:Virtual Key Codes. 
      # bscan (I) - Specifies a hardware scan code for the key.
      # flags (L) - Specifies various aspects of function operation. This parameter can be one or more of the following values.
      #   KEYEVENTF_EXTENDEDKEY - If specified, the scan code was preceded by a prefix byte having the value 0xE0 (224).
      #   KEYEVENTF_KEYUP - If specified, the key is being released. If not specified, the key is being depressed.
      # extra_info (L) - Specifies an additional value associated with the key stroke.
      # no return value

      it 'synthesizes a numeric keystroke, emulating keyboard driver' do
        test_app do |app|
          text = '123 456'
          text.upcase.each_byte do |b| # upcase needed since user32 keybd_event expects upper case chars 
            keybd_event(b.ord, 0, KEYEVENTF_KEYDOWN, 0)
            sleep TEST_KEY_DELAY
            keybd_event(b.ord, 0, KEYEVENTF_KEYUP, 0)
            sleep TEST_KEY_DELAY
          end
          app.textarea.text.should =~ Regexp.new(text)
          7.times {keystroke(VK_CONTROL, 'Z'.ord)} # dirty hack!
        end
      end

      it 'synthesizes a letter keystroke, emulating keyboard driver'
    end

    describe '#post_message' do
      spec{ use{ success = post_message(handle = 0, msg = 0, w_param = 0, l_param = 0) }}
      # handle (L) - Handle to the window whose window procedure will receive the message. 
      #   If this parameter is HWND_BROADCAST, the message is sent to all top-level windows in the system, including disabled or 
      #   invisible unowned windows, overlapped windows, and pop-up windows; but the message is not sent to child windows.
      # msg (L) - Specifies the message to be posted.
      # w_param (L) - Specifies additional message-specific information.
      # l_param (L) - Specifies additional message-specific information.
      # returns (L) - Nonzero if success, zero if function failed. To get extended error information, call GetLastError.

      it 'places (posts) a message in the message queue associated with the thread that created the specified window'
      it 'returns without waiting for the thread to process the message'
    end

    describe '#send_message' do
      spec{ use{ success = send_message(handle = 0, msg = 0, w_param = 1024, l_param = "\x0"*1024) }}
      # handle (L) - Handle to the window whose window procedure is to receive the message. The following values have special meanings.
      #   HWND_BROADCAST - The message is posted to all top-level windows in the system, including disabled or invisible unowned windows, 
      #     overlapped windows, and pop-up windows. The message is not posted to child windows.
      #   NULL - The function behaves like a call to PostThreadMessage with the dwThreadId parameter set to the identifier of the current thread.
      # msg (L) - Specifies the message to be posted.
      # w_param (L) - Specifies additional message-specific information.
      # l_param (L) - Specifies additional message-specific information.
      # return (L) - Nonzero if success, zero if function failed. To get extended error information, call GetLastError.

      it 'sends the specified message to a window or windows'
      it 'calls the window procedure and does not return until the window procedure has processed the message'
    end

    describe '#get_dlg_item' do
      spec{ use{ control_handle = get_dlg_item(handle = 0, item_id = 1) }}
      # handle (L) - Handle of the dialog box that contains the control. 
      # item_id (I) - Specifies the identifier of the control to be retrieved. 
      # Returns (L) - handle of the specified control if success or nil for invalid dialog box handle or a nonexistent control.
      #   To get extended error information, call GetLastError.
      #   You can use the GetDlgItem function with any parent-child window pair, not just with dialog boxes. As long as the handle 
      #   parameter specifies a parent window and the child window has a unique id (as specified by the hMenu parameter in the 
      #   CreateWindow or CreateWindowEx function that created the child window), GetDlgItem returns a valid handle to the child window. 

      it 'returns handle to correctly specified control'
    end

    describe '#enum_windows' do
      spec{ use{ enum_windows(message = 'Message') }}

      it 'return an array of top-level window handles if block is not given' do
        enum = enum_windows(message = 'Message')
        enum.should be_a_kind_of Array
        enum.should_not be_empty
        enum.should have_at_least(60).elements # typical number of top windows in WinXP system?
        enum.compact.size.should == enum.size # should not contain nils
      end

      it 'iterates through all the top-level windows, passing each found window handle and message to a given block'

    end

    describe '#enum_child_windows' do
      spec{ use{ enum_child_windows(parent = any_handle, message = 'Message') }}

      it 'return an array of child window handles if block is not given' do
        test_app do |app|
          enum = enum_child_windows(app.handle, message = 'Message')
          enum.should be_a_kind_of Array
          enum.should_not be_empty
          enum.should have(2).elements
          p get_class_name(enum.first), get_class_name(enum.last)
          get_class_name(enum.last).should == TEST_TEXTAREA_CLASS
        end
      end

      it 'loops through all children of given window, passing each found window handle and a message to a given block'
    end

    it 'GetForegroundWindow ', 'V', 'L'
    it 'GetActiveWindow ', 'V', 'L'
  end

  describe WinGui, ' convenience wrapper methods' do
    describe '#keystroke' do
      spec{ use{ keystroke( vkey = 30, vkey = 30) }}
      # this service method emulates combinations of (any amount of) keys pressed one after another (Ctrl+Alt+P) and then released
      # vkey (int) - Specifies a virtual-key code. The code must be a value in the range 1 to 254. For a complete list, see msdn:Virtual Key Codes. 

      it 'emulates combinations of keys pressed (Ctrl+Alt+P+M, etc)' do
        test_app do |app|
          keystroke(VK_CONTROL, 'A'.ord)
          keystroke(VK_SPACE)
          app.textarea.text.should == ' '
          2.times {keystroke(VK_CONTROL, 'Z'.ord)} # dirty hack!
        end
      end
    end

    describe '#type_in' do
      spec{ use{ type_in(message = '') }}
      # this service method types text message into window holding the focus

      it 'types text message into window holding the focus' do
        test_app do |app|
          text = '123 456'
          type_in(text)
          app.textarea.text.should =~ Regexp.new(text)
          7.times {keystroke(VK_CONTROL, 'Z'.ord)} # dirty hack!
        end
      end
    end

    describe 'dialog' do
      spec{ use{ dialog( title ='Dialog Title', timeout_sec = 0.001, &any_block)  }}
      # me od finds top-level dialog window by title and yields found dialog window to block if given

      it 'finds top-level dialog window by title' do
        pending 'Some problems (?with timeouts?) leave window open ~half of the runs'
        test_app do |app|
          keystroke(VK_ALT, 'F'.ord, 'A'.ord)
          @found = false
          dialog('Save As', 0.5) do |dialog_window|
            @found = true
            keystroke(VK_ESCAPE)
            dialog_window
          end
          @found.should == true
        end
      end
      it 'yields found dialog window to a given block'
    end

  end
end