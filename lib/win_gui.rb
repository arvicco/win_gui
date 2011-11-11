require 'version'
require 'extension'
require 'timeout'

module WinGui
  module Errors # :nodoc:
    class InitError < RuntimeError # :nodoc:
    end
  end
end # module WinGui

require 'win_gui/convenience'
require 'win_gui/window'
require 'win_gui/app'
