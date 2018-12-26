/* *** Listing 3 ***
 *
 * Draws nested ellipses of varying eccentricities in the VGA's
 * hi-res mode, mode 12h.
 * For VGA only.
 * Compile and link with listingX.c (where X is 1 or 4) with:
 *    tcc listingX listing3      (Turbo C)
 *    cl listingX.c listing3.c   (MSC)
 */

#include <dos.h>

main() {
   int XRadius, YRadius, Temp, Color;
   union REGS Regs;

   /* Select VGA's hi-res 640x480 graphics mode, mode 12h */
   Regs.x.ax = 0x0012;
   int86(0x10, &Regs, &Regs);

   /* Draw nested ellipses */
   for ( XRadius = 100, YRadius = 2, Color = 7; YRadius < 240;
         XRadius++, YRadius += 2 ) {
      DrawEllipse(640/2, 480/2, XRadius, YRadius, Color);
      Color = (Color + 1) & 0x0F;   /* cycle through 16 colors */
   }

   /* Wait for a key, restore text mode, and done */
   scanf("%c", &Temp);
   Regs.x.ax = 0x0003;
   int86(0x10, &Regs, &Regs);
}

