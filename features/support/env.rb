$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'win_gui'
require 'spec/expectations'
require 'spec/stubs/cucumber'

require 'pathname'
BASE_PATH = Pathname.new(__FILE__).dirname + '../..'
