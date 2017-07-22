(*!m2pim+mocka*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE stdio; (* MOCKA version *)

(* User-level Modula-2 interface to POSIX stdio *)
  
IMPORT stdio0;

FROM SYSTEM IMPORT ADDRESS, ADR, BYTE;


(* fopen() *)

PROCEDURE fopen ( filename, mode : ARRAY OF CHAR ) : FILE;

fnameAddr, modeAddr : ADDRESS;

BEGIN
  fnameAddr := ADR(filename);
  modeAddr := ADR(mode);
  RETURN stdio0.fopen(fnameAddr, modeAddr)
END fopen;


(* fread() *)

PROCEDURE fread
  ( VAR data : ARRAY OF BYTE; size, items  : SizeT; stream : FILE ) : SizeT;

VAR dataAddr : ADDRESS;

BEGIN
  dataAddr := ADR(data);
  RETURN stdio0.fread(dataAddr, size, items, stream)
END fread;


(* fwrite() *)

PROCEDURE fwrite
  ( data : ARRAY OF BYTE; size, items  : SizeT; stream : FILE ) : SizeT;

VAR dataAddr : ADDRESS;

BEGIN
  dataAddr := ADR(data);
  RETURN stdio0.fread(dataAddr, size, items, stream)
END fwrite;


(* rename() *)

PROCEDURE rename ( old, new : ARRAY OF CHAR ) : INT;

oldAddr, newAddr : ADDRESS;

BEGIN
  oldAddr := ADR(old);
  newAddr := ADR(new);
  RETURN stdio0.rename(oldAddr, newAddr)
END rename;


(* remove() *)

PROCEDURE remove ( path : ARRAY OF CHAR ) : INT;

VAR pathAddr : ADDRESS;

BEGIN
  pathAddr := ADR(path);
  RETURN stdio0.remove(pathAddr)
END remove;


END stdio.