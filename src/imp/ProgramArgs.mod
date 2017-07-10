(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE ProgramArgs;

(* Program Argument Management *)


VAR
  argsFile : InfileT;
  

PROCEDURE Open;
(* Opens the command line argument file. *)

VAR
  status : Infile.Status;
  
BEGIN
  Infile.Open(argsFile, Filename, status);
  
  (* TO DO : handle status *)
END Open;


PROCEDURE Close;
(* Closes the command line argument file. *)

BEGIN
  Infile.Close(argsFile);
  argsFile := NIL
END Close;


PROCEDURE Query;
(* Queries program args and writes argument file. *)

BEGIN
  (* TO DO *)
END Query;


PROCEDURE file () : InfileT;
(* Returns a file handle to the command line argument file, NIL if closed. *)

BEGIN
  RETURN argsFile
END file;


BEGIN
  argsFile := NIL
END ProgramArgs.