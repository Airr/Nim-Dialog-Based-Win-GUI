import winim/mean, strutils

# {.link: "resource.res".}
# {.passL: "-s".}

const
  DLG_MAIN*     =   100
  IDI_ICON1*    =   101
  IDC_EDIT1*    =   40000
  IDC_SLIDER1*  =   40001
  IDC_COMBO1*   =   40002
  IDC_CHECKBOX1* =  40003
  IDC_RICHEDIT1* =  40004
  IDC_BUTTON_OPEN* = 40005


proc openDialog(title: string): string =
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

        

proc DialogProc(hwndDlg: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): INT_PTR {.stdcall.} =

    case uMsg
        of WM_COMMAND:
            case LOWORD(wParam)
                # OPEN BUTTON CLICKED
                of IDC_BUTTON_OPEN:

                    # LAUNCH OPEN FILE DIALOG
                    var fileName = openDialog("Load Nim Source File")

                    # CHECK IF VALID FILENAME
                    if fileName.len > 0:

                        # SET THE TEXT ENTRY WITH THE FILENAME
                        SetDlgItemText(hwndDlg, IDC_EDIT1, fileName)

                        # LOAD FILENAME INTO STRING
                        var text = readFile(fileName)

                        # SET THE CONTENTS OF THE RICHEDIT
                        SetDlgItemText(hwndDlg, IDC_RICHEDIT1, text)

                    # WE HANDLED THIS MESSAGE SO LET
                    # RUNLOOP KNOW IT'S HANDLED
                    return TRUE

                # COMBOBOX ACTIVATED
                of IDC_COMBO1:
                    case HIWORD(wParam):
                        # SELECTION CHANGED
                        of CBN_SELCHANGE:
                            # BUFFER TO HOLD SELECTION
                            var cb_buffer=T(MAX_PATH)

                            # CURRENT SELECTED ITEM INDEX
                            let current_selection = SendDlgItemMessage(hwndDlg, IDC_COMBO1, CB_GETCURSEL, 0, 0)

                            # PLACE SELECTED ITEM INTO OUR BUFFER
                            SendDlgItemMessage(hwndDlg, IDC_COMBO1, CB_GETLBTEXT, current_selection, cast[LPARAM](&cb_buffer))

                            # SET THE TEXT ENTRY WITH THE SELECTED ITEM
                            SetDlgItemText(hwndDlg, IDC_EDIT1, cb_buffer)

                            return TRUE
                        else:
                            return FALSE
                else:
                    return FALSE
    
        of WM_CLOSE:
            # TERMINATE THE DIALOG WHEN
            # IT'S WINDOW IS CLOSED
            EndDialog(hwndDlg,0)
            return TRUE

        of WM_INITDIALOG:
            # SET APPLICATION ICON
            # SendMessage IS USED HERE SINCE IT IS THE PARENT WINDOW / DIALOG
            SendMessage(hwndDlg, WM_SETICON, ICON_SMALL, LoadIcon(GetModuleHandle(nil), MAKEINTRESOURCE(IDI_ICON1)))
            SendMessage(hwndDlg, WM_SETICON, ICON_BIG, LoadIcon(GetModuleHandle(nil), MAKEINTRESOURCE(IDI_ICON1)))
            
            # POPULATE COMBOBOX AND SET DEFAULT ITEM
            # SendDlgItemMessage IS USED HERE BECAUSE THE ComboBox
            # IS A CHILD OF THE PARENT WINDOW / DIALOG
            for txt in "Apples Oranges Cherries Tangerines".split:
                SendDlgItemMessage(hwndDlg, IDC_COMBO1, CB_ADDSTRING, 0, cast[LPARAM](newWideCString(txt)))
            SendDlgItemMessage(hwndDlg, IDC_COMBO1, CB_SETCURSEL, 2, 0)

            return TRUE;

        of WM_DESTROY:
            # GRACEFULLY END THE APP INSTANCE
            PostQuitMessage(0)
            return TRUE
        
        else:
            return FALSE

proc main(): INT_PTR =
    
    # GET HANDLE TO APPLICATION INSTANCE
    var hInstance = GetModuleHandle(nil)

    # WE NEED THIS FOR THE RICHEDIT OBJECT
    LoadLibrary("Riched20.dll")

    # INITIALIZE WINDOWS THEME SUPPORT
    # FOR THIS APPLICATION
    InitCommonControls() 

    # LAUNCH THE GUI
    result = DialogBox(hInstance, MAKEINTRESOURCE(DLG_MAIN), 0, DialogProc)

discard main()