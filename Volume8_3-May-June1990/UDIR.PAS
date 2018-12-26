(* udir.pas -- (c) 1990 by Tom Swan *)

unit udir;
interface
uses dos, ulist, uselect;

type

   fileNameStr = string[12];     { e.g. '*.PAS' or 'MYFILE.TXT' }

   fileItemPtr = ^fileItem;
   fileItem = object( selectableItem )
      constructor init( sr : searchRec );
   end; { fileItem }

   directory = object( selectionList )
      sr : searchRec;   { From the DOS unit }
      wildCard : fileNameStr;
      constructor init( wc : fileNameStr; x1, y1, x2, y2 : word );
      procedure resetDirectory; virtual;
      procedure putWildCard( wc : fileNameStr );
   end; { directory }

implementation

{ ----- Initialize fileItem object. }
constructor fileItem.init( sr : searchRec );
var
   junk : dirStr;       { Required by fSplit(); ignored }
   fileName : nameStr;  { File name without extension }
   fileExt : extStr;    { File name extension with leading '.' }
begin
   fSplit( sr.name, junk, fileName, fileExt ); { Parse file name }
   selectableItem.init( fileName + fileExt, TRUE ) { Init ancestor }
end; { fileItem.init }

{ ----- Initialize directory object. }
constructor directory.init( wc : fileNameStr; x1, y1, x2, y2 : word );
begin
   selectionList.init( x1, y1, x2, y2 );
   putWildCard( wc )   { Assign wild card and read directory }
end; { directory.init }

{ ----- Reread current directory. }
procedure directory.resetDirectory;
begin
   disposeList;   { Dispose an existing directory list }
   findFirst( wildCard, 0, sr );
   while dosError = 0 do
   begin
      insertItem( new( fileItemPtr, init( sr ) ) );
      findNext( sr )
   end
end; { directory.resetDirectory }

{ ----- Change wild card specification. }
procedure directory.putWildCard( wc : fileNameStr );
begin
   wildCard := wc;
   resetDirectory
end; { directory.putWildCard }

end. { udir }
