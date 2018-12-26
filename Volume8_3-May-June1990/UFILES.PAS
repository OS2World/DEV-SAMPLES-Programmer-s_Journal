(* ufiles.pas -- (c) 1989 by Tom Swan. *)

unit ufiles;

interface

uses crt, ukeys, ucmds, umenu, uprogram;

type

   fileObj = object( command )
      procedure processItem; virtual;
   end;

var

   fileCmd  : fileObj;

implementation

type

   fListObj = object( command )
      procedure processItem; virtual;
   end;

   fDirObj = object( command )
      procedure processItem; virtual;
   end;

   fEndObj = object( command )
      procedure processItem; virtual;
   end;

var

   fListCmd : fListObj;
   fDirCmd  : fDirObj;
   fEndCmd  : fEndObj;
   fileMenu : menu;

{ ----- File-menu methods. }

procedure fListObj.processItem;
begin
   clrscr;
   writeln( 'File-List command' );
end;

procedure fDirObj.processItem;
begin
   clrscr;
   writeln( 'File-Dir command' );
end;

procedure fEndObj.processItem;
begin
   pushKey( chr(27) );  { Ends file menu processing }
end;

{ ----- Run the file menu. }

procedure fileObj.processItem;
begin
   clrscr;
   fileMenu.init( 1, hi( windmax ) + 1, 'File:', WHITE + BLUE * 16 );
   fListCmd.init( @fileMenu, 'L', 'List' );
   fDirCmd.init(  @fileMenu, 'D', 'Dir' );
   fEndCmd.init(  @fileMenu, chr(13), '' );  { <Enter> ends menu }
   fileMenu.performCommands;
   fileMenu.done;
end;

begin
   fileCmd.init( @theMenu, 'F', 'File' );
end.


