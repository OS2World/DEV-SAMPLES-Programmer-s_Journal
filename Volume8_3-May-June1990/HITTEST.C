#define INCL_WIN
#define INCL_GPI
#include <os2.h>


// typedefs

typedef  struct wdw_params {
    MRESULT response;
    LONG    pattern,
            pattern1,
            pattern2;
} WDW_PARAMS;
typedef WDW_PARAMS  *NPWDW_PARAMS;
typedef WDW_PARAMS FAR  *PWDW_PARAMS;


// global variables

HAB     vhab;                                       // anchor block handle
HHEAP   vhHeap;                                     // heap handle

WDW_PARAMS    vdata[] = {
    MRFROMSHORT(HT_DISCARD),     PATSYM_SOLID, PATSYM_SOLID, PATSYM_NOSHADE,
    MRFROMSHORT(HT_TRANSPARENT), PATSYM_DIAG1, PATSYM_DIAG1, PATSYM_DIAG3,
    MRFROMSHORT(HT_NORMAL),      PATSYM_VERT,  PATSYM_VERT,  PATSYM_HORIZ
};


// function declarations

MRESULT EXPENTRY    ClientWndProc(HWND, USHORT, MPARAM, MPARAM);
MRESULT EXPENTRY    HittestWndProc(HWND, USHORT, MPARAM, MPARAM);
VOID    main(VOID);


VOID main(VOID)
{

    static ULONG    FrameFlags;                     // frame flags
    HMQ     hmq;                                    // msg queue handle
    HWND    hwndFrame,                              // frame window handle
            hwndClient;                             // client window handle
    QMSG    qmsg;                                   // window message queue

    vhab = WinInitialize(0);
    hmq = WinCreateMsgQueue(vhab, 0);
    vhHeap = WinCreateHeap(0, 0, 0, 0, 0, 0);

    WinRegisterClass(vhab, "Hittest", ClientWndProc, CS_SIZEREDRAW, 0);

    FrameFlags = FCF_TITLEBAR | FCF_SYSMENU | FCF_SIZEBORDER | FCF_MINMAX |
                 FCF_SHELLPOSITION | FCF_TASKLIST;

    hwndFrame = WinCreateStdWindow(HWND_DESKTOP, WS_VISIBLE, &FrameFlags,
                                   "Hittest", NULL, WS_CLIPCHILDREN, NULL,
                                   NULL, &hwndClient);

    while (WinGetMsg(vhab, &qmsg, NULL, 0, 0))
         WinDispatchMsg(vhab, &qmsg);

    WinDestroyHeap(vhHeap);
    WinDestroyWindow(hwndFrame);
    WinDestroyMsgQueue(hmq);
    WinTerminate(vhab);

}


MRESULT EXPENTRY ClientWndProc(HWND hwnd, USHORT msg, MPARAM mp1, MPARAM mp2)
{

    static LONG color;                              // background color
    HPS     hps;                                    // PS handle
    RECTL   rcl;                                    // window coordinates
    SHORT   i,                                      // window ID
            cxClient,                               // client window width
            cyClient,                               // & height
            wdwWidth,                               // child window width
            wdwHeight;                              // & height

    switch (msg) {
    case WM_CREATE :
        WinRegisterClass(vhab, "Test", HittestWndProc,
                         CS_SIZEREDRAW | CS_HITTEST,
                         sizeof(NPWDW_PARAMS));

        for (i = 0; i < 3; i++)
            WinCreateWindow(hwnd, "Test", NULL, WS_VISIBLE,
                            0, 0, 0, 0,
                            hwnd, HWND_TOP, i, (PVOID)&vdata[i], NULL);

        color = CLR_BACKGROUND;                     // initial bkg color
        break;

    case WM_SIZE:
        cxClient = SHORT1FROMMP(mp2);               // get size of client
        cyClient = SHORT2FROMMP(mp2);               // window

        wdwWidth = cxClient / 5;                    // size for child windows
        wdwHeight = cyClient / 5;

        for (i = 0; i < 3; i++)
            WinSetWindowPos(WinWindowFromID(hwnd, i), NULL,
                            ((i + 1) * (cxClient / 4)) - (wdwWidth / 2),
                            (cyClient / 2) - (wdwHeight / 2),
                            wdwWidth, wdwHeight,
                            SWP_MOVE | SWP_SIZE);

        break;

    case WM_PAINT:
        hps = WinBeginPaint(hwnd, NULL, NULL);
        WinQueryWindowRect(hwnd, &rcl);
        WinFillRect(hps, &rcl, color);
        WinEndPaint(hps);
        break;

    case WM_BUTTON1DOWN:
        color = (color == CLR_BACKGROUND) ? CLR_PINK : CLR_BACKGROUND;
        WinInvalidateRect(hwnd, NULL, FALSE);
        break;

    default:
        return(WinDefWindowProc(hwnd, msg, mp1, mp2));
    }

    return(NULL);

}


MRESULT EXPENTRY HittestWndProc(HWND hwnd, USHORT msg, MPARAM mp1, MPARAM mp2)
{

    HPS     hps;                                    // PS handle
    NPWDW_PARAMS WinData;                           // window specific data
    POINTL  ptl;                                    // point coordinates
    RECTL   rcl;                                    // rectangle coordinates

    WinData = (NPWDW_PARAMS)WinQueryWindowUShort(hwnd, 0);

    switch (msg) {
    case WM_CREATE:
        WinData = (NPWDW_PARAMS)WinAllocMem(vhHeap, sizeof(WDW_PARAMS));

        WinData->pattern = ((PWDW_PARAMS)mp1)->pattern1;
        WinData->pattern1 = ((PWDW_PARAMS)mp1)->pattern1;
        WinData->pattern2 = ((PWDW_PARAMS)mp1)->pattern2;
        WinData->response = ((PWDW_PARAMS)mp1)->response;

        WinSetWindowUShort(hwnd, 0, (USHORT)WinData);
        break;

    case WM_PAINT:
        hps = WinBeginPaint(hwnd, NULL, NULL);
        WinQueryWindowRect(hwnd, &rcl);

        GpiErase(hps);
        GpiSetPattern(hps, WinData->pattern);
        ptl.x = 0;                                      // lower left corner
        ptl.y = 0;                                      // of window
        GpiMove(hps, &ptl);
        ptl.x = --rcl.xRight;                           // decrement so we can
        ptl.y = --rcl.yTop;                             // see the border
        GpiBox(hps, DRO_OUTLINEFILL, &ptl, 0L, 0L);     // draw box w/border

        WinEndPaint(hps);
        break;

    case WM_BUTTON1DOWN:
        WinData->pattern = (WinData->pattern == WinData->pattern1) ?
                                   WinData->pattern2 : WinData->pattern1;
        WinInvalidateRect(hwnd, NULL, FALSE);
        break;

    case WM_HITTEST:
        return(WinData->response);

    case WM_DESTROY:
        WinFreeMem(vhHeap, (NPBYTE)WinData, sizeof(WDW_PARAMS));
        break;

    default:
        return(WinDefWindowProc(hwnd, msg, mp1, mp2));
    }

    return(NULL);

}
