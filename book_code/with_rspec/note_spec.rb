#---
# Excerpted from "Scripted GUI Testing With Ruby",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/idgtr for more book information.
#---
describe 'The main window' do
  
  it 'launches with a welcome message' do
    note = Note.new                     #(1)
    note.text.should include('Welcome') #(2)
    note.exit!                          #(3)
  end
  
  
  
  it 'exits without a prompt if nothing has changed' do
    note = Note.new
    note.exit!
    note.should_not have_prompted
  end
  
  it 'prompts before exiting if the document has changed' do
    note = Note.new
    note.type_in "changed"
    note.exit!
    note.should have_prompted
  end
  
end
