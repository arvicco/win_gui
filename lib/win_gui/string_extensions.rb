class String
  def snake_case
    gsub(/([a-z])([A-Z0-9])/, '\1_\2' ).downcase
  end

  def camel_case    
    if self.include? '_'
      self.split('_').map{|e| e.capitalize}.join
    else
      unless self =~ (/^[A-Z]/)
        self.capitalize
      else
        self
      end
    end
  end

  def to_w
    (self+"\x00").encode('utf-16LE')
  end

  def to_vkeys
    unless size == 1
      raise "Can't convert but a single character: #{self}"
    end
    ascii = upcase.unpack('C')[0]
    case self
      when 'a'..'z', '0'..'9', ' '
      [ascii]
      when 'A'..'Z'
      [WinGui.const_get(:VK_SHIFT), ascii]
    else
      raise "Can't convert unknown character: #{self}"
    end
  end
end