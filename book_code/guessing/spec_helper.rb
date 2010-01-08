#---
# Excerpted from "Scripted GUI Testing With Ruby",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/idgtr for more book information.
#---

require 'rubygems'
require 'hpricot'
require 'open-uri'

module RandomHelper
  def random_paragraph
    doc = Hpricot open('http://www.lipsum.com/feed/html?amount=1')
    (doc/"div#lipsum p").inner_html.strip #(1)
  end
end


describe 'a new document', :shared => true do
  before do
    @note = Note.open
  end
  
  after do
    @note.exit! if @note.running?
  end
end

describe 'a saved document', :shared => true do
  before do
    Note.fixture 'SavedNote'
  end
end

describe 'a reopened document', :shared => true do  
  before do
    @note = Note.open 'SavedNote'
  end
  
  after do
    @note.exit! if @note.running?
  end
end  


describe 'a searchable document', :shared => true do
  include RandomHelper #(2)

  before do
    @example = random_paragraph #(3)       
    
    words = @example.split /[^A-Za-z]+/
    last_cap = words.select {|w| w =~ /^[A-Z]/}.last
    @term = last_cap[0..1] #(4)

    @first_match = @example.index(/#{@term}/i)
    @second_match = @first_match ?
      @example.index(/#{@term}/i, @first_match + 1) :
      nil
    @reverse_match = @example.rindex(/#{@term}/i)
    @word_match = @example.index(/#{@term}\b/i)
    @case_match = @example.index(/#{@term}/)    

    @note.text = @example
  end
end
