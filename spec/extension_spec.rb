require File.join(File.dirname(__FILE__), "spec_helper" )

module WinGuiTest

  describe String do
    context '#to_key' do
      it 'transforms number char into [equivalent key code]' do
        ('0'..'9').each {|char| char.to_key.should == char.unpack('C')}
      end

      it 'transforms uppercase letters into [shift, equivalent key code]' do
        ('A'..'Z').each {|char| char.to_key.should == [0x10, *char.unpack('C')]}
        # Win.const_get(:VK_SHIFT) = 0x10 Bad coupling
      end

      it 'transforms lowercase letters into [(upcase) key code]' do
        ('a'..'z').each {|char| char.to_key.should == char.upcase.unpack('C')}
      end

      it 'transforms space into [equivalent key code]' do
        ' '.to_key.should == " ".unpack('C')
      end

      it 'transforms .,:\\ into [equivalent key code]' do
        ','.to_key.should == [WinGui.const_get(:VK_OEM_COMMA)]
        '.'.to_key.should == [WinGui.const_get(:VK_OEM_PERIOD)]
        ':'.to_key.should == [:VK_SHIFT, :VK_OEM_1].map {|s| WinGui.const_get s}
        "\\".to_key.should == [WinGui.const_get(:VK_OEM_102)]
      end
      
      it 'raises error if char is not implemented punctuation' do
        ('!'..'+').each {|char| lambda {char.to_key}.should raise_error ERROR_CONVERSION }
        (';'..'@').each {|char| lambda {char.to_key}.should raise_error ERROR_CONVERSION }
        (']'..'`').each {|char| lambda {char.to_key}.should raise_error ERROR_CONVERSION }
        ('{'..'~').each {|char| lambda {char.to_key}.should raise_error ERROR_CONVERSION }
        ['-','/', '['].each {|char| lambda {char.to_key}.should raise_error ERROR_CONVERSION }
      end

      it 'raises error if char is non-printable or non-ascii' do
        lambda {1.chr.to_key}.should raise_error ERROR_CONVERSION
        lambda {230.chr.to_key}.should raise_error ERROR_CONVERSION
      end

      it 'raises error if string is multi-char' do
        lambda {'hello'.to_key}.should raise_error ERROR_CONVERSION
        lambda {'23'.to_key}.should raise_error ERROR_CONVERSION
      end
    end
  end
end
