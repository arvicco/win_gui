require File.join(File.dirname(__FILE__), "..", "spec_helper" )

module WinGuiTest

  describe Window do
    before(:each) { @app = launch_test_app }
    after(:each){ close_test_app }

    context 'initializing' do
      it 'can be wrapped around any existing window' do
        any_handle = find_window(nil, nil)
        use{ Window.new any_handle }
      end
    end

    context 'manipulating' do
      it 'has handle property equal to underlying window handle' do
        any = Window.new any_handle
        any.handle.should == any_handle
      end

      it 'closes when asked nicely' do
        @app.close
        sleep SLEEP_DELAY # needed to ensure window had enough time to close down
        find_window(nil, WIN_TITLE).should == nil
      end

      it 'waits for window to disappear (NB: this happens before handle is released!)' do
        start = Time.now
        @app.close
        @app.wait_for_close
        (Time.now - start).should be <= CLOSE_TIMEOUT
        window_visible?(@app.handle).should be false
        window?(@app.handle).should be false
      end
    end

    context 'handle-related WinGui functions as instance methods' do
      it 'calls all WinGui functions as instance methods (with handle as implicit first argument)' do
        @app.window?.should == true
        @app.visible?.should == true
        @app.foreground?.should == true
        @app.maximized?.should == false
        @app.maximized?.should == false
        @app.child?(any_handle).should == false

        @app.window_rect.should be_an Array
        @app.window_thread_process_id.should be_an Array
        @app.enum_child_windows.should be_an Array
      end

      it 'has class_name and text properties (derived from WinGui function calls)' do
        @app.class_name.should == WIN_CLASS
        # window_text propery accessed via GetWindowText
        @app.window_text.should == WIN_TITLE
        # text propery accessed by sending WM_GETTEXT directly to window (convenience method in WinGui)
        @app.text.should == WIN_TITLE
      end
    end

    describe '.top_level' do
      it 'finds top-level window by title and wraps it in a Window object' do
        win = Window.top_level( title: WIN_TITLE, timeout: 1)
        win.handle.should == @app.handle
      end

      it 'finds top-level window by class and wraps it in a Window object' do
        win = Window.top_level( class: WIN_CLASS, timeout: 1)
        win.handle.should == @app.handle
      end

      it 'finds ANY top-level window without args and wraps it in a Window object' do
        use { @win = Window.top_level() }
        Window.should === @win
      end

      it 'returns nil immediately if top-level window with given title not found' do
        start = Time.now
        Window.top_level( title: IMPOSSIBLE).should == nil
        (Time.now - start).should be_close 0, 0.02
      end

      it 'returns nil after timeout if top-level window with given title not found' do
        start = Time.now
        Window.top_level( title: IMPOSSIBLE, timeout: 0.5).should == nil
        (Time.now - start).should be_close 0.5, 0.02
      end

      it 'raises exception if asked to' do
        expect{ Window.top_level( title: IMPOSSIBLE, raise: "Horror!")}.to raise_error "Horror!"
      end
    end # describe .top_level

    describe '#child' do
      spec { use { @child = @app.child(title: "Title", class: "Class", id: 0)  }}

      it 'returns nil immediately if specific child not found' do
        start = Time.now
        @app.child( title: IMPOSSIBLE).should == nil
        (Time.now - start).should be_close 0, 0.02
      end

      it 'returns nil after timeout if specific child not found' do
        start = Time.now
        @app.child( title: IMPOSSIBLE, timeout: 0.5).should == nil
        (Time.now - start).should be_close 0.5, 0.02
      end

      it 'finds ANY child window without args' do
        use { @child = @app.child() }
        @child.should_not == nil
        @app.child?(@child.handle).should == true
      end

      it 'finds child window by class and returns it as a Window object (no timeout)' do
        child = @app.child( class: TEXTAREA_CLASS)
        child.should_not == nil
        @app.child?(child.handle).should == true
      end

      it 'finds child window by class and returns it as a Window object (with timeout)' do
#        p @app.find_window_ex(0, TEXTAREA_CLASS, nil)
#        p @app.find_window_ex(0, STATUSBAR_CLASS, nil)
        child = @app.child( class: TEXTAREA_CLASS, timeout: 0.5)
        child.should_not == nil

        @app.child?(child.handle).should == true
        child = @app.child( class: STATUSBAR_CLASS, timeout: 0.5)
        child.should_not == nil
        @app.child?(child.handle).should == true
      end

      it 'finds child with specific text and returns it as a Window object' do
        with_dialog(:save) do |dialog|
#          @dialog.children.each{|child| puts "#{child.handle}, #{child.class_name}, #{child.window_text}"}
          child = dialog.child( title: "Cancel")
          child.should_not == nil
          dialog.child?(child.handle).should == true
          child.get_dlg_ctrl_id.should == IDCANCEL

          child = dialog.child( title: "&Save")
          child.should_not == nil
          dialog.child?(child.handle).should == true
          child.get_dlg_ctrl_id.should == IDOK
        end
      end

      it 'finds child control with a given ID and returns it as a Window object' do
        with_dialog(:save) do |dialog|
          child = dialog.child( id: IDCANCEL)
          child.should_not == nil
          dialog.child?(child.handle).should == true
          child.text.should == "Cancel"
        end
      end
    end # describe child

    describe '#children' do
      spec { use { children = @app.children  }}

      it 'returns an array of Windows that are descendants (not only DIRECT children) of a given Window' do
        children = @app.children
        children.should be_a_kind_of Array
        children.should_not be_empty
        children.should have(2).elements
        children.each{|child| child?(@app.handle, child.handle).should == true }
        children.last.class_name.should == TEXTAREA_CLASS
      end
    end # describe #children

    describe '#click' do
      it 'emulates clicking of the control identified by id, returns true' do
        with_dialog(:save) do |dialog|
          dialog.click(id: IDCANCEL).should == true
          sleep 0.5
          dialog.window?.should == false
        end
      end

      it 'emulates clicking of the control identified by title, returns true' do
        with_dialog(:save) do |dialog|
          dialog.click(title: "Cancel").should == true
          sleep 0.5
          dialog.window?.should == false
        end
      end

      it 'returns false if the specified control was not found' do
        with_dialog(:save) do |dialog|
          dialog.click(title: "Shpancel").should == false
          dialog.click(id: 66).should == false
          sleep 0.5
          dialog.window?.should == true
        end
      end
    end # describe #click
  end
end