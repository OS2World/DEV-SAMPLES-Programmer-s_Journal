(* uselect.pas -- (c) 1990 by Tom Swan *)

unit uselect;
interface
uses crt, ukeys, uscreen, uitem, ustritem, ulist;

type

   keySet = set of char;

   selectableItemPtr = ^selectableItem;
   selectableItem = object( strItem )
      selected : Boolean;
      constructor init( s : string; initial : Boolean );
      procedure setSelection( setting : Boolean );
      procedure toggleSelection;
      function getMarkedString : string; virtual;
   end; { selectableItem }

   selectionListPtr = ^selectionList;
   selectionList = object( list )
      xmin, ymin, xmax, ymax : word;   { Display coordinates }
      constructor init( x1, y1, x2, y2 : word );
      procedure firstSelectedItem( var noItems : Boolean );
      procedure nextSelectedItem( var pastHead : Boolean );
      procedure setAll( setting : Boolean );
      procedure toggleAll;
      procedure displayItems; virtual;
      procedure selectItems( exitKeys : keySet; 
         var lastKey : char ); virtual;
   end; { selectionList }

implementation

const

   DIM      = FALSE;    { ShowItem arguments }
   BRIGHT   = TRUE;
   ENTER    = #13;      { Various character constants }
   ESC      = #27;
   BLANK    = #32;
   KEY_UP   = 'H';
   KEY_DOWN = 'P';

{ ----- Initialize selectableItem object. }
constructor selectableItem.init( s : string; initial : Boolean );
begin
   selected := initial;
   strItem.Init( s )
end; { selectableItem.init }

{ ----- Set selected switch to 'setting'. }
procedure selectableItem.setSelection( setting : Boolean );
begin
   selected := setting
end; { selectableItem.setSelection }

{ ----- Toggle this item on/off }
procedure selectableItem.toggleSelection;
begin
   selected := not selected
end; { selectableItem.toggleSelection }

{ ----- Return string with selected marker on or off }
function selectableItem.getMarkedString : string;
var
   s2 : string[2];
begin
   if selected
      then s2 := '> '
      else s2 := '  ';
   getMarkedString := s2 + getString
end; { selectableItem.getMarkedString }

{ ----- Initialize selectionList object }
constructor selectionList.init( x1, y1, x2, y2 : word );
begin
   list.init;
   xmin := x1;
   ymin := y1;
   xmax := x2;
   ymax := y2
end; { selectionList.init }

{ ----- Advance list to first item where selected=TRUE. If noItems is
TRUE, then the list contains no selected items. }
procedure selectionList.firstSelectedItem( var noItems : Boolean );
begin
   noItems := listEmpty;   { i.e. noItems = TRUE if list is empty }
   if noItems then exit;
   resetList;
   if selectableItemPtr( currentItem )^.selected then exit;
   nextSelectedItem( noItems )
end; { selectionList.firstSelectedItem }

{ ----- Advance list to next item where selected=TRUE. If pastHead
returns TRUE, then the search has gone full circle around the list. }
procedure selectionList.nextSelectedItem( var pastHead : Boolean );
begin
   pastHead := listEmpty;
   while not pastHead do
   begin
      nextItem;
      pastHead := atHeadOfList;
      if selectableItemPtr( currentItem )^.selected then exit
   end { while }
end; { selectionList.nextSelectedItem }

{ ----- Set all select switches to 'setting.' }
procedure selectionList.setAll( setting : Boolean );
begin
   if listEmpty then exit;
   resetList;
   repeat
      selectableItemPtr( currentItem )^.setSelection( setting );
      nextItem
   until atHeadOfList
end; { selectionList.setAll }

{ ----- Toggle all select switches for all listed items. }
procedure selectionList.toggleAll;
begin
   if listEmpty then exit;
   resetList;
   repeat
      selectableItemPtr( currentItem )^.toggleSelection;
      nextItem
   until atHeadOfList
end; { selectionList.toggleAll }

{ ----- Display all selectableItem objects }
procedure selectionList.displayItems;
var
   line : integer;
begin
   clearWindow( xmin, ymin, xmax, ymax );
   gotoxy( xmin, ymin );
   line := ymin;
   if listEmpty then exit;    { Leaving window clear }
   resetList;
   repeat
      gotoxy( xmin, line );
      write( selectableItemPtr( currentItem )^.getMarkedString );
      nextItem;
      inc( line )
   until atHeadOfList or ( line > ymax )
end; { selectionList.displayItems }

{ ----- Let user select one or more items from the list. }
procedure selectionList.selectItems( 
   exitKeys : keySet; var lastKey : char );
var
   line : integer;            { Line number (absolute) }
   exitKeyPressed : Boolean;  { True if any exit key pressed }

   procedure showItem( ip : ItemPtr; highlight : Boolean );
   begin
      gotoxy( xmin, line );
      clrEol;
      if highlight
         then highVideo
         else normVideo;
      if ip <> nil
         then write( selectableItemPtr( ip )^.getMarkedString );
      normVideo
   end; { showItem }

   procedure startList;
   begin
      displayItems;
      line := ymin;
      resetList;
      showItem( currentItem, BRIGHT )
   end; { startList }

   procedure moveUp;
   begin
      if (not listEmpty) and (not atHeadOfList) then
      begin
         showItem( currentItem, DIM );
         if line > ymin
            then dec( line )
            else scrollDown( xmin, ymin, xmax, ymax );
         prevItem;
         showItem( currentItem, BRIGHT )
      end { if }
   end; { moveUp }

   procedure moveDown;
   begin
      if (not listEmpty) and (not atEndOfList) then
      begin
         showItem( currentItem, DIM );
         if line < ymax 
            then inc( line )
            else scrollUp( xmin, ymin, xmax, ymax );
         nextItem;
         showItem( currentItem, BRIGHT )
      end { if }
   end; { moveDown }

   procedure toggle;
   var
      sip : selectableItemPtr;
   begin
      sip := selectableItemPtr( currentItem );
      if sip <> nil
         then sip^.toggleSelection;
      showItem( sip, BRIGHT )
   end; { toggle }

begin
   startList;
   exitKeys := exitKeys + [ ESC ];    { Escape always exits }
   exitKeyPressed := FALSE;
   repeat
      lastKey := upcase( getKey );
      case lastKey of
         KEY_UP      : moveUp;
         KEY_DOWN    : moveDown;
         BLANK,ENTER : toggle;
      else 
         exitKeyPressed := lastKey in exitKeys
      end
   until exitKeyPressed;
   showItem( currentItem, DIM )
end; { selectionList.selectItems }

end. { uselect }
