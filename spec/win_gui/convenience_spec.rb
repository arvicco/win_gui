require File.join(File.dirname(__FILE__), "..", "spec_helper" )

module WinGuiTest

  describe 'Convenience methods' do
    before(:each){ @app = launch_test_app }
    after(:each) { close_test_app }

    describe '#dialog' do
      it 'returns top-level dialog window with given title if no block attached' do
        with_dialog(:save) do
          dialog_window = dialog(title: DIALOG_TITLE, timeout: 0.1)
          dialog_window.should_not == nil
          dialog_window.should be_a Window
          dialog_window.text.should == DIALOG_TITLE
        end
      end

      it 'yields found dialog window to block if block is attached' do
        with_dialog(:save) do
          dialog(title: DIALOG_TITLE) do |dialog_window|
            dialog_window.should_not == nil
            dialog_window.should be_a Window
            dialog_window.text.should == DIALOG_TITLE
          end
        end
      end

      it 'returns nil if there is no dialog with given title' do
        with_dialog(:save) do
          dialog(title: IMPOSSIBLE, timeout: 0.1).should == nil
        end
      end

      it 'yields nil to attached block if no dialog found' do
        with_dialog(:save) do
          dialog(title: IMPOSSIBLE, timeout: 0.1) do |dialog_window|
            dialog_window.should == nil
          end
        end
      end

      it 'considers all arguments optional' do
        with_dialog(:save) do
          use { dialog_window = dialog() }
        end
      end
    end # describe dialog

    describe 'convenience input methods on top of Windows API' do
      describe '#keystroke' do
        spec{ use{ keystroke( vkey = 30, char = 'Z') }}

        it 'emulates combinations of keys pressed (Ctrl+Alt+P+M, etc)' do
          keystroke(VK_CONTROL, 'A')
          keystroke(VK_SPACE)
          @app.textarea.text.should.should == ' '
          keystroke('1', '2', 'A', 'B'.ord)
          @app.textarea.text.should.should == ' 12ab'
        end
      end # describe '#keystroke'

      describe '#type_in' do
        it 'types text message into the window holding the focus' do
          text = '1234 abcdefg'
          type_in(text)
          @app.textarea.text.should =~ Regexp.new(text)
        end
      end # describe '#type_in'

    end # Input methods
  end # Convenience methods
end