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

      it 'has class_name property' do
        @app.class_name.should == WIN_CLASS
      end

      it 'has text property equal to underlying window text(title)' do
        @app.text.should == WIN_TITLE
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
        Window.top_level( title: IMPOSSIBLE, timeout: 1).should == nil
        (Time.now - start).should be_close 1, 0.02
      end
    end

    describe '#child' do
      spec { use { @control = @app.child(title_class_id = nil)  }}

      it 'finds any child window(control) if given nil' do
        @app.child(nil).should_not == nil
      end

      it 'finds child window(control) by class' do
        @app.child(TEXTAREA_CLASS).should_not == nil
      end

      it 'finds child window(control) by name' do
        pending 'Need to find control with short name'
        @app.child(TEXTAREA_TEXT).should_not == nil
      end

      it 'finds child window(control) by control ID' do
        pending 'Need to find some control ID'
        @app.child(TEXTAREA_ID).should_not == nil
      end

      it 'raises error if wrong control is given' do
        expect { @app.child('Impossible Control')}.to raise_error "Control 'Impossible Control' not found"
      end

      it 'substitutes & for _ when searching by title ("&Yes" type controls)' # Why?
    end

    describe '#children' do
      spec { use { children = @app.children  }}

      it 'returns an array of Windows that are descendants (not only DIRECTchildren) of a given Window' do
        children = @app.children
        children.should be_a_kind_of Array
        children.should_not be_empty
        children.should have(2).elements
        children.each{|child| child?(@app.handle, child.handle).should == true }
        get_class_name(children.last.handle).should == TEXTAREA_CLASS
      end

#      it 'finds child window(control) by name' do
#        pending 'Need to find control with short name'
#        @app.child(TEXTAREA_TEXT).should_not == nil
#      end
#
#      it 'finds child window(control) by control ID' do
#        pending 'Need to find some control ID'
#        @app.child(TEXTAREA_ID).should_not == nil
#      end
#
#      it 'raises error if wrong control is given' do
#        expect { @app.child('Impossible Control')}.to raise_error "Control 'Impossible Control' not found"
#      end
#      it 'substitutes & for _ when searching by title ("&Yes" type controls)'

    end

    context '#click' do
      it 'emulates clicking of the control identified by id'
    end
  end
end