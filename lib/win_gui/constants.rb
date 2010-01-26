module WinGui
  
  # WinGui Module internal Constants:
  WG_KEY_DELAY = 0.00001 
  WG_SLEEP_DELAY = 0.001 
  WG_CLOSE_TIMEOUT = 1
  #WG_TEXT_BUFFER = '\0' * 2048
  
  # Windows keyboard-related Constants:
  #   Virtual key codes:
  VK_CANCEL   = 0x03 # Control-break processing
  VK_BACK     = 0x08
  VK_TAB      = 0x09
  VK_SHIFT    = 0x10
  VK_CONTROL  = 0x11
  VK_RETURN   = 0x0D #   ENTER key
  VK_ALT      = 0x12 #   ALT key
  VK_MENU     = 0x12 #   ALT key alias
  VK_PAUSE    = 0x13 #   PAUSE key
  VK_CAPITAL  = 0x14 #   CAPS LOCK key
  VK_ESCAPE   = 0x1B #   ESC key
  VK_SPACE    = 0x20 #   SPACEBAR
  VK_PRIOR    = 0x21 #   PAGE UP key
  VK_NEXT     = 0x22  #  PAGE DOWN key
  VK_END      = 0x23  #  END key
  VK_HOME     = 0x24  #  HOME key
  VK_LEFT     = 0x25  #  LEFT ARROW key
  VK_UP       = 0x26  #  UP ARROW key
  VK_RIGHT    = 0x27  #  RIGHT ARROW key
  VK_DOWN     = 0x28  #  DOWN ARROW key
  VK_SELECT   = 0x29  #  SELECT key
  VK_PRINT    = 0x2A  #  PRINT key
  VK_EXECUTE  = 0x2B  #  EXECUTE key
  VK_SNAPSHOT = 0x2C  #  PRINT SCREEN key
  VK_INSERT   = 0x2D  #  INS key
  VK_DELETE   = 0x2E  #  DEL key
  VK_HELP     = 0x2F  #  HELP key
  #   Key events:
  KEYEVENTF_KEYDOWN = 0 
  KEYEVENTF_KEYUP = 2 
  
  # Show Window Commands:
  SW_HIDE           = 0
  SW_NORMAL         = 1
  SW_SHOWNORMAL     = 1
  SW_SHOWMINIMIZED  = 2
  SW_SHOWMAXIMIZED  = 3
  SW_MAXIMIZE       = 3
  SW_SHOWNOACTIVATE = 4
  SW_SHOW           = 5
  SW_MINIMIZE       = 6
  SW_SHOWMINNOACTIVE= 7
  SW_SHOWNA         = 8
  SW_RESTORE        = 9
  SW_SHOWDEFAULT    = 10
  SW_FORCEMINIMIZE  = 11
  
  # Windows Messages Constants:
  WM_GETTEXT = 0x000D
  WM_SYSCOMMAND = 0x0112
  SC_CLOSE = 0xF060
  
  # Other Windows Constants:
end

