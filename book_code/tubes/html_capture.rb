#---
# Excerpted from "Scripted GUI Testing With Ruby",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/idgtr for more book information.
#---

require 'spec/runner/formatter/html_formatter'

Spec::Runner.configure do |config|
  config.before :all do
    $example_num = 1
  end

  config.after do
    `screencapture #{$example_num}.png` #(1)
    $example_num += 1
  end
end




class HtmlCapture < Spec::Runner::Formatter::HtmlFormatter
  def extra_failure_content(failure)
    img = %Q(<img src="#{example_number}.png"
                  alt="" width="25%" height="25%" />)
    super(failure) + img
  end
end

