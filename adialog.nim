import winim/mean

proc openDialog*(title: string): string =
    var
        buffer=T(MAX_PATH)
        o = OPENFILENAME(
            lStructSize: OPENFILENAME.sizeof.int32,
            lpstrTitle: T(title),
            lpstrFile: &buffer,
            lpstrFilter: "Nim Files\0*.nim\0All Files\0*.*\0",
            nMaxFile: MAX_PATH,
            Flags: OFN_EXPLORER)

    if GetOpenFileName(o):
        result = $buffer

proc getCLassName*(parent: HWND, child: int32):wstring =
    var
        option:UINT
    
        control = GetDlgItem(parent,child)
        buffer=T(256)
        classname = GetClassName(control,&buffer,256)

    buffer.setlen(classname) 
    return buffer

proc add* (parent:HWND, child: int32, txt:string)=
    var
        option:UINT

    case getCLassName(parent,child)
        of T("ComboBox"):  option = CB_ADDSTRING
        else:
            discard

    SendDlgItemMessage(parent, child, option, 0, cast[LPARAM](newWideCString(txt)))

proc setText* (parent: HWND, child: int32, txt:string) =
        SetDlgItemText(parent, child, txt)

proc setAppIcon* (parent: HWND, icon: int32) =
    SendMessage(parent, WM_SETICON, ICON_SMALL, LoadIcon(GetModuleHandle(nil), MAKEINTRESOURCE(icon)))
    SendMessage(parent, WM_SETICON, ICON_BIG, LoadIcon(GetModuleHandle(nil), MAKEINTRESOURCE(icon)))

proc getSelection* (parent: HWND, child: int32): wstring =
    # BUFFER TO HOLD SELECTION
    var cb_buffer=T(MAX_PATH)

    # CURRENT SELECTED ITEM INDEX
    let current_selection = SendDlgItemMessage(parent, child, CB_GETCURSEL, 0, 0)

    # PLACE SELECTED ITEM INTO OUR BUFFER
    SendDlgItemMessage(parent, child, CB_GETLBTEXT, current_selection, cast[LPARAM](&cb_buffer))

    return cb_buffer
