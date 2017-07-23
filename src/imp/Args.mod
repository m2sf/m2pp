(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE Args;

(* Program Argument Management *)

IMPORT ISO646, CharArray, Console, BasicFileSys, Infile, Outfile, String;

FROM BuildParams IMPORT ArgQueryBufferSize;
FROM String IMPORT StringT; (* alias for String.String *)


VAR
  isOpen : BOOLEAN;
  argsFile : InfileT;
  

PROCEDURE Open;
(* Opens the command line argument file. *)

VAR
  status : Infile.Status;
  
BEGIN
  Infile.Open(argsFile, Filename, status);
  isOpen := (status = Infile.Success)
END Open;


PROCEDURE Close;
(* Closes the command line argument file. *)

BEGIN
  Infile.Close(argsFile);
  argsFile := Infile.Nil;
  isOpen := FALSE
END Close;


PROCEDURE Delete;
(* Deletes the command line argument file. *)

VAR
  status : BasicFileSys.Status;
  
BEGIN
  IF NOT isOpen THEN
    BasicFileSys.DeleteFile(Filename, status)
  END (* IF *)
END Delete;


PROCEDURE Query;
(* Queries program args and writes argument file. *)

VAR
  argStr : ARRAY [0..ArgQueryBufferSize] OF CHAR;
  tmpFile : InfileT;
  status : Infile.Status;
  
BEGIN
  (* prompt *)
  Console.WriteChars("args> ");
  
  (* read user input *)
  argStr[0] := ISO646.NUL;
  Console.ReadChars(argStr);
  
  (* remove leading and trailing space *)
  CharArray.Trim(argStr);
  
  (* bail out if user input is empty *)
  IF argStr[0] = ISO646.NUL THEN
    RETURN
  END; (* IF *)
  
  (* open/create argument file *)
  Outfile.Open(tmpFile, Filename, status);
  
  (* bail out if file couldn't be opened/created *)
  IF status # Outfile.Success THEN
    Console.WriteChars("unable to open/create ");
    Console.WriteChars(Filename);
    Console.WriteChars(".\n");
    RETURN
  END; (* IF *)
  
  (* write argStr to argument file *)
  Outfile.WriteChars(argStr);
  Outfile.Close(tmpFile);
  
  (* open argument file for argument parser *)
  Infile.Open(argsFile, Filename, status);
  
  (* bail out if file couldn't be opened *)
  IF status # Infile.Success THEN
    Console.WriteChars("unable to open ");
    Console.WriteChars(Filename);
    Console.WriteChars(".\n");
    RETURN
  END; (* IF *)
  
  isOpen := TRUE
END Query;


PROCEDURE file () : InfileT;
(* Returns a file handle to the command line argument file, NIL if closed. *)

BEGIN
  RETURN argsFile
END file;


BEGIN
  isOpen := FALSE;
  argsFile := Infile.Nil
END Args.