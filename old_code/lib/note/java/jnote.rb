require 'java'
require 'jemmy.jar'
require 'junquenote_app'

include_class 'org.netbeans.jemmy.JemmyProperties'
include_class 'org.netbeans.jemmy.TestOut'

%w(Frame TextArea MenuBar Dialog Button).each do |o| #(1)
  include_class "org.netbeans.jemmy.operators.J#{o}Operator"
end

JemmyProperties.set_current_timeout 'DialogWaiter.WaitDialogTimeout', 3000 #(2)
JemmyProperties.set_current_output TestOut.get_null_output #(3)

class Note
  def initialize
    JunqueNoteApp.new
    @main_window = JFrameOperator.new 'JunqueNote'
  end
  
  def type_in(text)
    edit = JTextAreaOperator.new @main_window
    edit.type_text text
  end
  
  def text
    edit = JTextAreaOperator.new @main_window
    edit.text
  end
  
  def exit!
    begin
      menu = JMenuBarOperator.new @main_window
      menu.push_menu_no_block 'File|Exit', '|'
      
      dialog = JDialogOperator.new "Quittin' time"
      button = JButtonOperator.new dialog, "No"
      button.push
      
      @prompted = true
    rescue
    end
  end
  
  def has_prompted?
    @prompted
  end
end