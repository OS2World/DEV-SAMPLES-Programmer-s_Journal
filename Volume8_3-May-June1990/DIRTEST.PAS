(* dirtest.pas -- (c) 1990 by Tom Swan *)

program dirtest;
uses crt, ustritem, udir;
var
   dir : directory;
   lastKey : char;
   name : fileNameStr;
   flag : Boolean;
begin
   clrscr;
   dir.init( '*.*', 10, 3, 40, 18 );
   dir.setAll( FALSE );
   dir.selectItems( [], lastKey );
   gotoxy( 1, 25 );
   writeln( 'Selected files:' );
   dir.firstSelectedItem( flag );
   while not flag {no items or past list head} do
   begin
      name := strItemPtr( dir.currentItem )^.getString;
      write( name, ' ' : 20 - length( name ) );
      dir.nextSelectedItem( flag )
   end;
   writeln;
   dir.done
end. { dirtest }
