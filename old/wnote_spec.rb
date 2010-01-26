describe 'The main window' do
  it 'launches with a welcome message' do
    note = Note.new
    note.text.should include('Welcome' )
    note.exit!
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