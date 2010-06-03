class String
  # converts one-char string into keyboard-scan 'Virtual key' code
  # TODO: only letters and numbers convertible so far, need to extend further
  def to_key
    unless size == 1
      raise "Can't convert but a single character: #{self}"
    end
    ascii = upcase.unpack('C')[0]
#    puts "I'm here with #{self}->#{ascii}"
    case self
      when 'a'..'z', '0'..'9', ' '
        [ascii]
      when 'A'..'Z'
        [WinGui.const_get(:VK_SHIFT), ascii]
      when ','
        [WinGui.const_get(:VK_OEM_COMMA)]
      when '.'
        [WinGui.const_get(:VK_OEM_PERIOD)]
      when ':'
        [:VK_SHIFT, :VK_OEM_1].map {|s| WinGui.const_get s}
      when "\\"
        [WinGui.const_get(:VK_OEM_102)]
      else
        raise "Can't convert unknown character: #{self}"
    end
  end

  def to_print
    force_encoding('cp1251').encode(Encoding.default_external, :undef => :replace)
  end
end
