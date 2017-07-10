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
  (* print message *)
  Console.WriteChars
    ("Please enter program arguments, press ENTER key when done");
  Console.WriteLn;
  
  (* prompt *)
  Console.WriteChars("M2PP> ");
  
  (* read user input *)
  Console.ReadLine(argStr);
  
  (* TO DO : check *)
  
  (* write args to argument file *)
  Outfile.Open(tmpFile, Filename, status);
  
  (* TO DO : handle status *)
  
  Outfile.WriteChars(argStr);
  Outfile.Close(tmpFile);
  
  (* open argument file for reading by argument parser *)
  Infile.Open(argsFile, Filename, status)
END Query;


PROCEDURE file () : InfileT;
(* Returns a file handle to the command line argument file, NIL if closed. *)

BEGIN
  RETURN argsFile
END file;


BEGIN
  argsFile := NIL
END ProgramArgs.