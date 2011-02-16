require "spec_helper.rb"

describe WinGui::Window do
  before(:each) { @win = launch_test_app.main_window }
  after(:each) { close_test_app }

  context 'initializing' do
    it 'can be wrapped around any existing window' do
      any_handle = find_window(nil, nil)
      use { Window.new any_handle }
    end
  end

  context 'manipulating' do
    it 'closes when asked nicely' do
      @win.close
      sleep SLEEP_DELAY # needed to ensure window had enough time to close down
      find_window(nil, WIN_TITLE).should == nil
    end

    it 'waits for window to disappear (NB: this happens before handle is released!)' do
      start = Time.now
      @win.close
      @win.wait_for_close
      (Time.now - start).should be <= CLOSE_TIMEOUT
      window_visible?(@win.handle).should be false
      window?(@win.handle).should be false
    end
  end

  context 'handle-related WinGui functions as instance methods' do
    it 'calls all WinGui functions as instance methods (with handle as implicit first argument)' do
      @win.window?.should == true
      @win.visible?.should == true
      @win.foreground?.should == true
      @win.maximized?.should == false
      @win.minimized?.should == false
      @win.child?(any_handle).should == false

      @win.window_rect.should be_an Array
      @win.window_thread_process_id.should be_an Array
      @win.enum_child_windows.should be_an Array
    end
  end

  context 'derived properties' do
    it 'has handle property equal to underlying window handle' do
      any = Window.new any_handle
      any.handle.should == any_handle
    end

    it 'has class_name and text/title properties (derived from WinGui function calls)' do
      @win.class_name.should == WIN_CLASS
      # text property accessed by sending WM_GETTEXT directly to window (convenience method in WinGui)
      @win.text.should == WIN_TITLE
      # window_text property accessed via GetWindowText
      @win.window_text.should == WIN_TITLE
      # title property is just an alias for window_text
      @win.title.should == WIN_TITLE
    end

    it 'has thread and process(pid) properties derived from get_window_thread_process_id' do
      [@win.thread, @win.process].should == get_window_thread_process_id(@win.handle)
      @win.pid.should == @win.process
    end

    it 'has id property that only makes sense for controls' do
      use { @win.id }
    end
  end

  describe '::top_level' do
    it 'finds ANY top-level window without args and wraps it in a Window object' do
      use { @window = Window.top_level() }
      @window.should be_a Window
    end


    context 'with String arguments' do
      let(:title) { WIN_TITLE }
      let(:class_name) { WIN_CLASS }
      let(:impossible) { IMPOSSIBLE }

      it 'finds top-level window by title and wraps it in a Window object' do
        window = Window.top_level(:title => title, timeout: 1)
        window.handle.should == @win.handle
      end

      it 'finds top-level window by class and wraps it in a Window object' do
        window = Window.top_level(:class => class_name, timeout: 1)
        window.handle.should == @win.handle
      end

      it 'returns nil immediately if top-level window with given title not found' do
        start = Time.now
        Window.top_level(:title => impossible).should == nil
        (Time.now - start).should be_within(0.03).of 0
      end

      it 'returns nil after timeout if top-level window with given title not found' do
        start = Time.now
        Window.top_level(:title => impossible, :timeout => 0.3).should == nil
        (Time.now - start).should be_within(0.03).of 0.3
      end

      it 'raises exception if asked to' do
        expect { Window.top_level(:title => impossible, :raise => "Horror!") }.to raise_error "Horror!"
      end
    end

    context 'with Regexp arguments' do
      let(:title) { Regexp.new WIN_TITLE[-6..-1] }
      let(:class_name) { Regexp.new WIN_CLASS[-6..-1] }
      let(:impossible) { Regexp.new IMPOSSIBLE }

      it 'finds top-level window by title and wraps it in a Window object' do
        window = Window.top_level(:title => title, timeout: 1)
        window.handle.should == @win.handle
      end

      it 'finds top-level window by class and wraps it in a Window object' do
        window = Window.top_level(:class => class_name, timeout: 1)
        window.handle.should == @win.handle
      end

      it 'returns nil immediately if top-level window with given title not found' do
        start = Time.now
        Window.top_level(:title => impossible).should == nil
        (Time.now - start).should be_within(0.03).of 0
      end

      it 'returns nil after timeout if top-level window with given title not found' do
        start = Time.now
        Window.top_level(:title => impossible, :timeout => 0.3).should == nil
        (Time.now - start).should be_within(0.03).of 0.3
      end

      it 'raises exception if asked to' do
        expect { Window.top_level(:title => impossible, :raise => "Horror!") }.to raise_error "Horror!"
      end
    end

  end # describe .top_level

  describe '#child' do
    spec { use { @child = @win.child(title: "Title", class: "Class", id: 0) } }

    it 'returns nil immediately if specific child not found' do
      start = Time.now
      @win.child(title: IMPOSSIBLE).should == nil
      (Time.now - start).should be_within(0.03).of 0
    end

    it 'returns nil after timeout if specific child not found' do
      start = Time.now
      @win.child(title: IMPOSSIBLE, timeout: 0.5).should == nil
      (Time.now - start).should be_within(0.03).of 0.5
    end

    it 'finds ANY child window without args' do
      use { @child = @win.child() }
      @child.should_not == nil
      @win.child?(@child.handle).should == true
    end

    it 'finds child window by class and returns it as a Window object (no timeout)' do
      child = @win.child(class: TEXTAREA_CLASS)
      child.should_not == nil
      @win.child?(child.handle).should == true
    end

    it 'finds child window by class and returns it as a Window object (with timeout)' do
      child = @win.child(class: TEXTAREA_CLASS, timeout: 0.5)
      child.should_not == nil

      @win.child?(child.handle).should == true
      child = @win.child(class: STATUSBAR_CLASS, timeout: 0.5)
      child.should_not == nil
      @win.child?(child.handle).should == true
    end

    it 'finds child with specific text and returns it as a Window object' do
      with_dialog(:save) do |dialog|
        child = dialog.child(title: "Cancel")
        child.should_not == nil
        dialog.child?(child.handle).should == true
        child.get_dlg_ctrl_id.should == IDCANCEL

        child = dialog.child(title: "&Save")
        child.should_not == nil
        dialog.child?(child.handle).should == true
        child.get_dlg_ctrl_id.should == IDOK
      end
    end

    it 'finds child control with a given ID and returns it as a Window object' do
      with_dialog(:save) do |dialog|
        child = dialog.child(id: IDCANCEL)
        child.should_not == nil
        dialog.child?(child.handle).should == true
        child.text.should == "Cancel"
      end
    end

    context 'indirect child' do
      it 'returns nil if specified child not found' do
        @win.child(title: IMPOSSIBLE, indirect: true).should == nil
      end

      it 'finds ANY child window without other args' do
        use { @child = @win.child(indirect: true) }
        @child.should_not == nil
        @win.child?(@child.handle).should == true
      end

      it 'finds child window by class' do
        child = @win.child(class: TEXTAREA_CLASS, indirect: true)
        child.should_not == nil
        @win.child?(child.handle).should == true
      end

      it 'finds child with specific text' do
        with_dialog(:save) do |dialog|
          child = dialog.child(title: "Cancel", indirect: true)
          child.should_not == nil
          dialog.child?(child.handle).should == true
          child.id.should == IDCANCEL

          child = dialog.child(title: "&Save", indirect: true)
          child.should_not == nil
          dialog.child?(child.handle).should == true
          child.id.should == IDOK
        end
      end

      it 'finds child control with a given ID ' do
        with_dialog(:save) do |dialog|
          child = dialog.child(id: IDCANCEL, indirect: true)
          child.should_not == nil
          dialog.child?(child.handle).should == true
          child.text.should == "Cancel"
        end
      end
    end # context indirect
  end # describe child

  describe '#children' do
    spec { use { children = @win.children } }

    it 'returns an array of Windows that are descendants (not only DIRECT children) of a given Window' do
      children = @win.children
      children.should be_a_kind_of Array
      children.should_not be_empty
      children.should have(2).elements
      children.each { |child| child?(@win.handle, child.handle).should == true }
      children.last.class_name.should == TEXTAREA_CLASS
    end
  end # describe #children

  describe '#click' do
    it 'emulates left click of the control identified by id, returns click coords' do
      with_dialog(:save) do |dialog|
        point = dialog.click(id: IDCANCEL)
        point.should be_an Array
        sleep 0.3
        dialog.window?.should == false
      end
    end

    it 'emulates left click of the control identified by title, returns click coords' do
      with_dialog(:save) do |dialog|
        point = dialog.click(title: "Cancel")
        point.should be_an Array
        sleep 0.3
        dialog.window?.should == false
      end
    end

    it 'emulates right click of the control identified by id, returns click coords' do
      with_dialog(:save) do |dialog|
        point = dialog.click(id: IDCANCEL, mouse_button: :right)
        point.should be_an Array
        sleep 0.3
        dialog.window?.should == true
      end
    end

    it 'emulates right click of the control identified by title, returns click coords' do
      with_dialog(:save) do |dialog|
        point = dialog.click(title: "Cancel", mouse_button: :right)
        point.should be_an Array
        sleep 0.3
        dialog.window?.should == true
      end
    end

    it 'returns nil if the specified control was not found' do
      with_dialog(:save) do |dialog|
        dialog.click(title: "Shpancel").should == nil
        dialog.click(id: 66).should == nil
        sleep 0.3
        dialog.window?.should == true
      end
    end
  end # describe #click
end