require File.join(File.dirname(__FILE__), "..", "spec_helper" )

module WinGuiTest

  describe 'Convenience methods' do
    before(:each){ @app = launch_test_app }
    after(:each) { close_test_app }

    describe '#dialog' do
      before(:each){ keystroke(VK_ALT, 'F', 'A') }  # Open "Save as" modal dialog
      after(:each) { keystroke(VK_ESCAPE) }                 # Close modal dialog if it is opened

      it 'returns top-level dialog window with given title if no block attached' do
        dialog_window = dialog(DIALOG_TITLE, 0.1)
        dialog_window.should_not == nil
        dialog_window.should be_a Window
        dialog_window.text.should == DIALOG_TITLE
      end

      it 'yields found dialog window to block if block is attached' do
        dialog(DIALOG_TITLE, 0.1) do |dialog_window|
          dialog_window.should_not == nil
          dialog_window.should be_a Window
          dialog_window.text.should == DIALOG_TITLE
        end
      end

      it 'returns nil if there is no dialog with given title' do
        dialog(IMPOSSIBLE, 0.1).should == nil
      end

      it 'yields nil to attached block if no dialog found' do
        dialog(IMPOSSIBLE, 0.1) do |dialog_window|
          dialog_window.should == nil
        end
      end

      it 'considers timeout argument optional' do
        dialog_window = dialog(DIALOG_TITLE)
        dialog_window.text.should == DIALOG_TITLE
      end
    end # describe dialog

    describe 'convenience input methods on top of Windows API' do
      describe '#keystroke' do
        spec{ use{ keystroke( vkey = 30, char = 'Z') }}

        it 'emulates combinations of keys pressed (Ctrl+Alt+P+M, etc)' do
          keystroke(VK_CONTROL, 'A'.ord)
          keystroke(VK_SPACE)
          @app.textarea.text.should.should == ' '
          2.times {keystroke(VK_CONTROL, 'Z'.ord)} # rolling back changes to allow window closing without dialog!
        end
      end # describe '#keystroke'

      describe '#type_in' do
        it 'types text message into the window holding the focus' do
          text = '12 34'
          type_in(text)
          @app.textarea.text.should =~ Regexp.new(text)
          5.times {keystroke(VK_CONTROL, 'Z')} # rolling back changes to allow window closing without dialog!
        end
      end # describe '#type_in'

    end # Input methods

  end
end