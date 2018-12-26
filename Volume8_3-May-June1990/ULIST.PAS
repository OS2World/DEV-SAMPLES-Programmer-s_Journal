(* ulist.pas -- (c) 1989 by Tom Swan *)

unit ulist;

interface

uses uitem;

type

   listPtr = ^list;
   list = object( item )
      anchor : itemPtr;    { Addresses list head }
      cip : itemPtr;       { Current item pointer }
      constructor init;
      destructor done; virtual;
      function listEmpty : Boolean;
      function atHeadOfList : Boolean;
      function atEndOfList : Boolean;
      function currentItem : itemPtr;
      procedure prevItem;
      procedure nextItem;
      procedure resetList;
      procedure insertItem( ip : itemPtr ); virtual;
      procedure removeItem( ip : itemPtr ); virtual;
      procedure processItems; virtual;
      procedure disposeList; virtual;
   end;

implementation

{ ----- Initialize an empty list. }

constructor list.init;
begin
   anchor := nil;
   cip := nil;
   item.init;
end;

{ ----- Dispose any listed items and the list object itself. }

destructor list.done;
begin
   if anchor <> nil
      then disposeList;
   item.done;
end;

{ ----- Return true if list is empty. }

function list.listEmpty : Boolean;
begin
   listEmpty := ( anchor = nil );
end;

{ ----- Return true if current item is at the head of the list. }

function list.atHeadOfList : Boolean;
begin
   atHeadOfList := ( anchor <> nil ) and ( cip = anchor );
end;

{ ----- Return true if current item is at the end of the list. }

function list.atEndOfList : Boolean; 
begin
   atEndOfList := ( anchor <> nil ) and ( cip = anchor^.left );
end;

{ ----- Return item addressed by current item pointer (cip). }

function list.currentItem : itemPtr;
begin
   currentItem := cip;
end;

{ ----- Move current pointer to previous item in list. }

procedure list.prevItem;
begin
   if cip <> nil
      then cip := cip^.left;
end;

{ ----- Move current pointer to next item in list. }

procedure list.nextItem;
begin
   if cip <> nil
      then cip := cip^.right;
end;

{ ----- Reset list. currentItem will return first item inserted. }

procedure list.resetList;
begin
   cip := anchor;
end;

{ ----- Insert item addressed by ip ahead of current item. }

procedure list.insertItem( ip : itemPtr );
begin
   if ip <> nil then       { Prevent out-of-memory disasters }
   if anchor = nil then    { If list is empty ... }
   begin
      anchor := ip;        {  then start a new list }
      resetList;           {  and initialize current item }
   end else
      ip^.link( cip );     {  else link item into list at cip }
end;

{ ----- Remove listed item addressed by ip and adjust anchor if
necessary to make sure that anchor and cip don't address the removed
item. }

procedure list.removeItem( ip : itemPtr );
begin
   if ip^.right = ip then  { If only one list item ... }
   begin
      anchor := nil;       {  then empty the list }
      cip := nil;
   end else                {  else adjust anchor and cip }
   begin
      if ip = anchor 
         then anchor := anchor^.right; 
      if cip = ip
         then cip := cip^.right;
   end;
   ip^.unlink;
end;

{ ----- Process all listed items. }

procedure list.processItems;
begin
   resetList;
   if currentItem <> nil then
   repeat
      currentItem^.processItem;
      nextItem;
   until atHeadOfList;
end;

{ ----- Dispose items in a list. }

procedure list.disposeList;
var
   ip : itemPtr;
begin
   while not listEmpty do
   begin
      ip := currentItem;
      removeItem( ip );
      if ( seg( ip^ ) <> DSeg ) and ( seg( ip^ ) <> SSeg )
         then dispose( ip, done )
         else ip^.done;
   end; { while }
end;

end.

