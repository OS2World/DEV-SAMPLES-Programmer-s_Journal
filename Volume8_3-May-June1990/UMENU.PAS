(* umenu.pas -- (c) 1989 by Tom Swan *)

unit umenu;

interface 

uses crt, ukeys, uitem, ucmds, ulist;

type

   menuPtr = ^menu;
   menu = object( list )
      menuRow, menuCol : word;   { Menu command-line location }
      menuTitle : ^string;       { Menu name string }
      menuDisplay : ^string;     { Menu commands string }
      menuAttr : word;           { Display attribute }

      constructor init( col, row : word; title : string; attr : word );
      destructor done; virtual;
      function menuStr : string;
      function getMenuAttr : Word;
      function getMenuRow : Word;
      function getMenuCol : Word;

      procedure displayMenu; virtual;
      procedure beforeCommand; virtual;
      procedure afterCommand; virtual;
      procedure performCommands; virtual;

{ ----- Replacement methods inherited from list object. }

      procedure insertItem( ip : ItemPtr ); virtual;
      procedure removeItem( ip : ItemPtr ); virtual;

   end;

implementation

const

   ESC = #27;     { ASCII escape char }

{ ----- Initialize a new menu command list. }

constructor menu.init( col, row : word; title : string; attr : word );
begin
   menuRow := row;
   menuCol := col;
   menuAttr := attr;
   menuDisplay := nil;  { Created by menu.menuStr }
   getMem( menuTitle, length( title ) + 1 );
   if menuTitle = nil then
   begin
      fail;
      done;
   end else
      menuTitle^ := title;
   list.init;
end;

{ ----- Dispose of a menu command list. }

destructor menu.done;
begin
   if menuTitle <> nil then
   begin
      freeMem( menuTitle, length( menuTitle^ ) + 1 );
      menuTitle := nil;
   end;
   if menuDisplay <> nil then
   begin
      freeMem( menuDisplay, length( menuDisplay^ ) + 1 );
      menuDisplay := nil;
   end;
   list.done;
end;

{ ----- Create and/or return current menu string. }

function menu.menuStr : string;
var
   s1, s2 : string[80];
begin
   if menuDisplay = nil then
   begin
      s1 := '';          { Null string }
      if not listEmpty then
      begin
         resetList;
         repeat
            s2 := commandPtr( currentItem )^.getstring;
            if length( s2 ) > 0
               then s1 := s1 + ' ' + s2;  { Add command to s1 }
            nextItem;
         until atHeadOfList;
      end;
      getMem( menuDisplay, length( s1 ) + 1 );
      if menuDisplay <> nil
         then menuDisplay^ := s1;
   end else
      s1 := menuDisplay^;
   if menuTitle <> nil
      then s1 := menuTitle^ + s1;
   menuStr := s1;
end;

{ ----- Return menu attribute word. }

function menu.getMenuAttr : Word;
begin
   getMenuAttr := menuAttr;
end;

{ ----- Return menu row. }

function menu.getMenuRow : Word;
begin
   getMenuRow := menuRow;
end;

{ ----- Return menu column. }

function menu.getMenuCol : Word;
begin
   getMenuCol := menuCol;
end;

{ ----- Display the menu name and command strings. }

procedure menu.displayMenu;
var
   oldAttr : word;   { For saving current attribute }
begin
   oldAttr := textAttr;
   textAttr := menuAttr;
   gotoxy( menuCol, menuRow );
   write( menuStr );
   clreol;
   textAttr := oldAttr;
end;

{ ----- Called at the top of the menu.performCommands repeat loop,
providing host programs a way to hook into the keyboard polling loop.
Optionally replaced by host program's menu object. }

procedure menu.beforeCommand;
begin
end;

{ ----- Called after menu.duringCommand. Optionally replaced by host
program's menu object. Note: you may use this procedure to modify the
menu list, allowing one command to alter the availability of other
commands. }

procedure menu.afterCommand;
begin
   displayMenu;   { Usually a good idea }
end;

{ ----- Process commands in menu list. Guaranteed to return upon
pressing <Esc>. Repeatedly calls beforeCommand while polling keyboard
for input. Calls afterCommand after processing a selected command in
the menu list. }

procedure menu.performCommands;
var
   ch : char;
begin
   displayMenu;         { Display menu name and commands }
   ch := chr( 0 );      { Initialize ch to null }
   repeat
      beforeCommand;       { Activate host polling hook }
      if keyWaiting then
      begin
         ch := upcase( getKey );
         if ch <> ESC then
         begin
            resetList;
            if not listEmpty then
            repeat
               if ch = commandPtr( currentItem )^.getcmdCh then
               begin
                  currentItem^.processItem;  { Perform command }
                  resetList;                 { Force loop to end }
                  afterCommand;              { Host post-cmd hook }
               end else
                  nextItem;
            until atHeadOfList;
         end;
      end;
   until ch = ESC;      { Until <Esc> pressed or forced }
end;

{ ----- Insert a new command into menu. Parameter ip must address a
command object as defined in ucmds.pas. Also dispose of the current
menu display string if neccessary, as these are invalid after new
commands are added to the list. }

procedure menu.insertItem( ip : ItemPtr );
begin
   if menuDisplay <> nil then
   begin
      freeMem( menuDisplay, length( menuDisplay^ ) + 1 );
      menuDisplay := nil;
   end;
   list.insertItem( ip );
end;

{ ----- Delete a single command from the menu.  Parameter ip should
address a command object (or a descendant). Also dispose the current
menu display string. }

procedure menu.removeItem( ip : ItemPtr );
begin
   if menuDisplay <> nil then
   begin
      freeMem( menuDisplay, length( menuDisplay^ ) + 1 );
      menuDisplay := nil;
   end;
   list.removeItem( ip );
end;

end.

