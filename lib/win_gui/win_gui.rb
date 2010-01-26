require 'Win32/api'
require 'string_extensions'
require 'constants'
require 'def_api'
require 'window'

#  TODO - When calling API functions, win_handle arg should default to instance var @handle of the host class
#  TODO - Giving a hash of "named args" to def_api, like this:
#  TODO        def_api 'ShowWindow', 'LI' , 'I', :args=>{1=>:handle=>, 2=>[:cmd, :command]}
#  TODO - Giving a hash of "defaults" to def_api, like this:
#  TODO        def_api 'ShowWindow', 'LI' , 'I', :defaults=>{1=>1234, 2=>'String2'}
#  TODO - Option :class_method should define CLASS method instead of instance

module WinGui
  self.extend DefApi

  # Windows GUI API definitions:

  # Tests whether the specified window handle identifies an existing window.
  #   A thread should not use IsWindow for a window that it did not create because the window
  #   could be destroyed after this function was called. Further, because window handles are
  #   recycled the handle could even point to a different window.
  #
  def_api 'IsWindow', 'L', 'L'

  # Tests if the specified window, its parent window, its parent's parent window, and so forth,
  # have the WS_VISIBLE style. Because the return value specifies whether the window has the
  # WS_VISIBLE style, it may be true even if the window is totally obscured by other windows.
  #
  def_api 'IsWindowVisible', 'L', 'L', :alias => :visible?

  # Tests whether the specified window is maximized.
  #
  def_api 'IsZoomed', 'L', 'L', :alias => :maximized?

  # Tests whether the specified window is maximized.
  #
  def_api 'IsIconic', 'L', 'L', :alias => :minimized?

  # Tests whether a window is a child (or descendant) window of a specified parent window.
  # A child window is the direct descendant of a specified parent window if that parent window
  # is in the chain of parent windows; the chain of parent windows leads from the original overlapped
  # or pop-up window to the child window.
  #
  def_api 'IsChild', 'LL', 'L'

  # Retrieves a handle to the top-level window whose class and window name match the specified strings.
  #   This function does not search child windows. This function does not perform a case-sensitive search.
  # class_name (P) - String that specifies (window) class name OR class atom created by a previous
  #   call to the RegisterClass(Ex) function. The atom must be in the low-order word of class_name;
  #   the high-order word must be zero. The class name can be any name registered with RegisterClass(Ex),
  #   or any of the predefined control-class names. If this parameter is nil, it finds any window whose
  #   title matches the win_title parameter.
  # win_name (P) - String that specifies the window name (title). If nil, all names match.
  # returns (L) found window handle or NIL if nothing found
  #
  def_api 'FindWindow', 'PP', 'L', :zeronil => true

  # Unicode version of find_window (strings must be encoded as utf-16LE AND terminate with "\x00\x00")
  #
  def_api 'FindWindowW', 'PP', 'L', :zeronil => true

  # Retrieves a handle to a CHILD window whose class name and window name match the specified strings.
  #   The function searches child windows, beginning with the one following the specified child window.
  #   This function does NOT perform a case-sensitive search.
  # parent (L) - Handle to the parent window whose child windows are to be searched.
  #   If nil, the function uses the desktop window as the parent window.
  #   The function searches among windows that are child windows of the desktop.
  # after_child (L) - Handle to a child window. Search begins with the NEXT child window in the Z order.
  #   The child window must be a direct child window of parent, not just a descendant window.
  #   If after_child is nil, the search begins with the first child window of parent.
  # win_class (P), win_title (P) - Strings that specify window class and name(title). If nil, anything matches.
  # Returns (L) - found child window (control) handle or NIL if nothing found
  #
  def_api 'FindWindowEx', 'LLPP', 'L', :zeronil => true

  # Returns the text of the specified window's title bar (if it has one). If the specified window is
  #   a control, the text of the control is copied. However, GetWindowText cannot retrieve the text of
  #   a control in another application.
  # API improved to require only win_handle and return rstripped text
  # win_handle (L) - Handle to the window and, indirectly, the class to which the window belongs.
  # buffer (P) - Pointer to the buffer that will receive the text. If the string is as long or longer
  #   than the buffer, the string is truncated and terminated with a NULL character.
  # count (L) Specifies the maximum number of characters to copy to the buffer, including the NULL character.
  #   If the text exceeds this limit, it is truncated.
  # Returns (L) length, in characters, of the copied string, not including the terminating NULL character.
  #   If the window has no title bar or text, if the title bar is empty, or if the window or control handle
  #   is invalid, the return value is zero.
  # To get extended error information, call GetLastError.
  #
  # Remarks: This function CANNOT retrieve the text of an edit control in ANOTHER app.
  #   If the target window is owned by the current process, GetWindowText causes a WM_GETTEXT message to
  #   be sent to the specified window or control. If the target window is owned by another process and has
  #   a caption, GetWindowText retrieves the window caption text. If the window does not have a caption,
  #   the return value is a null string. This allows to call GetWindowText without becoming unresponsive
  #   if the target window owner process is not responding. However, if the unresponsive target window
  #   belongs to the calling app, GetWindowText will cause the calling app to become unresponsive.
  #   To retrieve the text of a control in another process, send a WM_GETTEXT message directly instead
  #   of calling GetWindowText.
  #
  def_api 'GetWindowText', 'LPI', 'L', &return_string

  # Unicode version of get_window_text (returns rstripped utf-8 string)
  # API improved to require only win_handle and return rstripped string
  #
  def_api 'GetWindowTextW', 'LPI', 'L', &return_string('utf-8')

  # Retrieves the name of the class to which the specified window belongs.
  # API improved to require only win_handle and return rstripped  string
  # win_handle (L) - Handle to the window and, indirectly, the class to which the window belongs.
  # class_name (P) - Pointer to the buffer that is to receive the class name string.
  # max_count (I) - Specifies the length, in TCHAR, of the buffer pointed to by the lpClassName parameter.
  #   The class name string is truncated if it is longer than the buffer and is always null-terminated.
  # Returns (I) - number of TCHAR copied to the specified buffer, if the function succeeds.
  #   Returns zero if function fails. To get extended error information, call GetLastError.
  #
  def_api 'GetClassName', 'LPI', 'I', &return_string

  # Unicode version of get_class_name (returns rstripped utf-8 string)
  # API improved to require only win_handle and return rstripped string
  #
  def_api 'GetClassNameW', 'LPI', 'I', &return_string('utf-8')

  # Retrieves the identifier of the thread that created the specified window and, optionally, the identifier
  #   of the process that created the window.
  # API improved to accept window handle as a single arg and return a pair of [thread, process] ids
  # handle (L) - Handle to the window.
  # process (P) - A POINTER to a (Long) variable that receives the process identifier.
  # Returns (L) - Identifier of the thread that created the window.
  #
  def_api 'GetWindowThreadProcessId', 'LP', 'L' do |api, *args|
    raise 'Invalid args count' unless args.size == api.prototype.size-1
    thread = api.call(args.first, process = [1].pack('L'))
    [thread] + process.unpack('L')
  end

  # Shows and hides windows.
  # handle (L) - Handle to the window.
  # cmd (I) - Specifies how the window is to be shown. This parameter is ignored the first time an
  #   application calls ShowWindow, if the program that launched the application provides a STARTUPINFO
  #  structure. Otherwise, the first time ShowWindow is called, the value should be the value obtained
  #  by the WinMain function in its nCmdShow parameter. In subsequent calls, cmd may be:
  #    SW_HIDE          - Hides the window and activates another window.
  #    SW_MAXIMIZE      - Maximizes the specified window.
  #    SW_MINIMIZE      - Minimizes the specified window, activates the next top-level window in the Z order.
  #    SW_SHOW          - Activates the window and displays it in its current size and position.
  #    SW_SHOWMAXIMIZED - Activates the window and displays it as a maximized window.
  #    SW_SHOWMINIMIZED - Activates the window and displays it as a minimized window.
  #    SW_SHOWMINNOACTIVE Displays the window as a minimized window. This value is similar to
  #                       SW_SHOWMINIMIZED, except the window is not activated.
  #    SW_SHOWNA        - Displays the window in its current size and position. This value is similar to
  #                       SW_SHOW, except the window is not activated.
  #    SW_SHOWNOACTIVATE- Displays a window in its most recent size and position. This value is similar to
  #                       SW_SHOWNORMAL, except the window is not actived.
  #    SW_SHOWNORMAL    - Activates and displays a window. If the window is minimized or maximized,
  #                       the system restores it to its original size and position. An application should
  #                       specify this flag when displaying the window for the first time.
  #    SW_RESTORE       - Activates and displays the window. If the window is minimized or maximized,
  #                       the system restores it to its original size and position. An application should
  #                       specify this flag when restoring a minimized window.
  #    SW_SHOWDEFAULT   - Sets the show state based on the SW_ value specified in the STARTUPINFO structure
  #                       passed to the CreateProcess function by the program that started the application.
  #    SW_FORCEMINIMIZE - Windows 2000/XP: Minimizes a window, even if the thread that owns the window
  #                       is not responding. Only use this flag when minimizing windows from a different thread.
  # Returns (I) - True if the window was PREVIOUSLY visible, otherwise false
  #
  def_api 'ShowWindow', 'LI', 'I', :boolean => true

  def hide_window(handle)
    show_window(handle, SW_HIDE)
  end

  # Retrieves the dimensions of the specified window bounding rectangle. Dimensions are given relative
  #   to the upper-left corner of the screen.
  # API improved to accept only window handle and return 4-member dimensions array (left, top, right, bottom)
  # handle (L) - Handle to the window, rectangle - pointer to 4-long array for coordinates
  #
  # Remarks: As a convention for the RECT structure, the bottom-right coordinates of the returned rectangle
  #   are exclusive. In other words, the pixel at (right, bottom) lies immediately outside the rectangle.
  #
  def_api 'GetWindowRect', 'LP', 'I' do |api, *args|
    raise 'Invalid args count' unless args.size == api.prototype.size-1
    rectangle = [0, 0, 0, 0].pack 'L*'
    api.call args.first, rectangle
    rectangle.unpack 'l*'
  end

  def_api 'keybd_event', 'IILL', 'V'
  def_api 'PostMessage', 'LLLL', 'L'
  def_api 'SendMessage', 'LLLP', 'L'
  def_api 'GetDlgItem', 'LL', 'L'

  # The EnumWindows function enumerates all top-level windows on the screen by passing the handle to
  #   each window, in turn, to an application-defined callback function. EnumWindows continues until
  #   the last top-level window is enumerated or the callback function returns FALSE.
  # API improved to accept blocks (instead of callback objects) and message as a single arg
  # callback [K] - Pointer to an application-defined callback function (see EnumWindowsProc).
  # message [P] - Specifies an application-defined value(message) to be passed to the callback function.
  # Returns: Nonzero if the function succeeds, zero if the function fails (GetLastError for more error info).
  #   If callback returns zero, the return value is also zero. In this case, the callback function should
  #   call SetLastError to obtain a meaningful error code to be returned to the caller of EnumWindows.
  #
  # Remarks: The EnumWindows function does not enumerate child windows, with the exception of a few top-level
  #   windows owned by the system that have the WS_CHILD style. This function is more reliable than calling
  #   the GetWindow function in a loop. An application that calls GetWindow to perform this task risks being
  #   caught in an infinite loop or referencing a handle to a window that has been destroyed.
  #
  def_api 'EnumWindows', 'KP', 'L', &return_enum

  # Enumerates child windows to a given window.
  # parent (L) - Handle to the parent window whose child windows are to be enumerated.
  #   If it is nil, this function is equivalent to EnumWindows. Windows 95/98/Me: parent cannot be NULL.
  # API improved to accept blocks (instead of callback objects) and two args: parent handle and message.
  # callback (K) - Pointer to an application-defined callback function (see EnumChildProc).
  # message (P) - Specifies an application-defined value(message) to be passed to the callback function.
  # Returns (L) -  Not used (?!)
  #   If a child window has created child windows of its own, EnumChildWindows enumerates those windows as well.
  #   A child window that is moved or repositioned in the Z order during the enumeration process will be properly enumerated.
  #   The function does not enumerate a child window that is destroyed before being enumerated or that is created during the enumeration process.
  def_api 'EnumChildWindows', 'LKP', 'L', &return_enum

  def_api 'GetForegroundWindow', 'V', 'L'
  def_api 'GetActiveWindow', 'V', 'L'


  # Convenience wrapper methods:

  # emulates combinations of keys pressed (Ctrl+Alt+P+M, etc)
  def keystroke(*keys)
    return if keys.empty?
    keybd_event keys.first, 0, KEYEVENTF_KEYDOWN, 0
    sleep WG_KEY_DELAY
    keystroke *keys[1..-1]
    sleep WG_KEY_DELAY
    keybd_event keys.first, 0, KEYEVENTF_KEYUP, 0
  end

  # types text message into window holding the focus
  def type_in(message)
    message.scan(/./m) do |char|
      keystroke(*char.to_vkeys)
    end
  end

  # finds top-level dialog window by title and yields it to given block
  def dialog(title, seconds=3)
    d = begin
      win = Window.top_level(title, seconds)
      yield(win) ? win : nil
    rescue TimeoutError
    end
    d.wait_for_close if d
    return d
  end
end