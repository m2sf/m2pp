(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE stdio; (* use for ACK and MOCKA *)

(* User-level Modula-2 shim library to call POSIX stdio *)

IMPORT stdio0; (* foreign interface *)

FROM SYSTEM IMPORT ADR, BYTE;


(* fopen() *)

PROCEDURE fopen ( filename, mode : ARRAY OF CHAR ) : FILE;

BEGIN
  RETURN stdio0.fopen(ADR(filename), ADR(mode))
END fopen;


(* fread() *)

PROCEDURE fread
  ( VAR data : ARRAY OF BYTE; size, items  : SizeT; stream : FILE ) : SizeT;

BEGIN
  RETURN stdio0.fread(ADR(data), size, items, stream)
END fread;


(* fwrite() *)

PROCEDURE fwrite
  ( data : ARRAY OF BYTE; size, items  : SizeT; stream : FILE ) : SizeT;

BEGIN
  RETURN stdio0.fwrite(ADR(data), size, items, stream)
END fwrite;


(* rename() *)

PROCEDURE rename ( old, new : ARRAY OF CHAR ) : INT;

BEGIN
  RETURN stdio0.rename(ADR(old), ADR(new))
END rename;


(* remove() *)

PROCEDURE remove ( path : ARRAY OF CHAR ) : INT;

BEGIN
  RETURN stdio0.remove(ADR(path))
END remove;


END stdio.