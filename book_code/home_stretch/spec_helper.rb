#---
# Excerpted from "Scripted GUI Testing With Ruby",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/idgtr for more book information.
#---

describe 'a new document', :shared => true do #(1)
  before do                                   #(2)
    @note = Note.open
  end
  
  after do                                    #(3)
    @note.exit! if @note.running?             #(4)
  end
end



describe 'a saved document', :shared => true do
  before do
    Note.fixture 'SavedNote'                  #(5)
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
  before do
    @example = 'The longest island is Isabel Island.'
    @term = 'Is'

    @first_match = @example.index(/Is/i)
    @second_match = @example.index(/Is/i, @first_match + 1)
    @reverse_match = @example.rindex(/Is/i)
    @word_match = @example.index(/Is\b/i)
    @case_match = @example.index(/Is/)    

    @note.text = @example
  end
end
