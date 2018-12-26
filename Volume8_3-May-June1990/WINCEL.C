/* 
 * Resident segment for the Windows cellular automaton demo
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
#include <string.h>
#include <stdlib.h>

/* dialog box manifests */
#include "wcldlg.h"

/* all global variables are declared in this module */
#define EXTERN
#include "wincel.h"

#define MAXPOINTS  50		/* maximum number of points */

BYTE new[MAXPOINTS][MAXPOINTS];		/* cells */
BYTE old[MAXPOINTS][MAXPOINTS];

static BOOL go;			/* start, stop */
static BOOL start;		/* program has been started */

/* local function declarations */
static void NEAR MainWndPaint(HWND hWnd, HDC hDC);
static void NEAR DoPeekMessage(void);
static void NEAR InitializePoints(void);
static void NEAR Neighbor(int pos,register int i,register int j,int *k,int *l);
static void NEAR EatPoints(void);
static void NEAR ShowRect(HDC hDC, int i, int j, int index);
static void NEAR WndCommand(HWND hWnd, WORD id);

/* Entry point for program */
int PASCAL WinMain(hInstance, hPrevInstance, lpszCmdLine, cmdShow)
HANDLE hInstance, hPrevInstance;
LPSTR lpszCmdLine;
int cmdShow;
{

    MSG msg;

    // If initialization is not successful then exit.
    if (!InitProgram(hInstance,hPrevInstance, lpszCmdLine, cmdShow))
	return FALSE;

    // stay in this loop until window is destroyed.
    while (TRUE) {
        if (PeekMessage((LPMSG)&msg,NULL,0,0,PM_REMOVE)) {
	    if (msg.message == WM_QUIT)
		break;
	    TranslateMessage((LPMSG)&msg); // translate keydown/up to chars.
	    DispatchMessage((LPMSG)&msg);  // call the appropriate window proc.
	}
	else if (go) {
	    EatPoints();	// change states of points.
            PostMessage(hWndMain, WM_USER, 0, 0L); // copy and display states.
	}
    }
    return (int)msg.wParam;	// terminate program.
}

/* All messages are processed here */
long FAR PASCAL MainWndProc(hWnd,message,wParam,lParam)
HWND hWnd;
unsigned message;
WORD wParam;
LONG lParam;
{

    PAINTSTRUCT ps;

    switch(message) {

	// display points if appropriate and reinitialize the old array.
	case WM_USER:
	    if (!IsIconic(hWnd)) {
		if (--update == 0) {
	            InvalidateRect(hWnd, NULL, FALSE);
	            UpdateWindow(hWnd);
		    update = maxiterates;
	        }
	    }
            memcpy(old, new, sizeof(old));
	    break;

	// start and stop display with the mouse
	case WM_LBUTTONDOWN:
	    if (start)
		if (go == TRUE)
		    go = FALSE;
		else
		    go = TRUE;
	    break;

	// process menus
	case WM_COMMAND:
	    WndCommand(hWnd, wParam);
	    break;

	// quit
	case WM_DESTROY:
	    PostQuitMessage(0);
	    break;

	// draw
	case WM_PAINT:
	    BeginPaint(hWnd, (LPPAINTSTRUCT)&ps);
	    MainWndPaint(hWnd, ps.hdc);
	    EndPaint(hWnd, (LPPAINTSTRUCT)&ps);
	    break;

	// do some initializations
	case WM_CREATE:
	    WndInit(hWnd);
	    break;

	default:
	    return ((long)DefWindowProc(hWnd,message,wParam,lParam));
	    break;
    }
    return(0L);
}

/* process menu commands */
static void NEAR WndCommand(HWND hWnd, WORD id)
{
    switch (id) {
	// initiate or restart process
	case IDM_START:
	    InitializePoints();
	    start = TRUE;
	    go = TRUE;
            InvalidateRect(hWnd, NULL, TRUE);
	    break;

	// change parameters
	case IDM_PARAMS:
	    if (OpenDlgBox(hWnd, ParamBoxProc, DT_PARAMS)) {
		InitializePoints();
		InvalidateRect(hWnd, NULL, TRUE);
	    }
	    break;

	// display about box
	case IDM_ABOUT:
	    OpenDlgBox(hWnd, AboutBoxProc, DT_ABOUT);
	    break;
    }
}

/* update the screen */
static void NEAR MainWndPaint(HWND hWnd, HDC hDC)
{

    register int i,j;
    HCURSOR hcur, holdcur;
    RECT rect;

  /* draw the icon */
    if (IsIconic(hWnd)) {
	GetClientRect(hWnd, (LPRECT)&rect);
	Rectangle(hDC, 0,0,rect.right, rect.bottom);
        TextOut(hDC,2,rect.bottom/3,(LPSTR)szIcon,strlen(szIcon));
    }
    else if (start) {
	// put up hourglass cursor
        hcur = LoadCursor(hInst, IDC_WAIT);
        holdcur = SetCursor(hcur);

	// how big is the screen
        GetClientRect(hWnd, &rect);

	/* Set up a logical screen of MAXPOINTS x MAXPOINTS
	   rectangles each of size 5 units. */
        SetMapMode(hDC, MM_ANISOTROPIC);
        SetWindowOrg(hDC, 0, 0);
        SetWindowExt(hDC, 5 * MAXPOINTS, 5 * MAXPOINTS);
        SetViewportOrg(hDC, 0, 0);
        SetViewportExt(hDC, rect.right, rect.bottom);

	// show the points
        for (i = 0; i < MAXPOINTS; i++) {
	    for (j = 0; j < MAXPOINTS; j++)
	        ShowRect(hDC, i, j, (int)new[i][j]);
	    Yield();	// let someone else read a message
        }
        SetCursor(holdcur);	// restore the old cursor
    }
}

/* draw a rectangle on the screen using the display's color table */
static void NEAR ShowRect(HDC hDC, int i, int j, int index)
{
    HBRUSH hbr, hbrold;
    HPEN hpen, hpenold;
    register short x,y;
    DWORD color;

    // get the color for this index.
    // If monochrome, make one up
    if (monochrome)
	color = 0xff0000 * ((index & 4) >> 2) +
		0x00ff00 * ((index & 2) >> 1) +
		0x0000ff * (index & 1);
    // if color, read the color table of the device.
    else 
        Escape(hDC, GETCOLORTABLE, NULL, (LPSTR)&index, (LPSTR)&color);

    // create and select a brush for the interior
    hbr = CreateSolidBrush(color);
    hbrold = SelectObject(hDC, hbr);

    // we want the same color on the boundary, so create the appropriate pen.
    hpen = CreatePen(0, 0, color);
    hpenold = SelectObject(hDC, hpen);

    // draw the rectangle at the given position
    x = 5 * j;
    y = 5 * i;
    Rectangle(hDC, x, y, x + 5, y + 5);

    // select out and kill the drawing objects
    SelectObject(hDC, hbrold);
    SelectObject(hDC, hpenold);
    DeleteObject(hbr);
    DeleteObject(hpen);
}

// load the points with random values between 0 and numstates - 1
static void NEAR InitializePoints()
{
    register int i, j;
    double val;

    srand(LOWORD(GetCurrentTime()));
    for (i = 0; i < MAXPOINTS; i++) {
	for (j = 0; j < MAXPOINTS; j++) {
	    val = ((float)rand() / 32768.0) * numstates;
	    new[i][j] = old[i][j] = (char)val;
	}
    }
}

/* consume neighboring points */
static void NEAR EatPoints()
{
    register int i, j;
    int k, l, n;

    for (i = 0; i < MAXPOINTS; i++) {
        for (j = 0; j < MAXPOINTS; j++) {
   	    for (n = 0; n < 4; n++) {
	        Neighbor(n, i, j, &k, &l);
	        if (old[k][l] == ((old[i][j] + 1) % numstates)) {
	            new[i][j] = old[k][l];
		    break;
	        }
	    }
	}
    }
}

// for a given index i, compute the neighboring indices
static void NEAR Neighbor(int pos,register int i,register int j,int *k,int *l)
{
     switch(pos) {
	case 0:
	    *k = (i == 0 ? MAXPOINTS - 1 : i - 1);
	    *l = j;
	    break;
	case 1:
	    *k = (i == MAXPOINTS - 1 ?  0 : i + 1);
	    *l = j;
	    break;
	case 2:
	    *k = i;
	    *l = (j == 0 ? MAXPOINTS - 1 : j - 1);
	    break;
	case 3:
	    *k = i;
	    *l = (j == MAXPOINTS - 1 ? 0 : j + 1);
	    break;
    }
}
