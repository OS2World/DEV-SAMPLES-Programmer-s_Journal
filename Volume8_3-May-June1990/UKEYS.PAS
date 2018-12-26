(* ukeys.pas -- (c) 1989 by Tom Swan *)

unit ukeys;

interface

uses crt;

function getKey : char;
function keyWaiting : Boolean;
procedure pushKey( ch : char );

implementation

const

   NULL = #0;                 { ASCII NULL character }
   pushedChar : char = NULL;  { Saved char from pushKey procedure }

{ ----- Return next keyboard or pushed character. }

function getKey : char;
begin
   if pushedChar <> NULL then
   begin
      getKey := pushedChar;
      pushedChar := NULL;
   end else
      getKey := ReadKey;
end;

{ ----- Return true if a character is waiting to be read. }

function keyWaiting : Boolean;
begin
   keyWaiting := keypressed or ( pushedChar <> NULL );
end; { keyWaiting }

{ ----- Push a character back "into" the keyboard. }

procedure pushKey( ch : char );
begin
   pushedChar := ch;
end;

end.


