/* *** Listing 4 ***
 *
 * <<< This code replaces DrawEllipse in Listing 1 >>>
 *
 * Draws an ellipse of the specified X and Y axis radii and color,
 * using a fast integer-only & square-root-free approach.
 * Compiles with either Turbo C 2.0 or MSC 5.0.
 * VGA or EGA.
 */

/* Draws an ellipse of X axis radius A and Y axis radius B in
 * color Color centered at screen coordinate (X,Y). Radii must
 * both be non-zero */
void DrawEllipse(int X, int Y, int A, int B, int Color) {
   int WorkingX, WorkingY;
   long Threshold;
   long ASquared = (long) A * A;
   long BSquared = (long) B * B;
   long XAdjust, YAdjust;

   /* Set drawing color via set/reset */
   outpw(GC_INDEX, (0x0F << 8) | SET_RESET_ENABLE_INDEX);
                                 /* enable set/reset for all planes */
   outpw(GC_INDEX, (Color << 8) | SET_RESET_INDEX);
                                 /* set set/reset (drawing) color */
   outp(GC_INDEX, BIT_MASK_INDEX); /* leave the GC Index reg pointing
                                       to the Bit Mask reg */

   /* Draw the four symmetric arcs for which X advances faster (that is,
      for which X is the major axis) */
   /* Draw the initial top & bottom points */
   DrawDot(X, Y+B);
   DrawDot(X, Y-B);

   /* Draw the four arcs; set draw parameters for initial point (0,B) */
   WorkingX = 0;
   WorkingY = B;
   XAdjust = 0;
   YAdjust = ASquared * 2 * B;
   Threshold = ASquared / 4 - ASquared * B;

   for (;;) {
      /* Advance the threshold to the value for the next X point
         to be drawn */
      Threshold += XAdjust + BSquared;

      /* If the threshold has passed 0, then the Y coordinate has
         advanced more than halfway to the next pixel and it's time
         to advance the Y coordinate by 1 and set the next threhold
         accordingly */
      if ( Threshold >= 0 ) {
         YAdjust -= ASquared * 2;
         Threshold -= YAdjust;
         WorkingY--;
      }

      /* Advance the X coordinate by 1 */
      XAdjust += BSquared * 2;
      WorkingX++;

      /* Stop if X is no longer the major axis (the arc has passed the
         45-degree point) */
      if ( XAdjust >= YAdjust )
         break;

      /* Draw the 4 symmetries of the current point */
      DrawDot(X+WorkingX, Y-WorkingY);
      DrawDot(X-WorkingX, Y-WorkingY);
      DrawDot(X+WorkingX, Y+WorkingY);
      DrawDot(X-WorkingX, Y+WorkingY);
   }

   /* Draw the four symmetric arcs for which Y advances faster (that is,
      for which Y is the major axis) */
   /* Draw the initial left & right points */
   DrawDot(X+A, Y);
   DrawDot(X-A, Y);

   /* Draw the four arcs; set draw parameters for initial point (A,0) */
   WorkingX = A;
   WorkingY = 0;
   XAdjust = BSquared * 2 * A;
   YAdjust = 0;
   Threshold = BSquared / 4 - BSquared * A;

   for (;;) {
      /* Advance the threshold to the value for the next Y point
         to be drawn */
      Threshold += YAdjust + ASquared;

      /* If the threshold has passed 0, then the X coordinate has
         advanced more than halfway to the next pixel and it's time
         to advance the X coordinate by 1 and set the next threhold
         accordingly */
      if ( Threshold >= 0 ) {
         XAdjust -= BSquared * 2;
         Threshold = Threshold - XAdjust;
         WorkingX--;
      }

      /* Advance the Y coordinate by 1 */
      YAdjust += ASquared * 2;
      WorkingY++;

      /* Stop if Y is no longer the major axis (the arc has passed the
         45-degree point) */
      if ( YAdjust > XAdjust )
         break;

      /* Draw the 4 symmetries of the current point */
      DrawDot(X+WorkingX, Y-WorkingY);
      DrawDot(X-WorkingX, Y-WorkingY);
      DrawDot(X+WorkingX, Y+WorkingY);
      DrawDot(X-WorkingX, Y+WorkingY);
   }

   /* Reset the Bit Mask register to normal */
   outp(GC_INDEX + 1, 0xFF);
   /* Turn off set/reset enable */
   outpw(GC_INDEX, (0x00 << 8) | SET_RESET_ENABLE_INDEX);
}

