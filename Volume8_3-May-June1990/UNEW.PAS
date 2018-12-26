(* unew.pas -- (c) 1989 by Tom Swan *)

unit unew;

interface

uses crt, ucmds, uprogram;

type

   newObj = object( command )
      procedure processItem; virtual;
   end;

var

   newCmd   : newObj;

implementation

procedure newObj.processItem;
begin
   clrscr;
   writeln( 'You selected the New command' );
end;

begin
   newCmd.init(  @theMenu, 'N', 'New'  );
end.
