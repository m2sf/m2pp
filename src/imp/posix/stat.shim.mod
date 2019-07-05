(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE stat; (* use for ACK and MOCKA *)

(* User-level Modula-2 shim library to call POSIX stat *)

IMPORT stat0; (* foreign interface *)

FROM SYSTEM IMPORT ADR;


(* chmod() *)

PROCEDURE chmod ( path : ARRAY OF CHAR; mode : ModeT ) : INT;

BEGIN
  RETURN stat0.chmod(ADR(path), mode)
END chmod;


(* mkdir() *)

PROCEDURE mkdir ( path : ARRAY OF CHAR; mode : ModeT ) : INT;

BEGIN
  RETURN stat0.mkdir(ADR(path), mode)
END mkdir;


(* stat() *)

PROCEDURE stat ( path : ARRAY OF CHAR; VAR st : Stat ) : INT;

BEGIN
  RETURN stat0.stat(ADR(path), ADR(st))
END stat;


(* umask() *)

PROCEDURE umask ( mode : ModeT ) : INT;

BEGIN
  RETURN stat0.umask(mode)
END umask;


END stat.