(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation. *)

DEFINITION MODULE Console;

(* Console I/O library *)

IMPORT Terminal;

FROM ISO646 IMPORT NUL, NEWLINE, US, DEL;
FROM String IMPORT StringT; (* alias for String.String *)
FROM CardMath IMPORT abs, pow10, reqBits, maxDecimalDigits;


VAR
  maxDecimalExponent : CARDINAL;
  

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
 * procedure ReadChars(chars)
 * ---------------------------------------------------------------------------
 * Reads up to HIGH(chars)-1 characters from the console and passes them back
 * in chars.  NEWLINE terminates input and will not be copied to chars.
 * ------------------------------------------------------------------------ *)

PROCEDURE ReadChars ( VAR chars : ARRAY OF CHARS );

VAR
  ch : CHAR;
  index : CARDINAL;
  
BEGIN
  ch := NUL;
  index := 0;
  
  (* read characters *)
  WHILE (index < HIGH(chars)) AND (ch # NEWLINE) DO
    Terminal.Read(ch);
    (* copy to chars unless control char *)
    IF (ch > US) AND (ch # DEL) THEN
      chars[index] := ch
    END; (* IF *)
    index := index + 1
  END; (* WHILE *)
  
  (* terminate sequence *)
  chars[index] := NUL;
END ReadChars;


(* Write operations *)

(* ---------------------------------------------------------------------------
 * procedure WriteChar(chars)
 * ---------------------------------------------------------------------------
 * Prints the given character to the console.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteChar ( ch : CHAR );

BEGIN
  (* write unless control char *)
  IF (ch > US) AND (ch # DEL) THEN
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
    (* write unless control char *)
    IF (ch > US) AND (ch # DEL) THEN
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
  (* determine largest decimal exponent for type CARDINAL *)
  maxDecimalExponent := maxDecimalDigits(reqBits(MAX(CARDINAL)) DIV 8)
END Console.