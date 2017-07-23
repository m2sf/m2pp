(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE Terminal; (* ISO version *)

(* ISO emulation of PIM's Terminal library *)

IMPORT STextIO; (* ISO library *)


(* ---------------------------------------------------------------------------
 * procedure Read(ch)
 * ---------------------------------------------------------------------------
 * Blocking read operation. Reads a character from standard input.
 * ------------------------------------------------------------------------ *)

PROCEDURE Read ( VAR ch : CHAR );

BEGIN
  STextIO.ReadChar(ch)
END Read;


(* ---------------------------------------------------------------------------
 * procedure Write(ch)
 * ---------------------------------------------------------------------------
 * Writes the given character to standard output.
 * ------------------------------------------------------------------------ *)

PROCEDURE Write ( ch : CHAR );

BEGIN
  STextIO.WriteChar(ch)
END Write;


(* ---------------------------------------------------------------------------
 * procedure WriteString(array)
 * ---------------------------------------------------------------------------
 * Writes the given character array to standard output.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteString ( array : ARRAY OF CHAR );

BEGIN
  STextIO.WriteString(array)
END WriteString;


(* ---------------------------------------------------------------------------
 * procedure WriteLn
 * ---------------------------------------------------------------------------
 * Writes newline to standard output.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteLn;

BEGIN
  STextIO.WriteLn
END WriteLn;


END Terminal.