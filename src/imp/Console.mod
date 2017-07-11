(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

DEFINITION MODULE Console;

(* Console I/O library *)

IMPORT ISO646, Terminal;

FROM String IMPORT StringT; (* alias for String.String *)
FROM CardMath IMPORT abs, pow10, reqBits, maxDecimalDigits;


CONST
  BufferSize = 255;


VAR
  maxDecimalExponent : CARDINAL;
  buffer : ARRAY [0..BufferSize] OF CHAR;
  

(* Read operations *)

(* ---------------------------------------------------------------------------
 * procedure ReadChar(ch)
 * ---------------------------------------------------------------------------
 * Reads one character from the console and passes it back in ch.
 * ------------------------------------------------------------------------ *)

PROCEDURE ReadChar ( VAR ch : CHAR );

BEGIN
  Terminal.Read(ch)
END ReadChar;


(* ---------------------------------------------------------------------------
 * procedure ReadString(s)
 * ---------------------------------------------------------------------------
 * Reads a sequence of up to 255 characters from the console and passes it
 * back in s.  NEWLINE terminates input and will not be copied to s.
 * ------------------------------------------------------------------------ *)

PROCEDURE ReadString ( VAR s : StringT );

VAR
  ch : CHAR;
  index : CARDINAL;
  
BEGIN
  index := 0;
  
  (* read characters into buffer *)
  WHILE (index < BufferSize) (ch # ISO646.NEWLINE) DO
    Terminal.Read(ch);
    buffer[index] := ch;
    index := index + 1
  END; (* WHILE *)
  
  (* terminate buffer *)
  buffer[index] := ISO646.NUL;
  
  (* get interned string and return it *)
  RETURN String.forArray(buffer)
END ReadString;


(* Write operations *)

(* ---------------------------------------------------------------------------
 * procedure WriteChar(chars)
 * ---------------------------------------------------------------------------
 * Prints the given character to the console.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteChar ( ch : CHAR );

BEGIN
  IF (ch > ISO646.US) AND (ch # ISO646.DEL) THEN
    Terminal.Write(char)
  END (* IF *)
END WriteChar;


(* ---------------------------------------------------------------------------
 * procedure WriteChars(chars)
 * ---------------------------------------------------------------------------
 * Prints the given character array to the console.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteChars ( chars : ARRAY OF CHAR );

VAR
  ch : CHAR;
  index : CARDINAL;
  
BEGIN
  FOR index := 0 TO HIGH(chars) DO
    ch := chars[index];
    IF (ch > ISO646.US) AND (ch # ISO646.DEL) THEN
      Terminal.Write(ch)
    ELSIF ch = NUL THEN
      RETURN
    END (* IF *)
  END (* FOR *)
END WriteChars;


(* ---------------------------------------------------------------------------
 * procedure WriteString(s)
 * ---------------------------------------------------------------------------
 * Prints the given string to the console.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteString ( s : StringT );

BEGIN
  IF (s # String.Nil) AND (String.length(s) > 0) THEN
    String.WithCharsDo(s, Terminal.WriteString)
  END (* IF *)
END WriteString;


(* ---------------------------------------------------------------------------
 * procedure WriteCharsAndString(chars, s)
 * ---------------------------------------------------------------------------
 * Prints the given character array and string to the console.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteCharsAndString ( VAR chars : ARRAY OF CHAR; s : StringT );

BEGIN
  (* print chars *)
  WriteChars(chars);
  
  (* print s *)
  IF (s # String.Nil) AND (String.length(s) > 0) THEN
    String.WithCharsDo(s, Terminal.WriteString)
  END (* IF *)
END WriteCharsAndString;


(* ---------------------------------------------------------------------------
 * procedure WriteLn
 * ---------------------------------------------------------------------------
 * Prints newline to the console.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteLn;

BEGIN
  Terminal.WriteLn
END WriteLn;


(* ---------------------------------------------------------------------------
 * procedure WriteBool(value)
 * ---------------------------------------------------------------------------
 * Prints the given value to the console. "TRUE" for TRUE, "FALSE" for FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteBool ( value : BOOLEAN );

BEGIN
  IF value = TRUE THEN
    Terminal.WriteString("TRUE")
  ELSE
    Terminal.WriteString("FALSE")
  END (* IF *)
END WriteBool;


(* ---------------------------------------------------------------------------
 * procedure WriteCard(value)
 * ---------------------------------------------------------------------------
 * Prints the given cardinal value to the console.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteCard ( value : CARDINAL );

VAR
  m, n, weight, digit : CARDINAL;

BEGIN
  (* largest base-10 exponent *)
  m := maxDecimalExponent;
  
  (* skip any leading zeroes *)
  WHILE value DIV pow10(m) = 0 DO
    m := m - 1
  END; (* WHILE *)
  
  (* print digits *)
  weight := pow10(m);
  FOR n := m TO 0 BY -1 DO
    digit := value DIV weight;
    Terminal.Write(CHR(digit + 48));
    value := value MOD weight;
    weight := weight DIV 10
  END (* FOR *)
END WriteCard;


(* ---------------------------------------------------------------------------
 * procedure WriteInt(value)
 * ---------------------------------------------------------------------------
 * Prints the given integer value to the console.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteInt ( value : INTEGER );

BEGIN
  (* print sign if negative *)
  IF value < 0 THEN
    Terminal.Write("-")
  END; (* IF *)
  
  (* print unsigned value *)
  WriteCard(abs(value))
END WriteInt;


BEGIN
  maxDecimalExponent := maxDecimalDigits(reqBits(MAX(CARDINAL)) DIV 8)
END Console.