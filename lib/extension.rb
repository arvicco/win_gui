class String
  # converts one-char string into keyboard-scan 'Virtual key' code
  # TODO: only letters and numbers convertible so far, need to extend further
  def to_vkeys
    unless size == 1
      raise "Can't convert but a single character: #{self}"
    end
    ascii = upcase.unpack('C')[0]
    case self
      when 'a'..'z', '0'..'9', ' '
      [ascii]
      when 'A'..'Z'
      [0x10, ascii]    # Win.const_get(:VK_SHIFT) = 0x10 Bad coupling
    else
      raise "Can't convert unknown character: #{self}"
    end
  end
end
