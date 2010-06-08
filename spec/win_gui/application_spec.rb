require File.join(File.dirname(__FILE__), "..", "spec_helper" )

module WinGuiTest

  describe Application do
#    before(:each) { @app = launch_test_app }
#    after(:each){ close_test_app }

    context 'initializing' do
      it 'starts new application if asked to'
      it 'wraps around running application if asked to'
      it 'raises error if not able to start/find application'
      it 'has properties:'
#      it 'can be wrapped around any existing window' do
#        any_handle = find_window(nil, nil)
#        use{ Window.new any_handle }
#      end
    end

    context 'manipulating' do
      it 'exits application gracefully'
    end
  end
end
