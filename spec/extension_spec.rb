# encoding: UTF-8
require_relative "spec_helper.rb"

module WinGuiTest

  describe String do
    describe '#to_key' do
      it 'transforms number char into [equivalent key code]' do
        ('0'..'9').each {|char| char.to_key.should == char.unpack('C')}
      end

      it 'transforms uppercase letters into [shift, equivalent key code]' do
        ('A'..'Z').each {|char| char.to_key.should == [0x10, *char.unpack('C')]}
      end

      it 'transforms lowercase letters into [(upcase) key code]' do
        ('a'..'z').each {|char| char.to_key.should == char.upcase.unpack('C')}
      end

      it 'transforms space into [equivalent key code]' do
        ' '.to_key.should == " ".unpack('C')
      end

      it 'transforms \n into [VK_RETURN]' do
        "\n".to_key.should == [VK_RETURN]
      end

      it 'transforms .,:;\\ into [equivalent key code]' do
        ','.to_key.should == [VK_OEM_COMMA]
        '.'.to_key.should == [VK_OEM_PERIOD]
        ':'.to_key.should == [VK_SHIFT, VK_OEM_1]
        ';'.to_key.should == [VK_OEM_1]
        "\\".to_key.should == [VK_OEM_102]
      end

      it 'raises error if char is not implemented punctuation' do
        ('!'..'+').each {|char| lambda {char.to_key}.should raise_error ERROR_CONVERSION }
        (']'..'`').each {|char| lambda {char.to_key}.should raise_error ERROR_CONVERSION }
        ('{'..'~').each {|char| lambda {char.to_key}.should raise_error ERROR_CONVERSION }
        ['-', '/', '['].each {|char| lambda {char.to_key}.should raise_error ERROR_CONVERSION }
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

    describe '#to_print' do
      it 'converts String from (implied) WinCyrillic (CP1251) to default output encoding' do
        string = "Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства"
        win_string = string.encode('cp1251')
        print_string = win_string.encode(Encoding.default_external, :undef => :replace)
        win_string_thought_utf8 = win_string.force_encoding('utf-8')
        win_string_thought_dos = win_string.force_encoding('cp866')

        win_string_thought_utf8.to_print.should == print_string
        win_string_thought_dos.to_print.should == print_string
      end

    end
  end
end
