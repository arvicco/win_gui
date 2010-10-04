require File.join(File.dirname(__FILE__), "..", "spec_helper")

module WinGuiTest

  describe App do
    after(:each) do # Reliably closes launched app window (without calling close_test_app)
      app = App.find(title: WIN_TITLE)
      app.exit if app
    end

    context 'initializing' do
      context '::new' do
        before(:each) { launch_test_app }
        after(:each) { close_test_app }

        it 'wraps new App around existing Window' do
          window = Window.top_level(title: WIN_TITLE)
          @app = App.new(window)
          @app.should be_an App
          @app.main_window.should == window
        end

        it 'wraps new App around active window handle (of top-level Window)' do
          window = Window.top_level(title: WIN_TITLE)
          @app = App.new(window.handle)
          @app.should be_an App
          @app.main_window.handle.should == window.handle
        end

        it 'raises error trying to create App with wrong init args' do
          expect { App.new() }.to raise_error ArgumentError, /wrong number of arguments/
          [[nil], 1.2, {title: WIN_TITLE}].each do |args|
            expect { App.new(*args) }.to raise_error WinGui::Errors::InitError
          end
        end
      end

      context '::find' do
        before(:each) { launch_test_app }
        after(:each) { close_test_app }

        it 'finds already launched App given valid Window info' do
          use { @app = App.find(title: WIN_TITLE) }
          @app.should be_an App
        end

        it 'returns nil if asked to find App with invalid Window info' do
          App.find(title: IMPOSSIBLE).should == nil
        end

        it 'raises error only if asked to find App with invalid Window info and :raise option is set' do
          expect { App.find(title: IMPOSSIBLE, raise: WinGui::Errors::InitError) }.
                  to raise_error WinGui::Errors::InitError
        end
      end

      context '::launch' do
        it 'launches new App given valid path and Window info' do
          use { @app = App.launch(path: APP_PATH, title: WIN_TITLE) }
          @app.should be_an App
        end

        it 'raises error if asked to launch App with invalid path' do
          expect { App.launch(path: IMPOSSIBLE, title: WIN_TITLE) }.
                  to raise_error WinGui::Errors::InitError, /Unable to launch "Impossible"/
        end

        it 'raises error if asked to launch App with invalid Window info' do
          expect { App.launch(path: APP_PATH, title: IMPOSSIBLE) }.
                  to raise_error WinGui::Errors::InitError, /Unable to launch App with .*?:title=>"Impossible"/
        end
      end

      context 'properties:' do
        before(:each) { @app = App.launch(path: APP_PATH, title: WIN_TITLE) }
        after(:each) { @app.close }

        it 'main_window' do
          @app.main_window.should be_a Window
          @app.main_window.title.should == WIN_TITLE
        end
      end
    end

    context 'manipulating' do
      before(:each) { @app = App.launch(path: APP_PATH, title: WIN_TITLE) }

      it 'exits App gracefully' do
        @app.exit
        sleep SLEEP_DELAY # needed to ensure window had enough time to close down
        @app.main_window.visible?.should == false
        @app.main_window.window?.should == false
      end

      it 'closes App gracefully' do
        @app.close
        sleep SLEEP_DELAY # needed to ensure window had enough time to close down
        @app.main_window.visible?.should == false
        @app.main_window.window?.should == false
      end

      it 'exits App with timeout' do
        @app.exit(1)
        # No sleep SLEEP_DELAY needed!
        @app.main_window.visible?.should == false
        @app.main_window.window?.should == false
      end
    end
  end
end
