# encoding: UTF-8
libdir = File.join(File.dirname(__FILE__), "lib" )
$LOAD_PATH.unshift libdir unless $LOAD_PATH.include?(libdir)
require 'spec/spec_helper'

module Quik
  include WinGui
  extend WinGui
  include GuiTest

  QUIK_APP_PATH = ['C:\Program Files\Info', '\info.exe']
  QUIK_APP_START = 'start "" "' + QUIK_APP_PATH.join + '"'
  QUIK_MAIN_CLASS = 'InfoClass'
  QUIK_DIALOG_CLASS = '#32770'
  QUIK_DIALOG_TITLE = 'Идентификация пользователя'
  system 'cd "' + QUIK_APP_PATH.first + '"'
  system QUIK_APP_START
  handle = 0
  timeout(20) do
    sleep TEST_SLEEP_DELAY until (handle = find_window(QUIK_MAIN_CLASS, nil))
  end
  p handle
  quik = Window.new handle
  sleep 1
  p visible? quik.handle
#  hide_window(quik.handle)
  p window? quik.handle
  p visible? quik.handle
  p QUIK_DIALOG_TITLE#.force_encoding('CP1251')
  p title = QUIK_DIALOG_TITLE.encode('CP1251')
  dialog( title, 1) do |dlg|
    child = dlg.child 'ComboLBox'
    p 'Found!', child.handle
  end
#  quik.close
#  quik.wait_for_close

end