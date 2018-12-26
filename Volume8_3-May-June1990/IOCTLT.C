/*   ioctlt.c  tests  std_tst function
*    Written by: B. H. Robinson
*       Written: Jan 21, 1990
*       Version: 001
*    Compile on Turbo C
*********************************************/
#include <stdio.h>
#include <io.h>
#include <conio.h>

int std_tst( int channel );
void check( int ch );

char *s_channel[] = {"STDIN" ,
                   "STDOUT" ,
                   " BAD CHANNEL " };

int main()
{
    check( 0 );   /* Check stdin channel  */
    check( 1 );   /* Check stdout channel */
    return 0;
}
/**********************************************/
void check( int ch )
{
    int stat;
                                    
    if( (ch != 0) && (ch != 1) )
        ch = 2;
    stat = std_tst( ch );
    switch( stat ){
        case -1:
            cprintf("Error in st_tst for %s.\n\r", s_channel[ ch ] );
            break;
        case 0:
            cprintf("%s is a file.\n\r", s_channel[ ch ]);
            break;
        case 1:
            cprintf("%s is a device.\n\r", s_channel[ ch ]);
            break;
        default:
            break;
    }
}
/***************** end of file ****************/
