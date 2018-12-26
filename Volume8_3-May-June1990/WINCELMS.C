/* 
 * Miscellaneous segment for the Windows cellular automaton demo
 *
 * Written by Bill Hall
 * 3665 Benton Street, #66
 * Santa Clara, CA 95051
 *
 */

#define NOCOMM
#define NOKANJI
#define NOATOM
#define NOSOUND
#define NOMINMAX
#include <windows.h>
#include <stdlib.h>

#include "wincel.h"
#include "wcldlg.h"

static void NEAR InitParamBox(HWND hDlg);
static void NEAR SetParamBox(HWND hDlg);

/* utility function to open a modal dialog box */
BOOL OpenDlgBox(HWND hWnd, FARPROC fpProc, WORD boxnum)
{

    FARPROC fp;
    BOOL result;

  /* make a proc instance for the about box window function */
    fp = MakeProcInstance(fpProc, hInst);
  /* create a modal dialog box */
    result = DialogBox(hInst, MAKEINTRESOURCE(boxnum),hWnd,fp);
    FreeProcInstance(fp);
    return result;

}

/* This is the window proc for the about box when it is displayed */
BOOL FAR PASCAL AboutBoxProc(HWND hDlg,unsigned message,WORD wParam,LONG lParam)
{

    switch (message) {

      /* nothing to initialize */
	case WM_INITDIALOG:
	    break;

      /* this dialog box has only an OK button */
	case WM_COMMAND:
	    switch (wParam) {
		case IDOK:
		case IDCANCEL:
		/* destroy the dialog box */
		    EndDialog(hDlg,TRUE);
		    break;
		default:
		    return FALSE;		/* we did not process */
	    }
	    break;
	    
	default:
	    return FALSE;
    }
    return TRUE;		/* we processed message */
}

BOOL FAR PASCAL ParamBoxProc(HWND hDlg,unsigned message,WORD wParam,LONG lParam)
{

    switch (message) {

	case WM_INITDIALOG:
	    InitParamBox(hDlg);
	    break;

	case WM_COMMAND:
	    switch (wParam) {
		/* OK selected */
		case IDOK:
		    SetParamBox(hDlg);
		    EndDialog(hDlg,TRUE);
		    break;
		/* destroy the dialog box */
		case IDCANCEL:
		    EndDialog(hDlg,FALSE);
		    break;
		default:
		    return FALSE;
	    }
	    break;
	    
	default:
	    return FALSE;
    }
    return TRUE;		/* we processed message */
}

/* set selected paramters */
static void NEAR SetParamBox(HWND hDlg)
{
    WORD index;
    char buf[40];

    /* read each list box for current selection and set values accordingly */

    index = (WORD)SendDlgItemMessage(hDlg, IDD_STATES, LB_GETCURSEL, 0, 0L);
    if (index != LB_ERR) {
	SendDlgItemMessage(hDlg, IDD_STATES, LB_GETTEXT, index,
						(LONG)(LPSTR)buf);
	numstates = atoi(buf);
    }
    index = (WORD)SendDlgItemMessage(hDlg, IDD_ITERATIONS, LB_GETCURSEL, 0, 0L);
    if (index != LB_ERR) {
	SendDlgItemMessage(hDlg, IDD_ITERATIONS, LB_GETTEXT, index,
						(LONG)(LPSTR)buf);
	maxiterates = atoi(buf);
    }
}

/* initialize the dialog box list boxes */
static void NEAR InitParamBox(HWND hDlg)
{
    register int i;
    int k;
    char buf[40];
    DWORD color;
    HDC hDC;

    /* initialize the states list box */
    for (i = 2; i <= maxstates; i++)
        SendDlgItemMessage(hDlg, IDD_STATES, LB_INSERTSTRING, -1,
				(LONG)(LPSTR)itoa(i, buf, 10));
    SendDlgItemMessage(hDlg, IDD_STATES, LB_SELECTSTRING, -1,
			(LONG)(LPSTR)itoa(numstates, buf, 10));

    /* initialize the iterations list box */	
    for (i = 1; i <= 100; i++)
        SendDlgItemMessage(hDlg, IDD_ITERATIONS, LB_INSERTSTRING, -1,
				(LONG)(LPSTR)itoa(i, buf, 10));
    SendDlgItemMessage(hDlg, IDD_ITERATIONS, LB_SELECTSTRING, -1,
			(LONG)(LPSTR)itoa(maxiterates, buf, 10));
    
    /* finally, read the color table and display the values in hex */
    hDC = GetDC(hDlg);
    for (k = 0; k < maxstates; k++) {
	if (monochrome)
	    color = 0xff0000 * ((k & 4) >> 2) +
			    0x00ff00 * ((k & 2) >> 1) +
			    0x0000ff * (k & 1);
	else
	    Escape(hDC, GETCOLORTABLE, NULL, (LPSTR)&k, (LPSTR)&color);
        SendDlgItemMessage(hDlg, IDD_COLORS, LB_INSERTSTRING, -1,
				(LONG)(LPSTR)ultoa(color, buf, 16));
    }
    ReleaseDC(hDlg, hDC);
}
