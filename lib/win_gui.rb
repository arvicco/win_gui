win_gui_dir = File.join(File.dirname(__FILE__),"win_gui" )
$LOAD_PATH.unshift win_gui_dir unless $LOAD_PATH.include?(win_gui_dir)
require 'win_gui'