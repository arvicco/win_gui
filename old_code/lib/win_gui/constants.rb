module WinGui
  
  # Delay between key commands (events)
  WG_KEY_DELAY = 0.00001
  # Wait delay quant
  WG_SLEEP_DELAY = 0.001
  # Timeout waiting for Window to be closed
  WG_CLOSE_TIMEOUT = 1

  # Windows keyboard-related Constants:
  #   Virtual key codes:


  # Control-break processing
  VK_CANCEL   = 0x03
  #  Backspace? key
  VK_BACK     = 0x08
  #  Tab key
  VK_TAB      = 0x09
  #  Shift key
  VK_SHIFT    = 0x10
  #  Ctrl key
  VK_CONTROL  = 0x11
  #  ENTER key
  VK_RETURN   = 0x0D
  #  ALT key
  VK_ALT      = 0x12
  #  ALT key alias
  VK_MENU     = 0x12
  #  PAUSE key
  VK_PAUSE    = 0x13
  #  CAPS LOCK key
  VK_CAPITAL  = 0x14
  #  ESC key
  VK_ESCAPE   = 0x1B
  #  SPACEBAR
  VK_SPACE    = 0x20
  #  PAGE UP key
  VK_PRIOR    = 0x21
  #  PAGE DOWN key
  VK_NEXT     = 0x22
  #  END key
  VK_END      = 0x23
  #  HOME key
  VK_HOME     = 0x24
  #  LEFT ARROW key
  VK_LEFT     = 0x25
  #  UP ARROW key
  VK_UP       = 0x26
  #  RIGHT ARROW key
  VK_RIGHT    = 0x27
  #  DOWN ARROW key
  VK_DOWN     = 0x28
  #  SELECT key
  VK_SELECT   = 0x29
  #  PRINT key
  VK_PRINT    = 0x2A
  #  EXECUTE key
  VK_EXECUTE  = 0x2B
  #  PRINT SCREEN key
  VK_SNAPSHOT = 0x2C
  #  INS key
  VK_INSERT   = 0x2D
  #  DEL key
  VK_DELETE   = 0x2E
  #  HELP key
  VK_HELP     = 0x2F

  # Key down keyboard event
  KEYEVENTF_KEYDOWN = 0
  # Key up keyboard event
  KEYEVENTF_KEYUP = 2
  
  # Windows Message Get Text
  WM_GETTEXT = 0x000D
  # Windows Message Sys Command
  WM_SYSCOMMAND = 0x0112
  # Sys Command Close
  SC_CLOSE = 0xF060
  
end

