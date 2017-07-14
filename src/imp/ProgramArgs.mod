(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE ProgramArgs;

(* Program Argument Management *)

IMPORT ISO646, Console, Infile, Outfile, String;

FROM String IMPORT StringT; (* alias for String.String *)


CONST
  QueryBufferSize = 255;
  
  
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


PROCEDURE Delete;
(* Deletes the command line argument file. *)

BEGIN
  (* TO DO *)
END Delete;


PROCEDURE Query;
(* Queries program args and writes argument file. *)

VAR
  argStr : ARRAY [0..QueryBufferSize] OF CHAR;
  tmpFile : InfileT;
  
BEGIN
  (* prompt *)
  Console.WriteChars("args> ");
  
  (* read user input *)
  argStr[0] := ISO646.NUL;
  Console.ReadChars(argStr);
  
  IF argStr[0] # ISO646.NUL THEN
    (* write argStr to argument file *)
    Outfile.Open(tmpFile, Filename, status);
    
    (* TO DO : handle status *)
    
    Outfile.WriteChars(argStr);
    Outfile.Close(tmpFile);
    
    (* open argument file for reading by argument parser *)
    Infile.Open(argsFile, Filename, status)
  END (* IF *)
END Query;


PROCEDURE file () : InfileT;
(* Returns a file handle to the command line argument file, NIL if closed. *)

BEGIN
  RETURN argsFile
END file;


BEGIN
  argsFile := NIL
END ProgramArgs.