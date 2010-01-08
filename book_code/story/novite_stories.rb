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
require 'chronic'
require 'party'

class Listener
  attr_reader :browser
  
  def run_started(num_scenarios)
    @browser = Selenium::SeleniumDriver.new \
      'localhost', 4444, '*firefox', 'http://localhost:3000', 10000
    @browser.start
  end

  def run_ended
    @browser.stop
  end
  
  def method_missing(name, *args, &block)
    # We don't care about the rest of the Story Runner events.
  end
end

listener = Listener.new
Spec::Story::Runner.register_listener(listener)




steps_for :planning do
  Given 'a party called "$name"' do |name|
    @party = Party.new(listener.browser)
    @party.name = name
  end

  Given 'a description of "$desc"' do |desc|
    @party.description = desc
  end
  
  Given 'a location of "$loc"' do |loc|
    @party.location = loc
  end
  
  Given /an? $event time of $sometime/ do |event, sometime|   #(1)
    clean = sometime.gsub ',', ' '
    date_time = Chronic.parse clean, :now => Time.now - 86400 #(2)

    if event == 'starting'
      @party.begins_at = date_time
    else
      @party.ends_at = date_time
    end
  end

  When 'I view the invitation' do
    @party.save_and_view
  end
end




steps_for :reviewing do
  Then 'the $setting should be "$value"' do |setting, value|
    @party.send(setting).should == value
  end

  Then 'the party should $event on $date_time' do |event, date_time|
    actual_time =
      (event == 'begin') ?
      @party.begins_at :
      @party.ends_at

    clean = date_time.gsub ',', ' '
    expected_time = Chronic.parse clean, :now => Time.now - 86400
    
    actual_time.should == expected_time
  end
  
  Then 'I should see the Web address to send to my friends' do
    @party.link.should match(%r{^http://})
  end
end




steps_for :rsvp do
  Then 'I should see the party details' do
    @party.should have_name
    @party.should have_description
    @party.should have_location
    @party.should have_times
  end
  
  When /I answer that "$guest" will( not)? attend/ do |guest, answer|
    attending = !answer.include?('not')
    @party.rsvp guest, attending
  end

  Then 'I should see "$guest" in the list of $type' do |guest, type|
    want_attending = (type == 'partygoers')
    @party.responses(want_attending).should include(guest)
  end
end




steps_for :email do
  Given 'a guest list of "$list"' do |list|
    @party.recipients = list
  end
  
  Then 'I should see that e-mail was sent to "$list"' do |list|
    @party.notice.include?(list).should be_true
  end

  When 'I view the e-mail that was sent to "$address"' do |address|
    @email = @party.email_to address
  end
  
  Then 'I should see "Yes/No" links' do
    @email.should match(%r{Yes - http://})
    @email.should match(%r{No - http://})
  end
  
  When 'I follow the "$answer" link' do |answer|
    link = %r{#{answer} - (http://.+)}.match(@email)[1]
    @party.rsvp_at link
  end
end




with_steps_for :planning, :reviewing do
  run 'invite.story'
end




with_steps_for :planning, :reviewing, :rsvp, :email do
  run 'rsvp.story'
end

