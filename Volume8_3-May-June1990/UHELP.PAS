(* uhelp.pas -- (c) 1989 by Tom Swan *)

unit uhelp;

interface

uses crt, ucmds, uprogram;

type

   helpObj = object( command )
      procedure processItem; virtual;
   end;

var

   helpCmd  : helpObj;

implementation

{ ----- Display sample help screen. }

procedure helpObj.processItem;
begin
   clrscr;
   writeln( 'Help!' );
   writeln;
   writeln( 'Type the first letter of a command.  Type Q' );
   writeln( 'or <Esc> to quit and return to DOS.' );
end;

begin
   helpCmd.init( @theMenu, 'H', 'Help' );
end.

