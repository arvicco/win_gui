require File.join(File.dirname(__FILE__), ".." , "spec_helper" )

module GuiTest

  describe String do
    context '#snake_case' do
      it 'transforms CamelCase strings' do
        'GetCharWidth32'.snake_case.should == 'get_char_width_32'
      end
      
      it 'leaves snake_case strings intact' do
        'keybd_event'.snake_case.should == 'keybd_event'
      end
    end

    context '#to_w' do
      it 'transcodes string to utf-16LE' do
        'GetCharWidth32'.to_w.encoding.name.should == 'UTF-16LE'
      end
      
      it 'ensures that encoded string is null-terminated' do
        'GetCharWidth32'.to_w.bytes.to_a[-2..-1].should == [0, 0]
      end
    end
    
    context '#to_vkeys' do
      it 'transforms number char into [equivalent key code]' do
       ('0'..'9').each {|char| char.to_vkeys.should == char.unpack('C')}
      end
      
      it 'transforms uppercase letters into [shift, equivalent key code]' do
       ('A'..'Z').each {|char| char.to_vkeys.should == [VK_SHIFT, char.unpack('C')[0]]}
      end
      
      it 'transforms lowercase letters into [(upcase) key code]' do
       ('a'..'z').each {|char| char.to_vkeys.should == char.upcase.unpack('C')}
      end
      
      it 'transforms space into [equivalent key code]' do 
        " ".to_vkeys.should == ' '.unpack('C')
      end
      
      it 'raises error if char is not implemented punctuation' do
       ('!'..'/').each {|char| lambda {char.to_vkeys}.should raise_error TEST_ERROR_CONVERSION}
       (':'..'@').each {|char| lambda {char.to_vkeys}.should raise_error TEST_ERROR_CONVERSION }
       ('['..'`').each {|char| lambda {char.to_vkeys}.should raise_error TEST_ERROR_CONVERSION }
       ('{'..'~').each {|char| lambda {char.to_vkeys}.should raise_error TEST_ERROR_CONVERSION }
      end
      
      it 'raises error if char is non-printable or non-ascii' do
        lambda {1.chr.to_vkeys}.should raise_error TEST_ERROR_CONVERSION
        lambda {230.chr.to_vkeys}.should raise_error TEST_ERROR_CONVERSION
      end
      
      it 'raises error if string is multi-char' do
        lambda {'hello'.to_vkeys}.should raise_error TEST_ERROR_CONVERSION
        lambda {'23'.to_vkeys}.should raise_error TEST_ERROR_CONVERSION
      end  
    end
  end
end