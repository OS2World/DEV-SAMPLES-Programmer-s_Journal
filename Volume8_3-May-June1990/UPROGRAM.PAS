(* uprogram.pas -- (c) 1989 by Tom Swan *)

unit uprogram;

interface

uses crt, ukeys, ucmds, ulist, umenu;

procedure run;

var

   theMenu  : menu;

implementation

{ ----- Private command object. }

type

   quitObj = object( command )
      procedure processItem; virtual;
   end;

var
   
   quitCmd  : quitObj;

{$IFDEF DEBUG}
   startmem : longint;  { Holds memavail at startup for debugging }
{$ENDIF}

{ ----- Run the program. }

procedure run;
begin
   quitCmd.init( @theMenu, 'Q', 'Quit' );
   theMenu.performCommands;
   theMenu.done;
   gotoxy( 1, hi( windmax ) + 1 );
   writeln;
{$IFDEF DEBUG}
   writeln( 'mem at start = ', startmem );   { display statistics }
   writeln( 'mem at end   = ', memavail );
{$ENDIF}
end;

{ ----- Implement the Quit command. }

procedure quitObj.processItem;
begin
   pushKey( chr(27) );     { Simulate <Esc> keypress }
end;

begin
{$IFDEF DEBUG}
   startmem := memavail;   { Record memavail at startup }
{$ENDIF}
   theMenu.init( 1, hi( windmax ) + 1, 'Test:', WHITE + BLUE * 16 );
end.
