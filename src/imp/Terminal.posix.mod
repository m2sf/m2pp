(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE Terminal; (* POSIX version *)

(* POSIX emulation of PIM's Terminal library *)

IMPORT unistd; (* POSIX library *)

IMPORT Newline;
FROM SYSTEM IMPORT ADR;
FROM ISO646 IMPORT NUL, LF, CR;


(* ---------------------------------------------------------------------------
 * procedure Read(ch)
 * ---------------------------------------------------------------------------
 * Blocking read operation. Reads a character from standard input.
 * ------------------------------------------------------------------------ *)

PROCEDURE Read ( VAR ch : CHAR );

VAR
  res : unistd.INT;
  
BEGIN
  res := unistd.read(unistd.StdIn, ADR(ch), 1);
END Read;


(* ---------------------------------------------------------------------------
 * procedure Write(ch)
 * ---------------------------------------------------------------------------
 * Writes the given character to standard output.
 * ------------------------------------------------------------------------ *)

PROCEDURE Write ( ch : CHAR );

VAR
  res : unistd.INT;
  
BEGIN
  res := unistd.write(unistd.StdOut, ADR(ch), 1)
END Write;


(* ---------------------------------------------------------------------------
 * procedure WriteString(array)
 * ---------------------------------------------------------------------------
 * Writes the given character array to standard output.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteString ( array : ARRAY OF CHAR );

VAR
  res : unistd.INT;
  len, maxIndex : CARDINAL;

BEGIN
  maxIndex := HIGH(array);
  IF maxIndex = 0 THEN
    RETURN
  END; (* IF *)
  
  len := 0;
  WHILE (len < maxIndex) AND (array[len] # NUL) DO
    len := len + 1
  END; (* WHILE *)
  
  res := unistd.write(unistd.StdOut, ADR(array), len)
END WriteString;


(* ---------------------------------------------------------------------------
 * procedure WriteLn
 * ---------------------------------------------------------------------------
 * Writes newline to standard output.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteLn;

BEGIN
  CASE Newline.mode() OF
    Newline.LF :
      Write(LF)
      
  | Newline.CR :
      Write(CR)
      
  | Newline.CRLF :
      Write(CR); Write(LF)
  END (* CASE *)
END WriteLn;


END Terminal.