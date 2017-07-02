(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE M2PP;

(* Modula-2 Preprocessor *)

IMPORT Dictionary, String, BasicFileIO;

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


(* ---------------------------------------------------------------------------
 * procedure Expand(template, outfile)
 * ---------------------------------------------------------------------------
 * Expands template file into output file using a global dictionary.
 * ------------------------------------------------------------------------ *)

PROCEDURE Expand ( template : File; outfile : File );

BEGIN
  
  WHILE NOT EOF(template) DO
    
    ReadChar(template, ch);
    
    CASE ch OF
    (* tabulator *)
      TAB :
        IF ReplaceTabsWithSpaces THEN
          WriteChars(outfile, "  ")
        ELSE
          WriteChar(outfile, ch)
        END (* IF *)
      
    (* line feed *)
    | LF :
        (* write newline *)
        WriteLn(outfile)
        
    (* carriage return *)
    | CR :
        (* write newline *)
        WriteLn(outfile);
        
        (* if LF follows, skip it *)
        ReadChar(template, ch);
        IF ch # LF THEN
          (* not LF, put it back *)
          InsertChar(template, ch)
        END (* IF *)
        
    (* double quoted literal *)
    | DOUBLEQUOTE :
        (* prevent expansion within quoted literal *)
        CopyCharsUpTo(template, ch)
        
    (* placeholder *)
    | '#' :
      (* get next char *)
      ReadChar(template, ch);
      
      IF ch = '#' THEN
        (* 2nd char matched *)
        ExpandPlaceholder(template, outfile)
        
      ELSE (* 2nd char did not match *)
        WriteChar(outfile, "#");
        (* put 2nd char back *)
        InsertChar(template, ch)
      END (* IF *)
    
    (* single quoted literal *)
    | SINGLEQUOTE :
        (* prevent expansion within quoted literal *)
        CopyCharsUpTo(template, ch)
        
    (* m2pp directive *)
    | '(' :
      (* get next char *)
      ReadChar(template, ch);
      
      IF ch = '*' THEN
        (* 2nd char matched *)
        ReadChar(c, ch);
        
        IF ch = '?' THEN
          (* 3rd char matched *)
          Directive(template, outfile)
          
        ELSE (* 3rd char did not match *)
          WriteChars(outfile, "(*");
          (* put 3rd char back *)
          InsertChar(template, ch)
        END (* IF *)
        
      ELSE (* 2nd char did not match *)
        WriteChar(outfile, "(");
        (* put 2nd char back *)
        InsertChar(template, ch)
      END (* IF *)
    
    (* m2pp comment *)
    | '/' :
      (* 1st char matched *)
      ReadChar(template, ch);
      
      IF ch = '*' THEN
        (* 2nd char matched *)
        SkipComment(template);
        
      ELSE (* 2nd char did not match *)
        WriteChar(outfile, "/");
        (* put last char back *)
        InsertChar(template, ch)
      END (* IF *)
      
    (* any other chars *)
    ELSE
      WriteChar(template, ch)
    END (* CASE *)
  END (* WHILE *)  
END Expand;


(* ---------------------------------------------------------------------------
 * function EOF()
 * ---------------------------------------------------------------------------
 * Returns TRUE if infile has reached EOF, else FALSE.
 * ------------------------------------------------------------------------ *)

PROCEDURE EOF( infile : File ) : BOOLEAN;

BEGIN
  RETURN BasicFileIO.eof(infile)
END EOF;


(* ---------------------------------------------------------------------------
 * procedure ReadChar(infile ch)
 * ---------------------------------------------------------------------------
 * Reads a character from the input file and passes it back in ch
 * ------------------------------------------------------------------------ *)

PROCEDURE ReadChar( infile : File; VAR ch : CHAR );
  
BEGIN
  BasicFileIO.ReadChar(infile, ch);
END ReadChar;


(* ---------------------------------------------------------------------------
 * procedure InsertChar(infile, ch)
 * ---------------------------------------------------------------------------
 * Inserts ch into infile's insert buffer to be reread by next ReadChar call
 * ------------------------------------------------------------------------ *)

PROCEDURE InsertChar( infile : File; VAR ch : CHAR );
  
BEGIN
  BasicFileIO.InsertChar(infile, ch);
END InsertChar;


(* ---------------------------------------------------------------------------
 * procedure WriteChar(outfile, ch)
 * ---------------------------------------------------------------------------
 * Writes a character to the output file if it is a printable character
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteChar( outfile : File; ch : CHAR );

BEGIN
  (* write to output if printable char *)
  IF (ch >= SPACE) AND (ch # DEL) THEN
    BasicFileIO.WriteChar(outfile, ch)
  END   
END WriteChar;


(* ---------------------------------------------------------------------------
 * procedure WriteChars(outfile, array)
 * ---------------------------------------------------------------------------
 * Writes a character array to the output file
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteChars( outfile : File; array : ARRAY OF CHAR );

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
      BasicFileIO.Write(outfile, ch)
    END   
  END (* FOR *)
END WriteChars;


(* ---------------------------------------------------------------------------
 * procedure WriteStr(outfile, array)
 * ---------------------------------------------------------------------------
 * Writes a string to the output file
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteStr( outfile : File; string : StringT );

PROCEDURE WriteCharsToOutfile ( array : ARRAY OF CHAR );

BEGIN
  WriteChars(outfile, array)
END WriteCharsToOutfile;

BEGIN
  String.withCharsDo(string, WriteCharsToOutfile)
END WriteStr;


(* ---------------------------------------------------------------------------
 * procedure WriteLn(outfile)
 * ---------------------------------------------------------------------------
 * Writes a newline to the output file
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteLn( outfile : File );

BEGIN
  BasicFileIO.WriteLn(outfile)
END WriteLn;


(* ---------------------------------------------------------------------------
 * procedure CopyQuotedLiteral(infile, outfile, delimiter)
 * ---------------------------------------------------------------------------
 * Reads a quoted literal from infile and writes it verbatim to outfile
 * ------------------------------------------------------------------------ *)

PROCEDURE CopyQuotedLiteral ( infile, outfile : File; delimiter : CHAR );
  
VAR
  next : CHAR;

BEGIN
  (* print lead delimiter already consumed by caller *)
  WriteChar(outfile, delimiter);
  
  (* get next char *)
  ReadChar(infile, next);
  
  WHILE next # delimiter DO
    IF (next) >= SPACE THEN
      WriteChar(outfile, next)
    END; (* IF *)
    
    (* get next char *)
    ReadChar(infile, next);
  END (* WHILE *)
  
  (* put last char back *)
  InsertChar(next)
END CopyQuotedLiteral;


(* ---------------------------------------------------------------------------
 * procedure ExpandPlaceholder(infile, outfile)
 * ---------------------------------------------------------------------------
 * Reads a placeholder from infile and writes its translation to outfile
 * ------------------------------------------------------------------------ *)

PROCEDURE ExpandPlaceholder ( infile, outfile : File );

VAR
  valid : BOOLEAN;
  ident, replacement : StringT;
  
BEGIN
  GetIdent(infile, ident, next, valid);
  
  IF NOT valid OR (next # '#') THEN
    WriteChars(outfile, "##");
    WriteStr(outfile, ident);
    InsertChar(infile, next);
    RETURN
  END; (* IF *)
  
  (* get next char *)
  ReadChar(infile, next);
  
  IF next # '#' THEN
    WriteChars(outfile, "##");
    WriteStr(outfile, ident);
    WriteChar(outfile, "#");
    InsertChar(next);
    RETURN
  END; (* IF *)
  
  (* lookup replacement string *)
  replacement := Dictionary.stringForKey(ident);
  IF replacement # NIL THEN
    (* print replacement string *)
    WriteStr(outfile, replacement)
    
  ELSE (* no entry found *)
    WriteChars(outfile, "##");
    WriteStr(outfile, ident);
    WriteChars(outfile, "##")
  END (* IF *)
END ExpandPlaceholder;


(* ---------------------------------------------------------------------------
 * procedure Directive(infile)
 * ---------------------------------------------------------------------------
 * Reads an M2PP preprocessor directive from infile and processes it
 * ------------------------------------------------------------------------ *)

PROCEDURE Directive ( infile : File );

VAR
  ident, version : StringT;
  
BEGIN
  ReadChar(infile, next);
  
  (* conditional insert directive *)
  IF ((next >= 'a') AND (next <= 'z')) THEN
    GetIdent(infile, ident, next, valid)
    
    (* check if identifier matches version string *)
    version := Dictionary.stringForKey("ver");
    IF (version # NIL) AND (ident = version) THEN
      (* continue *)
      RETURN
      
    ELSE (* skip chars until next directive *)
      SkipToStartOfDirective(infile)
    END (* IF *)
    
  (* section terminator directive *)
  ELSIF next = ';' THEN
    SkipToEndOfDirective(infile)
    
  ELSE (* illegal char *)  
    (* TO DO : report error *)
    SkipToEndOfDirective(infile)
  END (* CASE *)
END Directive;


(* ---------------------------------------------------------------------------
 * procedure SkipComment(infile)
 * ---------------------------------------------------------------------------
 * Reads and consumes a preprocessor comment from infile
 * ------------------------------------------------------------------------ *)

PROCEDURE SkipComment( infile : File );

VAR
  next : CHAR;
  delimiterFound : BOOLEAN;

BEGIN
  delimiterFound := FALSE;
  
  WHILE NOT delimiterFound DO
    (* get next char *)
    ReadChar(infile, next);
    
    IF next = '*' THEN
      (* possibly closing delimiter *)
      ReadChar(infile, next);
      
      IF next = '/' THEN
        delimiterFound := TRUE
      END (* IF *)
    END (* IF *)
  END (* WHILE *)
END SkipComment;


END M2PP.