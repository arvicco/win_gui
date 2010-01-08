#---
# Excerpted from "Scripted GUI Testing With Ruby",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/idgtr for more book information.
#---
require 'spec_helper'

describe 'The main window' do
  it_should_behave_like 'a new document'
  
  it 'launches with a welcome message' do
    @note.text.should include('Welcome')
  end
  
  it 'exits without a prompt if nothing has changed' do
    @note.exit!
    @note.should_not have_prompted(:to_confirm_exit)
  end
  
  it 'prompts before exiting if the document has changed' do
    @note.text = 'changed'
    @note.exit!
    @note.should have_prompted(:to_confirm_exit)
  end
  
  it 'offers information about the program' do
    @note.about
    @note.should have_prompted(:with_help_text)
  end  
end

describe 'Saving a document for the first time' do
  it_should_behave_like 'a new document'
  
  it 'requires a password' do
    @note.save_as 'MyNote'
    @note.should have_prompted(:for_password)
  end
end

describe 'The password assignment prompt' do
  it_should_behave_like 'a new document'
  
  it 'ignores the new password if cancelled' do
    @note.text = 'changed'
    @note.save_as 'MyNote', :cancel_password => true
    @note.exit!
    @note.should have_prompted(:to_confirm_exit)
  end
  
  it 'ignores an unconfirmed password' do
    @note.text = 'changed'
    @note.save_as 'SavedNote', :confirmation => 'mismatch'
    @note.should have_prompted(:with_error)
    @note.exit!
    @note.should have_prompted(:to_confirm_exit)
  end
end

describe 'The password entry prompt' do
  it_should_behave_like 'a saved document'

  it 'ignores the password if cancelled' do
    note = Note.open 'SavedNote', :cancel_password => true
    note.should_not be_running
  end
  
  it 'exits with an error message for an invalid password' do
    note = Note.open 'SavedNote', :password => 'invalid'
    note.should_not be_running
    note.should have_prompted(:with_error)
  end
end

describe 'A previously saved document' do
  it_should_behave_like 'a saved document'
  it_should_behave_like 'a reopened document'
  
  it 'preserves and encrypts the contents of the file' do
    @note.text.should include('Welcome')
    IO.read(@note.path).should_not include('Welcome')
  end

  it 'does not require a password on subsequent saves' do
    @note.text = 'changed'
    @note.exit! :save_as => 'MyNote'
    @note.should_not have_prompted(:for_password)
  end
  
  it 'supports changing the password' do
    @note.change_password \
      :old_password => 'password',
      :password => 'new'
    @note.exit!
    
    @note = Note.open 'SavedNote', :password => 'new'
    @note.should_not have_prompted(:with_error)
    @note.should be_running
  end
end

describe 'The editor' do
  it_should_behave_like 'a new document'

  it 'supports multiple levels of undo' do
    @note.text = 'abc'
    
    @note.undo
    @note.text.should == 'ab'

    @note.undo
    @note.text.should == 'a'
  end
  
  it 'supports copying and pasting text' do
    @note.text = 'itchy'
    @note.select_all
    @note.copy
    @note.text.should == 'itchy'
    
    @note.text = 'scratchy'
    @note.select_all
    @note.paste
    @note.text.should == 'itchy'
  end
  
  it 'supports cutting and pasting text' do
    @note.text = 'pineapple'
    @note.select_all
    @note.cut
    @note.text.should be_empty
    
    @note.text = 'mango'
    @note.select_all
    @note.paste
    @note.text.should == 'pineapple'
  end
end

describe 'The Find window' do
  it_should_behave_like 'a new document'
  it_should_behave_like 'a searchable document'
  
  it 'supports searching forward' do
    @note.go_to :beginning
    @note.find @term
    @note.selection.begin.should == @first_match

    @note.find_next
    @note.selection.begin.should == @second_match
  end
  
  it 'supports searching backward' do
    @note.go_to :end
    @note.find @term, :direction => :back
    @note.selection.begin.should == @reverse_match
  end
  
  it 'can restrict its search to whole words' do
    pending 'on hold' do
      @note.go_to :beginning
      @note.find @term, :whole_word => true
      @note.selection.begin.should == @word_match
    end
  end
  
  it 'can restrict its search to exact case matches' do
    @note.go_to :beginning
    @note.find @term, :exact_case => true
    @note.selection.begin.should == @case_match   
  end
end
