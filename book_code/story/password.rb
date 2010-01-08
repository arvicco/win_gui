#---
# Excerpted from "Scripted GUI Testing With Ruby",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/idgtr for more book information.
#---

require 'rubygems'
require 'spec/story'

steps_for :app_state do #(1)
  Given 'a new document' do
    @note = Note.open
  end

  When 'I exit the app' do
    @note.exit!
  end

  Then 'the app should be running' do
    @note.should be_running
  end
end




steps_for :documents do
  When 'I type "$something"' do |something|
    @note.text = something
  end  

  When 'I save the document as "$name" with password "$password"' do  #(2)
    |name, password|
    @note.save_as name, :password => password
  end
  
  When 'I open the document "$name" with password "$password"' do
    |name, password|
    @note = Note.open name, :password => password
  end

  When 'I change the password from "$old" to "$password"' do
    |old, password|
    @note.change_password :old_password => old, :password => password
  end

  Then 'the text should be "$something"' do |something|
    @note.text.should == something
  end
end




with_steps_for :app_state, :documents do
  run 'password.story'
end

