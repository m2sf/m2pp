(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE unistd; (* use for ACK and MOCKA *)

(* User-level Modula-2 shim library to call POSIX unistd *)

IMPORT unistd0; (* foreign interface *)

FROM SYSTEM IMPORT ADR;


(* access() *)

PROCEDURE access ( path : ARRAY OF CHAR; mode : AccessMode ) : INT;

BEGIN
  RETURN unistd0.access(ADR(path), VAL(INT, mode))
END access;


(* unlink() *)

PROCEDURE unlink ( path : ARRAY OF CHAR ) : INT;

BEGIN
  RETURN unistd0.unlink(ADR(path))
END unlink;


END unistd.