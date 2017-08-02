(*!m2pim*) (* Copyright (c) 2017 Modula-2 Software Foundation *)

IMPLEMENTATION MODULE Preprocessor;

(* Modula-2 Preprocessor -- initial simplified version *)

IMPORT Infile, Outfile, Dictionary, String;

FROM ISO646 IMPORT
  NUL, TAB, LF, CR, SPACE, DEL, SINGLEQUOTE, DOUBLEQUOTE;
FROM String IMPORT StringT; (* alias for String.String *)
FROM Infile IMPORT InfileT; (* alias for Infile.Infile *)
FROM Outfile IMPORT OutfileT; (* alias for Outfile.Outfile *)


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
    next := Infile.lookaheadChar(infile);
    
    CASE next OF
    (* tabulator *)
      TAB :
        (* consume and write *)
        next := Infile.consumeChar(infile);
        Outfile.WriteTab(outfile)
      
    (* newline *)
    | LF :        
        (* consume and write *)
        next := Infile.consumeChar(infile);
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
        (* write and consume *)
        Outfile.WriteChar(outfile, next);
        next := Infile.consumeChar(infile)
      END (* IF *)
    
    (* m2pp directive *)
    | '(' :
      (* consume *)
      next := Infile.consumeChar(infile);
      
      IF next = '*' THEN
      (* consume *)
        next := Infile.consumeChar(infile);
        
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
        SkipComment(infile, outfile)
      
      ELSE (* sole slash *)
        (* write and consume *)
        Outfile.WriteChar(outfile, '/');
        next := Infile.consumeChar(infile)
      END (* IF *)
      
    (* any other chars *)
    ELSE
      (* write and consume *)
      Outfile.WriteChar(outfile, next);
      next := Infile.consumeChar(infile)
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
  done : BOOLEAN;
  next, delimiter : CHAR;

BEGIN
  (* write delimiter *)
  delimiter := Infile.lookaheadChar(infile);
  Outfile.WriteChar(outfile, delimiter);
  
  done := FALSE;
  next := Infile.consumeChar(infile);
  WHILE NOT done AND NOT (Infile.eof(infile)) AND (next # LF) DO
    (* write *)
    Outfile.WriteChar(outfile, next);
    done := (next = delimiter);
    (* consume *)
    next := Infile.consumeChar(infile)
  END (* WHILE *)
END CopyQuotedLiteral;


(* ---------------------------------------------------------------------------
 * procedure ExpandPlaceholder(infile, outfile)
 * ---------------------------------------------------------------------------
 * Reads a placeholder from infile and writes its translation to outfile
 * ------------------------------------------------------------------------ *)

PROCEDURE ExpandPlaceholder ( infile : InfileT; outfile : OutfileT );

VAR
  next : CHAR;
  ident, replacement : StringT;
  
BEGIN
  (* consume opening delimiter *)
  next := Infile.consumeChar(infile);
  next := Infile.consumeChar(infile);
  
  (* bail out if following char is not letter *)
  IF NOT (((next >= 'a') AND (next <= 'z')) OR
    ((next >= 'A') AND (next <= 'Z'))) THEN
    Outfile.WriteChars(outfile, "##");
    RETURN
  END; (* IF *)
  
  (* read identifier *)
  ident := stdIdent(infile);
      
  (* lookup replacement string *)
  replacement := Dictionary.valueForKey(ident);
  IF replacement # String.Nil THEN
    (* write replacement string *)
    Outfile.WriteString(outfile, replacement);
    
    (* consume closing delimiter *)
    next := Infile.lookaheadChar(infile);
    IF (next = '#') AND (Infile.la2Char(infile) = '#') THEN
      next := Infile.consumeChar(infile);
      next := Infile.consumeChar(infile)
    END (* IF *)
    
  ELSE (* no entry found *)
    Outfile.WriteChars(outfile, "##");
    Outfile.WriteString(outfile, ident);
    Outfile.WriteChars(outfile, "##")
  END (* IF *)
END ExpandPlaceholder;


(* ---------------------------------------------------------------------------
 * procedure Directive(infile, outfile)
 * ---------------------------------------------------------------------------
 * Reads an M2PP preprocessor directive from infile and processes it
 * ------------------------------------------------------------------------ *)

PROCEDURE Directive ( infile : InfileT; outfile : OutfileT );

VAR
  next : CHAR;
  ident, typeIdent, value, key, version : StringT;
  
BEGIN
  (* opening comment delimiter has already been consumed *)
  
  (* '?' *)
  next := Infile.consumeChar(infile);
  
  (* IMPCAST | TCAST *)
  (* bail out if following char is not letter *)
  IF NOT (((next >= 'a') AND (next <= 'z')) OR
    ((next >= 'A') AND (next <= 'Z'))) THEN
    Outfile.WriteChars(outfile, "(*?");
    RETURN
  END; (* IF *)
  
  (* read identifier *)
  ident := upperIdent(infile);
  
  (* IMPCAST *)
  IF String.matchesConstArray(ident, "IMPCAST") THEN
    next := Infile.lookaheadChar(infile);
    
    (* '*' *)
    IF next = '*' THEN
      (* consume *)
      next := Infile.consumeChar(infile);
      
      (* ')' *)
      IF next = ')' THEN (* well formed *)
        next := Infile.consumeChar(infile);
        key := String.forConstArray("ver");
        version := Dictionary.valueForKey(key);
        IF String.matchesConstArray(version, "iso") THEN
          Outfile.WriteChars(outfile, "FROM SYSTEM IMPORT CAST;")
        END (* IF *)
        
      ELSE (* malformed directive *)
        Outfile.WriteChars(outfile, "(*?");
        Outfile.WriteString(outfile, ident);
        Outfile.WriteChar(outfile, '*')
      END (* IF *)
        
    ELSE (* malformed directive *)
      Outfile.WriteChars(outfile, "(*?");
      Outfile.WriteString(outfile, ident)
    END (* IF *)
  
  (* TCAST *)
  ELSIF String.matchesConstArray(ident, "TCAST") THEN
    next := Infile.lookaheadChar(infile);
    
    (* '(' *)
    IF next = '(' THEN
      (* consume *)
      next := Infile.consumeChar(infile);
      
      (* typeIdent *)
      IF ((next >= 'a') AND (next <= 'z')) OR
        ((next >= 'A') AND (next <= 'Z')) THEN
        
        (* read identifier *)
        typeIdent := stdIdent(infile);
        next := Infile.lookaheadChar(infile);
        
        (* ',' *)
        IF next = ',' THEN
          (* consume *)
          next := Infile.consumeChar(infile);
          
          (* ' '? *)
          IF next = SPACE THEN
            (* consume *)
            next := Infile.consumeChar(infile);
          END; (* IF *)
          
          (* value *)
          IF ((next >= 'a') AND (next <= 'z')) OR
            ((next >= 'A') AND (next <= 'Z')) THEN
            
            (* read identifier *)
            value := stdIdent(infile);
            next := Infile.lookaheadChar(infile);
            
            (* ')' *)
            IF next = ')' THEN
              (* consume *)
              next := Infile.consumeChar(infile);
              
              (* '*' *)
              IF next = '*' THEN
                (* consume *)
                next := Infile.consumeChar(infile);
                
                (* ')' *)
                IF next = '*' THEN
                  (* consume *)
                  next := Infile.consumeChar(infile);
                  
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
  Infile.MarkLexeme(infile);
  
  REPEAT
    next := Infile.consumeChar(infile)
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
  Infile.MarkLexeme(infile);
  
  REPEAT
    next := Infile.consumeChar(infile)
  UNTIL (* not alpha-numeric *)
    (next < '0') OR
    ((next > '9') AND (next < 'A')) OR
    ((next > 'Z') AND (next < 'a')) OR
    ((next > 'z'));
    
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
  key, version : StringT;
  
BEGIN
  key := String.forConstArray("ver");
  version := Dictionary.valueForKey(key);
  
  (* PIM specific cast *)
  IF String.matchesConstArray(version, "pim") THEN
    Outfile.WriteString(outfile, type);
    Outfile.WriteChar(outfile, '(');
    Outfile.WriteString(outfile, value);
    Outfile.WriteChar(outfile, ')')
    
  (* ISO specific cast *)
  ELSIF String.matchesConstArray(version, "iso") THEN
    Outfile.WriteChars(outfile, "CAST(");
    Outfile.WriteString(outfile, type);
    Outfile.WriteChars(outfile, ", ");
    Outfile.WriteString(outfile, value);
    Outfile.WriteChar(outfile, ')')
  
  (* no version *)
  ELSE (* write directive *)
    Outfile.WriteChars(outfile, "(*?TCAST(");
    Outfile.WriteString(outfile, type);
    Outfile.WriteChars(outfile, ", ");
    Outfile.WriteString(outfile, value);
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

PROCEDURE SkipComment ( infile : InfileT; outfile : OutfileT );

VAR
  next : CHAR;
  delimiterFound : BOOLEAN;

BEGIN
  delimiterFound := FALSE;
  
  (* consume "/*" *)
  next := Infile.consumeChar(infile);
  next := Infile.consumeChar(infile);
  
  (* consume chars until closing delimiter *)
  WHILE NOT Infile.eof(infile) AND 
    (next # '*') AND (Infile.la2Char(infile) # '/') DO
    next := Infile.consumeChar(infile)
  END; (* WHILE *)
  
  (* skip newline if this comment is the only content in this line *)
  IF (next = LF) AND (Outfile.column(outfile) = 1) THEN
    (* consume newline *)
    next := Infile.consumeChar(infile)
  END (* IF *)
END SkipComment;


END Preprocessor.