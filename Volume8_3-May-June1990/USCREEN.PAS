(* uscreen.pas -- (c) 1990 by Tom Swan *)

unit uscreen;
interface
uses crt, dos;

procedure clearWindow( x1, y1, x2, y2 : word );
procedure scrollUp( x1, y1, x2, y2 : word );
procedure scrollDown( x1, y1, x2, y2 : word );

implementation

{ ----- Clear display area to current background color. }
procedure clearWindow( x1, y1, x2, y2 : word );
var
   oldMin, oldMax : word;
begin
   oldMin := crt.windMin;
   oldMax := crt.windMax;
   window( x1, y1, x2, y2 );
   clrscr;
   crt.windMin := oldMin;
   crt.windMax := oldMax
end; { clearWindow }

{ ----- Scroll display area up one line }
procedure scrollUp( x1, y1, x2, y2 : word );
var
   regs : registers;
begin
   with regs do
   begin
      ah := 6;             { BIOS function number }
      al := 1;             { Number of lines to scroll }
      bh := crt.textAttr;  { Attribute for blank line }
      cl := x1 - 1;
      ch := y1 - 1;
      dl := x2 - 1;
      dh := y2 - 1
   end;
   intr( $10, regs )
end; { scrollUp }

{ ----- Scroll display area down one line }
procedure scrollDown( x1, y1, x2, y2 : word );
var
   regs : registers;
begin
   with regs do
   begin
      ah := 7;             { BIOS function number }
      al := 1;             { Number of lines to scroll }
      bh := crt.textAttr;  { Attribute for blank line }
      cl := x1 - 1;
      ch := y1 - 1;
      dl := x2 - 1;
      dh := y2 - 1
   end;
   intr( $10, regs )
end; { scrollDown }

end. { uscreen }
