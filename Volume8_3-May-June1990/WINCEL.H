/*
 * Header file for the Windows cellular automaton demo
 *
 * Written by Bill Hall
 * 3665  Benton Street, #66
 * Santa Clara, CA 95051
 *
 */

/* This trick insures that globals are declared in only one place */
#if !defined(EXTERN)
#define EXTERN extern
#endif

/* Resource string constants */
#define IDS_APPNAME	100
#define IDS_ICON	101
#define IDS_TITLE	102

/* menu items */
#define IDM_START	100
#define IDM_PARAMS	101
#define IDM_ABOUT	102

/* other manifests */
#define UPDATECOUNT 5		/* number of computations between displays */
#define MAXSTATES 14		/* a reasonable upper bound for states */

/* Global variables */
EXTERN HWND hWndMain;		/* main window handle */
EXTERN char szAppName[10];	/* name of the application */
EXTERN char szIcon[5];		/* icon string */
EXTERN HANDLE hInst;		/* instance handle */
EXTERN int numstates;		/* number of states */
EXTERN int maxstates;		/* maximum allowable states */
EXTERN int maxiterates;		/* iterations between displays */
EXTERN BOOL monochrome;		/* device is monochrome, fake color */
EXTERN int update;		/* update counter */

/* Declarations which need to be known in all C source files */
LONG FAR PASCAL MainWndProc(HWND,unsigned,WORD,LONG);
BOOL FAR InitProgram(HANDLE, HANDLE, LPSTR, int);
BOOL OpenDlgBox(HWND hWnd, FARPROC fpProc, WORD boxnum);
BOOL FAR PASCAL AboutBoxProc(HWND hDlg,unsigned message,WORD wParam,LONG lParam);
BOOL FAR PASCAL ParamBoxProc(HWND hDlg,unsigned message,WORD wParam,LONG lParam);
void FAR WndInit(HWND hWnd);
