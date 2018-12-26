(* uitem.pas -- (c) 1989 by Tom Swan *)

unit uitem;

interface

type

   itemPtr = ^item;
   item = object
      left, right : itemPtr;
      constructor init;
      destructor done; virtual;
      procedure link( ip : itemPtr );
      procedure unlink;
      procedure processItem; virtual;
   end;

implementation

{ ----- Initialize a new item object to point to itself. }

constructor item.init;
begin
   left := @self;
   right := @self;
end;

{ ----- Dispose item object's memory. }

destructor item.done;
begin
end;

{ ----- Link item to another item addressed by ip. }

procedure item.Link( ip : itemPtr );
begin
   right := ip;
   left := ip^.left;
   ip^.left^.right := @self;
   ip^.left := @self;
end;

{ ----- Unlink an item if it's linked to another. }

procedure item.Unlink;
begin
   left^.right := right;
   right^.left := left;
end;

{ ----- Process contents of item. }

procedure item.processItem;
begin
end;

end.
