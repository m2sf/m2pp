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

PROCEDURE Expand ( infile : Infile; outfile : Outfile );

VAR
  next : CHAR;

BEGIN
  (* read chars from infile until EOF *)
  WHILE NOT Infile.eof(infile) DO
    (* all decisions based on lookahead *)
    next := Infile.lookahead(infile);
    
    CASE next OF
    (* tabulator *)
      TAB :
        (* consume and write *)
        Infile.ReadChar(infile, next);
        Outfile.WriteTab(outfile)
      
    (* newline *)
    | LF :        
        (* consume and write *)
        Infile.ReadChar(infile, next);
        Outfile.WriteLn(outfile)
        
    (* quoted literal *)
    | DOUBLEQUOTE, SINGLEQUOTE :
        (* consume and write *)
        CopyQuotedLiteral(infile, outfile)       
        
    (* placeholder *)
    | '#' :
      IF Infile.la2Char(infile) = '#' THEN (* found m2pp placeholder *)
        (* consume and write *)
        ExpandPlaceholder(infile, outfile)
        
      ELSE (* not a placeholder *)
        (* consume and write *)
        Infile.ReadChar(infile, next);
        Outfile.WriteChar(outfile, next)
      END (* IF *)
    
    (* m2pp directive *)
    | '(' :
      (* consume *)
      Infile.ReadFile(infile, next);
      next := Infile.lookahead(infile, next);
      
      IF next = '*' THEN
      (* consume *)
        Infile.ReadFile(infile, next);
        next := Infile.lookahead(infile, next);
    
        IF next = '?' THEN (* m2pp directive *)
          ExpandDirective(infile, outfile)
          
        ELSE (* Modula-2 comment *)
          Outfile.WriteChars(outfile, "(*")
        END (* IF *)
        
      ELSE (* sole parenthesis *)
        Outfile.WriteChar(outfile, '(')
      END; (* IF *)
          
    (* m2pp comment *)
    | '/' :
      IF Infile.la2Char(infile) = '*' THEN (* m2pp comment *)
        (* consume *)
        SkipComment(infile)
      
      ELSE (* sole slash *)
        (* consume and write *)
        Infile.ReadChar(infile, next);
        Outfile.WriteChar(outfile, '/')
      END (* IF *)
      
    (* any other chars *)
    ELSE
      (* consume and write *)
      Infile.ReadChar(infile, next);
      Outfile.WriteChar(outfile, next)
    END (* CASE *)
  END (* WHILE *)  
END Expand;


(* ---------------------------------------------------------------------------
 * procedure CopyQuotedLiteral(infile, outfile, delimiter)
 * ---------------------------------------------------------------------------
 * Reads a quoted literal from infile and writes it verbatim to outfile
 * ------------------------------------------------------------------------ *)

PROCEDURE CopyQuotedLiteral ( infile, outfile : File );
  
VAR
  next, delimiter : CHAR;

BEGIN
  (* consume and write delimiter *)
  Infile.ReadChar(infile, delimiter);
  WriteChar(outfile, delimiter);
  
  REPEAT
    (* consume and write *)
    Infile.ReadChar(infile, next);
    Outfile.WriteChar(outfile, next)
  UNTIL (next = delimiter) OR (next = LF) OR (Infile.eof(infile))
END CopyQuotedLiteral;


(* ---------------------------------------------------------------------------
 * procedure ExpandPlaceholder(infile, outfile)
 * ---------------------------------------------------------------------------
 * Reads a placeholder from infile and writes its translation to outfile
 * ------------------------------------------------------------------------ *)

PROCEDURE ExpandPlaceholder ( infile, outfile : File );

VAR
  ident, replacement : StringT;
  
BEGIN
  (* consume opening delimiter *)
  Infile.ReadChar(infile, next);
  Infile.ReadChar(infile, next);
  next := Infile.lookahead(infile);
  
  (* bail out if following char is not letter *)
  IF NOT (((next >= 'a') AND (next <= 'z')) OR
    ((next >= 'A') AND (next <= 'Z'))) THEN
    Outfile.WriteChars(outfile, "##");
    RETURN
  END; (* IF *)
  
  (* mark identifier *)
  Infile.MarkChar(infile);
  
  (* consume and write lead char *)
  Infile.ReadChar(infile, next);
  Outfile.WriteChar(outfile, next);
  next := Infile.lookahead(infile);
  
  (* consume and write tail of identifier *)
  WHILE ((next >= 'a') AND (next <= 'z')) OR
        ((next >= 'A') AND (next <= 'Z')) OR
        ((next >= '0') AND (next <= '9')) DO
    Infile.ReadChar(infile, next);
    Outfile.WriteChar(outfile, next);
    next := Infile.lookahead(infile)
  END; (* WHILE *)
  
  (* get identifier *)
  ident := Infile.lexeme(infile);
    
  (* lookup replacement string *)
  replacement := Dictionary.stringForKey(ident);
  IF replacement # NIL THEN
    (* write replacement string *)
    Outfile.WriteString(outfile, replacement);
    
    (* consume closing delimiter *)
    next := Infile.lookahead(infile);
    IF (next = '#') AND (Infile.la2Char(infile) = '#') THEN
      Infile.ReadChar(infile, next);
      Infile.ReadChar(infile, next);
    END (* IF *)
    
  ELSE (* no entry found *)
    Outfile.WriteChars(outfile, "##");
    Outfile.WriteString(outfile, ident);
    Outfile.WriteChars(outfile, "##")
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
  (* consume opening delimiter *)
  Infile.ReadChar(infile, next);
  next := Infile.lookahead(infile);
  
  (* bail out if following char is not letter *)
  IF NOT (((next >= 'a') AND (next <= 'z')) OR
    ((next >= 'A') AND (next <= 'Z'))) THEN
    Outfile.WriteChars(outfile, "##");
    RETURN
  END; (* IF *)
  
  (* mark identifier *)
  Infile.MarkChar(infile);
  
  (* consume and write lead char *)
  Infile.ReadChar(infile, next);
  Outfile.WriteChar(outfile, next);
  next := Infile.lookahead(infile);
  
  (* consume and write tail of identifier *)
  WHILE ((next >= 'A') AND (next <= 'Z')) DO
    Infile.ReadChar(infile, next);
    Outfile.WriteChar(outfile, next);
    next := Infile.lookahead(infile)
  END; (* WHILE *)
  
  (* get identifier *)
  ident := Infile.lexeme(infile);
  
  IF String.matchesArray(ident, "IMPCAST") THEN
    next := Infile.lookahead(infile);
    
    IF next = '*' THEN
      (* consume *)
      Infile.ReadChar(infile, next);
      next := Infile.lookahead(infile);
      
      IF next = ')' THEN (* well formed *)
        version := Dictionary.stringForKey("ver");
        IF String.matchesArray(version, "iso") THEN
          Outfile.WriteChars(outfile, "FROM SYSTEM IMPORT CAST;");
        END (* IF *)
        
      ELSE (* malformed directive *)
        Outfile.WriteChars(outfile, "(*?");
        Outfile.WriteString(outfile, ident);
        Outfile.WriteChar(outfile, '*')
        
    ELSE (* malformed directive *)
      Outfile.WriteChars(outfile, "(*?");
      Outfile.WriteString(outfile, ident)
    END (* IF *)
    
  ELSIF String.matchesArray(ident, "TCAST") THEN
    
    (* TO DO *)
    
    (* '(' *)
    
    (* typeIdent *)
    
    (* ',' *)
    
    (* ' '? *)
    
    (* value *)
    
    (* ')' *)
    
    version := Dictionary.stringForKey("ver");
    IF String.matchesArray(version, "pim") THEN
      Outfile.WriteString(outfile, typeIdent);
      Outfile.WriteChar(outfile, '(');
      Outfile.WriteString(value);
      Outfile.WriteChar(outfile, ')')
      
    ELSIF String.matchesArray(version, "iso") THEN
      Outfile.WriteChars(outfile, "CAST(");
      Outfile.WriteString(outfile, typeIdent);
      Outfile.WriteChars(outfile, ", ");
      Outfile.WriteString(value);
      Outfile.WriteChar(outfile, ')')
    END (* IF *)
    
  ELSE (* unknown directive *)
    
  END (* IF *)
END Directive;


(* ---------------------------------------------------------------------------
 * procedure SkipComment(infile)
 * ---------------------------------------------------------------------------
 * Reads and consumes a preprocessor comment from infile. If the current
 * writing position of outfile is at column 1 and a newline immediately
 * follows the comment in infile, then the newline is also consumed.
 * ------------------------------------------------------------------------ *)

PROCEDURE SkipComment( infile : Infile; outfile : Outfile);

VAR
  next : CHAR;
  delimiterFound : BOOLEAN;

BEGIN
  delimiterFound := FALSE;
  
  (* consume '/' *)
  Infile.ReadChar(infile, next);
  (* consume '*' *)
  Infile.ReadChar(infile, next);
  
  (* consume chars until closing delimiter *)
  WHILE NOT delimiterFound DO
    (* get next char *)
    ReadChar(infile, next);
    
    IF (next = '*') AND (Infile.la2Char(infile) = '/') THEN
      delimiterFound := TRUE;
      (* consume delimiter *)
      ReadChar(infile, next);
    END (* IF *)
  END (* WHILE *)
  
  (* skip newline if this comment is the only content in this line *)
  IF (Infile.lookahead(infile) = LF) AND (Outfile.column(outfile) = 1) THEN
      (* consume newline *)
      Infile.ReadChar(infile, next)
    END (* IF *)
  END (* IF *)
END SkipComment;


END M2PP.