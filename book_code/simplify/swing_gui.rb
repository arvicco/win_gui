#---
# Excerpted from "Scripted GUI Testing With Ruby",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/idgtr for more book information.
#---
require 'java'
require 'jemmy.jar'

include_class 'org.netbeans.jemmy.JemmyProperties'
include_class 'org.netbeans.jemmy.TestOut'

JemmyProperties.set_current_output TestOut.get_null_output

%w(Frame TextArea MenuBar Dialog Button).each do |o|
  include_class "org.netbeans.jemmy.operators.J#{o}Operator"
end


class JDialogOperator
  def click(title)
    b = JButtonOperator.new self, title.gsub('_', '') #(1)
    b.push
  end
end



module SwingGui
  def dialog(title, seconds=3)
    JemmyProperties.set_current_timeout \
      'DialogWaiter.WaitDialogTimeout', seconds * 1000
    
    begin
      d = JDialogOperator.new title
      yield d #(2)
      d.wait_closed
      
      true
    rescue NativeException
    end
  end
end
