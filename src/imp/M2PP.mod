(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE M2PP;

(* Modula-2 Preprocessor *)

IMPORT Dictionary, String, CharQueue, FileIO;

FROM String IMPORT StringT; (* alias for String.String *)


CONST
  NUL   = CHR(0);
  TAB   = CHR(9);
  LF    = CHR(10);
  CR    = CHR(13);
  SPACE = CHR(32);
  DEL   = CHR(127);
  SINGLEQUOTE = CHR(39);
  DOUBLEQUOTE = CHR(34);


TYPE Context = RECORD
  dict    : Dictionary;
  infile,
  outfile : FileIO.File
END; (* Context *)


(* ---------------------------------------------------------------------------
 * procedure Expand(template, dict, outfile)
 * ---------------------------------------------------------------------------
 * Expands template file into output file using dictionary dict.
 * ------------------------------------------------------------------------ *)

PROCEDURE Expand
  ( template : FileIO.File; dict : Dictionary; outfile : FileIO.File );

VAR
  c : Context;
  
BEGIN
  c.dict := dict;
  c.infile := template;
  c.outfile := outfile;
  
  WHILE NOT EOF(c) DO
    
    ReadChar(c, ch);
    
    CASE ch OF
    (* tabulator *)
      TAB :
        IF ReplaceTabsWithSpaces THEN
          WriteChars(c, "  ")
        ELSE
          WriteChar(c, ch)
        END (* IF *)
      
    (* line feed *)
    | LF :
        (* write newline *)
        WriteLn(c)
        
    (* carriage return *)
    | CR :
        (* write newline *)
        WriteLn(c);
        
        (* if LF follows, skip it *)
        ReadChar(c, ch);
        IF ch # LF THEN
          (* not LF, put it back *)
          CharQueue.Insert(ch)
        END (* IF *)
        
    (* double quoted literal *)
    | DOUBLEQUOTE :
        (* prevent expansion within quoted literal *)
        CopyCharsUpTo(c, ch)
        
    (* placeholder *)
    | '#' :
      (* get next char *)
      ReadChar(c, ch);
      
      IF ch = '#' THEN
        (* 2nd char matched *)
        ExpandPlaceholder(c)
        
      ELSE (* 2nd char did not match *)
        WriteChar(c, "#");
        (* put 2nd char back *)
        CharQueue.Insert(ch)
      END (* IF *)
    
    (* single quoted literal *)
    | SINGLEQUOTE :
        (* prevent expansion within quoted literal *)
        CopyCharsUpTo(c, ch)
        
    (* m2pp pragma*)
    | '(' :
      (* get next char *)
      ReadChar(c, ch);
      
      IF ch = '*' THEN
        (* 2nd char matched *)
        ReadChar(c, ch);
        
        IF ch = '?' THEN
          (* 3rd char matched *)
          Pragma(c)
          
        ELSE (* 3rd char did not match *)
          WriteChars(c, "(*");
          (* put 3rd char back *)
          CharQueue.Insert(ch)
        END (* IF *)
        
      ELSE (* 2nd char did not match *)
        WriteChar(c, "(");
        (* put 2nd char back *)
        CharQueue.Insert(ch)
      END (* IF *)
    
    (* m2pp comment *)
    | '/' :
      (* 1st char matched *)
      ReadChar(c, ch);
      
      IF ch = '*' THEN
        (* 2nd char matched *)
        SkipComment(c);
        
      ELSE (* 2nd char did not match *)
        WriteChar("/");
        (* put last char back *)
        CharQueue.Insert(ch)
      END (* IF *)
      
    (* any other chars *)
    ELSE
      WriteChar(c, ch)
    END (* CASE *)
  END (* WHILE *)  
END Expand;


(* ---------------------------------------------------------------------------
 * function EOF()
 * ---------------------------------------------------------------------------
 * Returns TRUE if infile has reached EOF, else FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE EOF( VAR (* CONST *) c : Context ) : BOOLEAN;

BEGIN
  RETURN FileIO.eof(c.infile)
END EOF;


(* ---------------------------------------------------------------------------
 * procedure ReadChar(ch)
 * ---------------------------------------------------------------------------
 * Reads a character from the input file
 * ------------------------------------------------------------------------ *)

PROCEDURE ReadChar( VAR (* CONST *) c : Context; VAR ch : CHAR );

VAR
  octet : CARDINAL;
  
BEGIN
  IF CharQueue.isEmpty() THEN
    FileIO.Read(c.infile, octet);
    ch := CHR(octet)
  ELSE
    CharQueue.Remove(ch)
  END (* IF *)  
END ReadChar;


(* ---------------------------------------------------------------------------
 * procedure WriteChar(ch)
 * ---------------------------------------------------------------------------
 * Writes a character to the output file
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteChar( VAR (* CONST *) c; ch : CHAR );

BEGIN
  (* write to output if printable char *)
  IF (ch >= SPACE) AND (ch # DEL) THEN
    FileIO.Write(c.outfile, ORD(ch))
  END   
END WriteChar;


(* ---------------------------------------------------------------------------
 * procedure WriteChars(array)
 * ---------------------------------------------------------------------------
 * Writes a character array to the output file
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteChars( VAR (* CONST *) c : Context; array : ARRAY OF CHAR );

VAR
  ch : CHAR;
  index : CARDINAL;
  
BEGIN
  FOR index := 0 TO HIGH(array) DO
    (* get next char *)
    ch := array[index];
    
    (* done when NUL *)
    IF ch = NUL THEN
      RETURN
    END; (* IF *)
    
    (* write to output if printable char *)
    IF (ch >= SPACE) AND (ch # DEL) THEN
      FileIO.Write(c.outfile, ORD(ch))
    END   
  END (* FOR *)
END WriteChars;


(* ---------------------------------------------------------------------------
 * procedure WriteStr(array)
 * ---------------------------------------------------------------------------
 * Writes a string to the output file
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteStr( VAR (* CONST *) c : Context; string : StringT );

PROCEDURE WriteCharsSimple ( array : ARRAY OF CHAR );

BEGIN
  WriteChars(c, array)
END WriteCharsSimple;

BEGIN
  String.withCharsDo(string, WriteCharsSimple)
END WriteStr;


(* ---------------------------------------------------------------------------
 * procedure WriteLn
 * ---------------------------------------------------------------------------
 * Writes a newline to the output file
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteLn( VAR (* CONST *) c : Context );

BEGIN
  FileIO.WriteLn(c.outfile)
END WriteStr;


(* ---------------------------------------------------------------------------
 * procedure CopyQuotedLiteral
 * ---------------------------------------------------------------------------
 * Reads quoted literal from stdin and writes it verbatim to stdout
 * ------------------------------------------------------------------------ *)

PROCEDURE CopyQuotedLiteral( VAR (* CONST *) c : Context; delimiter : CHAR );
  
VAR
  next : CHAR;

BEGIN
  (* print lead delimiter already consumed by caller *)
  WriteChar(c, delimiter);
  
  (* get next char *)
  ReadChar(c, next);
  
  WHILE next # delimiter DO
    IF (next) >= SPACE THEN
      WriteChar(c, next)
    END; (* IF *)
    
    (* get next char *)
    ReadChar(c, next);
  END (* WHILE *)
  
  (* put last char back *)
  CharQueue.Insert(next)
END CopyQuotedLiteral;


(* ---------------------------------------------------------------------------
 * procedure ExpandPlaceholder
 * ---------------------------------------------------------------------------
 * Reads a quoted literal from stdin and writes it verbatim to stdout
 * ------------------------------------------------------------------------ *)

PROCEDURE ExpandPlaceholder ( VAR (* CONST *) c : Context );

VAR
  valid : BOOLEAN;
  ident, replacement : StringT;
  
BEGIN
  GetIdent(c, ident, next, valid);
  
  IF NOT valid OR (next # '#') THEN
    WriteCharsc(c, "##");
    WriteStr(c, ident);
    CharQueue.Insert(next);
    RETURN
  END; (* IF *)
  
  (* get next char *)
  ReadChar(c, next);
  
  IF next # '#' THEN
    WriteChars(c, "##");
    WriteStr(c, ident);
    WriteChar(c, "#");
    CharQueue.Insert(next);
    RETURN
  END; (* IF *)
  
  (* lookup replacement string *)
  IF Dictionary.lookup(c.dict, ident, replacement) THEN
    (* print replacement string *)
    WriteStr(c, replacement)
    
  ELSE (* no entry found *)
    WriteChars(c, "##");
    WriteStr(c, ident);
    WriteChars(c, "##")
  END (* IF *)
END ExpandPlaceholder;


(* ---------------------------------------------------------------------------
 * procedure Pragma
 * ---------------------------------------------------------------------------
 * Reads a quoted literal from stdin and writes it verbatim to stdout
 * ------------------------------------------------------------------------ *)

PROCEDURE Pragma ( VAR (* CONST *) c : Context );

VAR
  ident, version : StringT;
  
BEGIN
  ReadChar(c, next);
  
  (* conditional insert pragma *)
  IF ((next >= 'a') AND (next <= 'z')) OR
     ((next >= 'A') AND (next <= 'Z')) THEN
    GetIdent(c, ident, next, valid)
    
    (* check if identifier matches version string *)
    IF Dictionary.lookup(c.dict, "ver", version) AND (ident = version) THEN
      (* continue *)
      RETURN
      
    ELSE (* skip chars until next pragma *)
      SkipToStartOfPragma(c)
    END (* IF *)
    
  (* section terminator pragma *)
  ELSIF next = ';' THEN
    SkipToEndOfPragma(c)
    
  ELSE (* illegal char *)  
    (* TO DO : report error *)
    SkipToEndOfPragma(c)
  END (* CASE *)
END Pragma;


(* ---------------------------------------------------------------------------
 * procedure SkipComment
 * ---------------------------------------------------------------------------
 * Reads and consumes a preprocessor comment from input
 * ------------------------------------------------------------------------ *)

PROCEDURE SkipComment( VAR (* CONST *) c : Context );

VAR
  next : CHAR;
  delimiterFound : BOOLEAN;

BEGIN
  delimiterFound := FALSE;
  
  WHILE NOT delimiterFound DO
    (* get next char *)
    ReadChar(c, next);
    
    IF next = '*' THEN
      (* possibly closing delimiter *)
      ReadChar(c, next);
      
      IF next = '/' THEN
        delimiterFound := TRUE
      END (* IF *)
    END (* IF *)
  END (* WHILE *)
END SkipComment;


END M2PP.