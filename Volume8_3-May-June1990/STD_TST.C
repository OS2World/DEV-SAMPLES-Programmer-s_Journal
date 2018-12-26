/*   std_tst.c   std_tst function
*    Tests whether stdin or stdout has been
*    redirected to a file  
*    Written by: B. H. Robinson
*       Written: Jan 21, 1990
*       Version: 001
*    The parameter "channel" must be 0 to test stdin or
*    1 to test stdout. stdin_tst returns 0 if the channel
*    is redirected to a file, 1 if it is a device or -1
*    if there is an error in execution of std_tst.
*********************************************/
#include <stdio.h>
#include <io.h>
#include <conio.h>

int std_tst( int channel )
{
    int stat;

    if( (channel != 0) && (channel != 1) ) {
        cprintf( "Incorrect parameter in call to std_tst.\n\r");
        return -1;
    }
    stat = ioctl( channel, 0 );
    if( stat == -1 )
        return -1;
    if( (stat & 0x80) == 128 )
        return 1;
    else
        return 0;
}    
/************** end of file ****************************/

