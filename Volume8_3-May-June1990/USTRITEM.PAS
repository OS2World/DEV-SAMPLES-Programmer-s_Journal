(* ustritem.pas -- (c) 1989 by Tom Swan *)

unit ustritem;

interface

uses uitem;

type

   strItemPtr = ^strItem;
   strItem = object( item )
      sp : ^string;
      constructor init( s : string );
      destructor done; virtual;
      function getString : string;
      function putString( s : string ) : Boolean; virtual;
      procedure upperString; virtual;
   end;

implementation

{ ----- Initialize a new string item, allocating heap space for the
string's characters and addressing that space with the object's sp
pointer. }

constructor strItem.init( s : string );
begin
   sp := nil;
   if putstring( s ) then item.init else
   begin
      done;    { Clean up any partially allocated structures }
      fail;    { Out of memory error }
   end;
end;

{ ----- Dispose of the allocated heap space and any memory assigned
to the string item object. }

destructor strItem.done;
begin
   if sp <> nil
      then freemem( sp, length( sp^ ) + 1 );
   item.done;
end;

{ ----- Return the value of the string. }

function strItem.getString : string;
begin
   getString := sp^;
end;

{ ----- Assign or replace the object's character string. Disposes any
current string and returns true for success; false if out of memory. }

function strItem.putString( s : string ) : Boolean;
begin
   if sp <> nil
      then freemem( sp, length( sp^ ) + 1 );
   getmem( sp, length( s ) + 1 );
   if sp = nil then putString := false else
   begin
      sp^ := s;
      putString := true;
   end;
end;

{ ----- Convert string to all uppercase. }

procedure strItem.upperString;
var
   i : integer;
begin
   if sp <> nil then
      for i := 1 to length( sp^ ) do
         sp^[ i ] := upcase( sp^[ i ] );
end;

end.





