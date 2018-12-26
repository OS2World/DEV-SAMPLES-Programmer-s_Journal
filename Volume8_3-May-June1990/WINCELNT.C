/* 
 * Initialization segment for the Windows cellular automaton demo
 * This code is discarded after it is used.
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
#include <windows.h>
#include "wincel.h"

/* local function declarations */
static BOOL NEAR RegisterWindowClass(HANDLE);
static void NEAR GetPrevInstanceData(HANDLE);
static BOOL NEAR MakeAndShowMainWnd(HANDLE, int);

/* This routine is FAR since it is called from another segment */
BOOL FAR InitProgram(hInstance,hPrevInstance, lpszCmdLine, cmdShow)
HANDLE hInstance, hPrevInstance;
LPSTR lpszCmdLine;
int cmdShow;
{

    hInst = hInstance;

  /* if this is the first instance of the program ... */
    if (!hPrevInstance) {
     /* register the window */
	if (!RegisterWindowClass(hInstance))
	    return FALSE;
     /* get the icon string */
	LoadString(hInstance, IDS_ICON,(LPSTR)szIcon,sizeof(szIcon));
    }

  /* A previous instance already exists so get global data from there */
    else
	GetPrevInstanceData(hPrevInstance);

  /* Create and show the window */
    if (!MakeAndShowMainWnd(hInstance, cmdShow))
	return FALSE;

    return TRUE;
}

/* Every window must belong to a class. We register ours here */
static BOOL NEAR RegisterWindowClass(hInstance)
HANDLE hInstance;
{

    PWNDCLASS pWndClass;
    HANDLE hTemp;

  /* Load the name string from resources */
    LoadString(hInstance, IDS_APPNAME,(LPSTR)szAppName,sizeof(szAppName));

  /* allocate space for the WNDCLASS structure and lock it down */
    hTemp = LocalAlloc(LPTR,sizeof(WNDCLASS));
    pWndClass = (PWNDCLASS)LocalLock(hTemp);

  /* fill the structure */	
    pWndClass->hCursor	= LoadCursor(NULL, IDC_ARROW);  /* standard cursor */
    pWndClass->hIcon	= NULL;				/* no icon */
    pWndClass->lpszMenuName = (LPSTR)szAppName;
    pWndClass->lpszClassName = (LPSTR)szAppName;	/* our class name */
    pWndClass->hbrBackground = COLOR_APPWORKSPACE + 1;
    pWndClass->hInstance = hInstance;		/* instance handle */
    pWndClass->style = CS_VREDRAW | CS_HREDRAW; /* standard redraw values */
    pWndClass->lpfnWndProc = MainWndProc;	/* pointer to our window proc */

  /* register the class.  if fail, abort */
    if (!RegisterClass((LPWNDCLASS)pWndClass))
	return FALSE;

  /* free the memory used */
    LocalUnlock(hTemp);
    LocalFree(hTemp);

  /* show success */
    return TRUE;
}

/*
   If this not the first instance, we can retrieve static data from a
   previous invocation of the program
*/
static void NEAR GetPrevInstanceData(hInstance)
HANDLE hInstance;
{

    GetInstanceData(hInstance, (PSTR)szAppName, sizeof(szAppName));
    GetInstanceData(hInstance, (PSTR)szIcon, sizeof(szIcon));

}

/*
 Create the window, making sure that its position and size are suitable
 for the display.
*/
static BOOL NEAR MakeAndShowMainWnd(HANDLE hInstance, int cmdShow)
{

   char szTitle[50];

    LoadString(hInstance, IDS_TITLE,(LPSTR)szTitle,sizeof(szTitle));

  /* create the window, letting it fall where Windows wants */
    hWndMain = CreateWindow((LPSTR)szAppName,
			     (LPSTR)szTitle,
			     WS_OVERLAPPEDWINDOW,
			     CW_USEDEFAULT,0,
			     CW_USEDEFAULT,0,
			     (HWND)NULL,
			     (HMENU)NULL,
			     (HANDLE)hInstance,
			     (LPSTR)NULL);

  /* if we fail, give up */
    if (hWndMain == NULL)
	return FALSE;

  /* finally, display the window and show success */
    ShowWindow(hWndMain, cmdShow);
    UpdateWindow(hWndMain);

    return TRUE;
}

// get the maximum number of states for the display and set some values
void FAR WndInit(HWND hWnd)
{
    register HDC hDC;

    hDC = GetDC(hWnd);
    maxstates = GetDeviceCaps(hDC, NUMCOLORS);
    ReleaseDC(hWnd, hDC);

    if (maxstates == 2) {
	maxstates = 8;
	monochrome = TRUE;
    }
    numstates = maxstates > MAXSTATES ? MAXSTATES : maxstates;
    maxiterates = UPDATECOUNT;
    update = maxiterates;
}

