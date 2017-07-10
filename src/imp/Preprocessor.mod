(*!m2iso*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE Preprocessor;

(* Modula-2 Preprocessor -- initial simplified version *)

IMPORT Infile, Outfile, Dictionary, String;

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

PROCEDURE Expand ( infile : InfileT; outfile : OutfileT );

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
          Directive(infile, outfile)
          
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
 * procedure CopyQuotedLiteral(infile, outfile)
 * ---------------------------------------------------------------------------
 * Reads a quoted literal from infile and writes it verbatim to outfile
 * ------------------------------------------------------------------------ *)

PROCEDURE CopyQuotedLiteral ( infile : InfileT; outfile : OutfileT );
  
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

PROCEDURE ExpandPlaceholder ( infile : InfileT; outfile : OutfileT );

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
  
  (* read identifier *)
  ident := stdIdent(infile);
      
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

PROCEDURE Directive ( infile : InfileT );

VAR
  ident, version : StringT;
  
BEGIN
  (* '(*' has already been consumed *)
  
  (* '?' *)
  Infile.ReadChar(infile, next);
  next := Infile.lookahead(infile);
  
  (* IMPCAST | TCAST *)
  (* bail out if following char is not letter *)
  IF NOT (((next >= 'a') AND (next <= 'z')) OR
    ((next >= 'A') AND (next <= 'Z'))) THEN
    Outfile.WriteChars(outfile, "##");
    RETURN
  END; (* IF *)
  
  (* read identifier *)
  ident := upperIdent(infile);
  
  (* IMPCAST *)
  IF String.matchesArray(ident, "IMPCAST") THEN
    next := Infile.lookahead(infile);
    
    (* '*' *)
    IF next = '*' THEN
      (* consume *)
      Infile.ReadChar(infile, next);
      next := Infile.lookahead(infile);
      
      (* ')' *)
      IF next = ')' THEN (* well formed *)
        version := Dictionary.stringForKey("ver");
        IF String.matchesArray(version, "iso") THEN
          Outfile.WriteChars(outfile, "FROM SYSTEM IMPORT CAST;")
        END (* IF *)
        
      ELSE (* malformed directive *)
        Outfile.WriteChars(outfile, "(*?");
        Outfile.WriteString(outfile, ident);
        Outfile.WriteChar(outfile, '*')
        
    ELSE (* malformed directive *)
      Outfile.WriteChars(outfile, "(*?");
      Outfile.WriteString(outfile, ident)
    END (* IF *)
  
  (* TCAST *)
  ELSIF String.matchesArray(ident, "TCAST") THEN
    next := Infile.lookahead(infile);
    
    (* '(' *)
    IF next = '(' THEN
      (* consume *)
      Infile.ReadChar(infile, next);
      next := Infile.lookahead(infile);
      
      (* typeIdent *)
      IF ((next >= 'a') AND (next <= 'z')) OR
        ((next >= 'A') AND (next <= 'Z')) THEN
        
        (* read identifier *)
        typeIdent := stdIdent(infile);
        next := Infile.lookahead(infile);
        
        (* ',' *)
        IF next = ',' THEN
          (* consume *)
          Infile.ReadChar(infile, next);
          next := Infile.lookahead(infile);
          
          (* ' '? *)
          IF next = SPACE THEN
            (* consume *)
            Infile.ReadChar(infile, next);
            next := Infile.lookahead(infile);
          END (* IF *)
          
          (* value *)
          IF ((next >= 'a') AND (next <= 'z')) OR
            ((next >= 'A') AND (next <= 'Z')) THEN
            
            (* read identifier *)
            value := stdIdent(infile);
            next := Infile.lookahead(infile);
            
            (* ')' *)
            IF next = ')' THEN
              (* consume *)
              Infile.ReadChar(infile, next);
              next := Infile.lookahead(infile);
              
              (* '*' *)
              IF next = '*' THEN
                (* consume *)
                Infile.ReadChar(infile, next);
                next := Infile.lookahead(infile);
                
                (* ')' *)
                IF next = '*' THEN
                  (* consume *)
                  Infile.ReadChar(infile, next);
                  next := Infile.lookahead(infile);
                  
                  (* write dialect specific cast *)
                  WriteCast(outfile, typeIdent, value)
                  
                ELSE (* malformed directive *)
                  Outfile.WriteChars(outfile, "(*?");
                  Outfile.WriteString(outfile, ident);
                  Outfile.WriteChar(outfile, '(');
                  Outfile.WriteString(outfile, typeIdent);
                  Outfile.WriteChars(outfile, ", ");
                  Outfile.WriteString(outfile, value);
                  Outfile.WriteChars(outfile, ")*")
                END (* IF *)
                
              ELSE (* malformed directive *)
                Outfile.WriteChars(outfile, "(*?");
                Outfile.WriteString(outfile, ident);
                Outfile.WriteChar(outfile, '(');
                Outfile.WriteString(outfile, typeIdent);
                Outfile.WriteChars(outfile, ", ");
                Outfile.WriteString(outfile, value);
                Outfile.WriteChar(outfile, ')')
              END (* IF *)
              
            ELSE (* malformed directive *)
              Outfile.WriteChars(outfile, "(*?");
              Outfile.WriteString(outfile, ident);
              Outfile.WriteChar(outfile, '(');
              Outfile.WriteString(outfile, typeIdent);
              Outfile.WriteChars(outfile, ", ");
              Outfile.WriteString(outfile, value)
            END (* IF *)
            
          ELSE (* malformed directive *)
            Outfile.WriteChars(outfile, "(*?");
            Outfile.WriteString(outfile, ident);
            Outfile.WriteChar(outfile, '(');
            Outfile.WriteString(outfile, typeIdent);
            Outfile.WriteChars(outfile, ", ")
          END (* IF *)
        
        ELSE (* malformed directive *)
          Outfile.WriteChars(outfile, "(*?");
          Outfile.WriteString(outfile, ident);
          Outfile.WriteChar(outfile, '(');
          Outfile.WriteString(outfile, typeIdent)
        END (* IF *)
        
      ELSE (* malformed directive *)
        Outfile.WriteChars(outfile, "(*?");
        Outfile.WriteString(outfile, ident);
        Outfile.WriteChar(outfile, '(')
      END (* IF *)
    
    ELSE (* malformed directive *)
      Outfile.WriteChars(outfile, "(*?");
      Outfile.WriteString(outfile, ident)
    END (* IF *)
        
  ELSE (* unknown directive *)
    Outfile.WriteChars(outfile, "(*?")
  END (* IF *)
END Directive;


(* ---------------------------------------------------------------------------
 * procedure upperIdent(infile)
 * ---------------------------------------------------------------------------
 * Reads and consumes an all-uppercase identifier from infile and returns it.
 * ------------------------------------------------------------------------ *)

PROCEDURE upperIdent ( infile : InfileT ) : StringT;

VAR
  next : CHAR;

BEGIN
  (* mark identifier *)
  Infile.MarkChar(infile);
  
  REPEAT
    Infile.ReadChar(infile, next);
    next := Infile.lookahead(infile)
  UNTIL (next < 'A') OR (next > 'Z'); 
    
  (* return identifier *)
  RETURN Infile.lexeme(infile);
END upperIdent;


(* ---------------------------------------------------------------------------
 * procedure stdIdent(infile)
 * ---------------------------------------------------------------------------
 * Reads and consumes a standard identifier from infile and returns it.
 * ------------------------------------------------------------------------ *)

PROCEDURE stdIdent ( infile : InfileT ) : StringT;

VAR
  next : CHAR;

BEGIN
  (* mark identifier *)
  Infile.MarkChar(infile);
  
  REPEAT
    Infile.ReadChar(infile, next);
    next := Infile.lookahead(infile)
  UNTIL (* not alpha-numeric *)
    (next < '0') OR
    ((next > '9') AND (next < 'A')) OR
    ((next > 'Z') AND (next < 'a')) OR
    ((next > 'z');
    
  (* return identifier *)
  RETURN Infile.lexeme(infile)
END stdIdent;


(* ---------------------------------------------------------------------------
 * procedure WriteCast(infile, type, value)
 * ---------------------------------------------------------------------------
 * Writes dialect specific cast to outfile.
 * ------------------------------------------------------------------------ *)

PROCEDURE WriteCast ( outfile : OutfileT; type, value : StringT );

VAR
  version : StringT;
  
BEGIN
  version := Dictionary.stringForKey("ver");
  
  (* PIM specific cast *)
  IF String.matchesArray(version, "pim") THEN
    Outfile.WriteString(outfile, type);
    Outfile.WriteChar(outfile, '(');
    Outfile.WriteString(value);
    Outfile.WriteChar(outfile, ')')
    
  (* ISO specific cast *)
  ELSIF String.matchesArray(version, "iso") THEN
    Outfile.WriteChars(outfile, "CAST(");
    Outfile.WriteString(outfile, type);
    Outfile.WriteChars(outfile, ", ");
    Outfile.WriteString(value);
    Outfile.WriteChar(outfile, ')')
  
  (* no version *)
  ELSE (* write directive *)
    Outfile.WriteChars(outfile, "(*?TCAST(");
    Outfile.WriteString(outfile, type);
    Outfile.WriteChars(outfile, ", ");
    Outfile.WriteString(value);
    Outfile.WriteChars(outfile, ')*)')
  END (* IF *)
END WriteCast;


(* ---------------------------------------------------------------------------
 * procedure SkipComment(infile)
 * ---------------------------------------------------------------------------
 * Reads and consumes a preprocessor comment from infile. If the current
 * writing position of outfile is at column 1 and a newline immediately
 * follows the comment in infile, then the newline is also consumed.
 * ------------------------------------------------------------------------ *)

PROCEDURE SkipComment( infile : InfileT; outfile : OutfileT );

VAR
  next : CHAR;
  delimiterFound : BOOLEAN;

BEGIN
  delimiterFound := FALSE;
  
  (* consume "/*" *)
  Infile.ReadChar(infile, next);
  Infile.ReadChar(infile, next);
  
  (* consume chars until closing delimiter *)
  WHILE NOT delimiterFound DO
    (* get next char *)
    ReadChar(infile, next);
    
    (* check for closing delimiter *)
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


END Preprocessor.