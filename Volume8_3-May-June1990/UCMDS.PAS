(* ucmds.pas -- (c) 1989 by Tom Swan *)

unit ucmds;

interface

uses crt, ustritem, ulist;

type

   commandPtr = ^command;
   command = object( strItem )
      cmdCh : char;
      constructor init( theMenu: listPtr; ch : char; description : string );
      function getcmdCh : char; virtual;
   end;

implementation

{ ----- Initialize a new command and insert into theMenu. }

constructor command.init( 
   theMenu: listPtr; ch : char; description : string );
begin
   cmdCh := ch;
   strItem.init( description );
   theMenu^.insertItem( @self );
end;

{ ----- Return a command's character. }

function command.getcmdCh : char;
begin
   getcmdCh := cmdCh;
end;

end.
