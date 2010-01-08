libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift libdir unless $LOAD_PATH.include?(libdir)

# Abstract Note class (to be subclassed)
class Note
  @@app = nil
  @@titles = {}

  def self.open
    @@app.new
  end
end

require 'note/win/locknote'
#require 'note/java/junquenote'
